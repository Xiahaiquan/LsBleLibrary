//
//  Ls02GPSUpgradeTransferManager.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/27.
//
import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

public class Ls02GPSUpgradeTransferManager {
    
    private var agpsfileDataNumber: Int = 0
    private var writeMaxValue: Int = 125        //每一包可发送的最大字节数 （默认 128 - 3 个头字节）
    private var serialNo: Int = 0               //发送的编号
    private var totalPackageNumber: Int = 0     //总共需要发送的次数
    private var currentSendIndex: Int = 0       //记录在 4K中 次发送中的第几次
    private var remainByteNumber: Int = 0       //最后一包的字节数
    private var writeDataSuspend: Bool = false  //暂停递归发送数据
    private var timeoutTimer: Timer?
    
    private var binDatas: [(type: Ls02GPSOTAType, data: Data)]!                  // 需要升级的bin 文件
    private var splitDataBy4KArray: [Data] = [] //按 4 k 切分好的数据
    private var currentWriteData: Data?         //当前正在处理的 4k数据
    
    private let bag: DisposeBag = DisposeBag()
    
    public init(binDatas: [(type: Ls02GPSOTAType, data: Data)]) {
        self.binDatas = binDatas
    }
    
    // 信号中转器，功能： 监听 cell 的点击，信号转发到外部
    typealias RouterAction = (
        progress: PublishRelay<CloudWatchFaceProcess>, ()
    )
    
    private let progressAction: RouterAction = (
        PublishRelay(), ()
    )
    
    typealias Routing = (
        event: Observable<CloudWatchFaceProcess>, ()
    )
    
    lazy var progressEvent: Routing = (
        event: progressAction.progress.asObservable(), ()
    )
    
    //开始
    func start() {
        BleOperator.shared.readyUpdateAGPSCommand(type: .beidou).do { [weak self] statue in
            switch statue {
            case .ready:
                print("1.ready")
                self?.splitData()
                self?.startCloudWatchFaceTransfer()
            case .complete:
                print("1.complete")
            case .continueSend:
                print("1.continueSend")
            case .success:
                print("1.success")
            case .faile:
                print("1.faile")
            case .allComplete:
                print("1.allComplete")
            }
        }.subscribe { _ in
            
        } onError: { er in
            
        }.disposed(by: bag)
    }
    
    
    public func startCloudWatchFaceTransfer() {
        guard self.splitDataBy4KArray.count > 0 else {
            self.progressAction.progress.accept(.dataerror)           // 传入的数据为空
            return
        }
        if self.splitDataBy4KArray.count > 0 {
            self.currentSendIndex = 0
            self.currentWriteData = self.splitDataBy4KArray.first
            let dataLength = self.currentWriteData!.count
            self.remainByteNumber = dataLength % self.writeMaxValue
            self.totalPackageNumber = dataLength / self.writeMaxValue
            self.writeBinData()
        }
    }
    
    public func continueNext4k() {
        self.invalidateTimeoutTimer()       // 继续发送，定时器作废
        if self.splitDataBy4KArray.count > 0 {
            self.splitDataBy4KArray.removeFirst()
        }
        self.writeDataSuspend = false
        self.startCloudWatchFaceTransfer()
    }
    
    
    
    public func writeBinData() {
        
        //最后一包
        if(totalPackageNumber == self.currentSendIndex) {
            guard self.remainByteNumber > 0 else {
                return
            }
            let tempRemainCount = self.remainByteNumber
            let startIndex = self.currentWriteData!.index(self.currentWriteData!.startIndex, offsetBy: self.currentSendIndex * self.writeMaxValue)
            let endIndex = self.currentWriteData!.index(startIndex, offsetBy: tempRemainCount)
            let subDataRange:Range = startIndex..<endIndex
            let subData = self.currentWriteData!.subdata(in: subDataRange)
            
            self.sendOTABin(data: subData)
            
            self.writeDataSuspend = true
            self.addTimeoutTimer(timeOutInterval: TimeInterval(8), repeats: false) {
                print("发送表盘文件过程中等待超时")
                self.progressAction.progress.accept(.timeout)
                self.invalidateTimeoutTimer()
            }
            self.serialNo += 1
            
        } else {
            let startIndex = self.currentWriteData!.index(self.currentWriteData!.startIndex, offsetBy: self.currentSendIndex * self.writeMaxValue)
            let endIndex = self.currentWriteData!.index(startIndex, offsetBy: self.writeMaxValue)
            let subDataRange:Range = startIndex..<endIndex
            let subData = self.currentWriteData!.subdata(in: subDataRange)
            
            self.sendOTABin(data: subData)
            
            self.serialNo += 1
            self.currentSendIndex += 1
        }
        
        let progress: Float = Float(self.serialNo) / (Float(self.binDatas.count) / Float(self.writeMaxValue))
        self.progressAction.progress.accept(.progress(progress))
        
        // 递归发送bin内容数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            guard self.writeDataSuspend == false else {
                return
            }
            self.writeBinData()
        }
    }
    
    func sendOTABin(data: Data) {
        BleOperator.shared.sendAGPSDataCommand(gpsData: data, number: serialNo).do { [weak self] statue in
            switch statue {
            case .ready:
                print("2.ready")
            case .complete:
                print("2.complete, 发下一个")
                self?.binDatas.removeFirst()
            case .continueSend:
                print("2.continueSend")
                self?.continueNext4k()
            case .success:
                print("2.success")
                self?.progressAction.progress.accept(.success)
            case .faile:
                print("2.faile")
                self?.invalidateTimeoutTimer()
            case .allComplete:
                print("2.allComplete")
                self?.invalidateTimeoutTimer()
            }
        }.filter { statue in
            return statue == .complete
        }.flatMap { statue in
            
            return Observable<Bool>.create { (subscriber) -> Disposable in
                if self.binDatas.isEmpty {
                    let _ = BleOperator.shared.updateAGPComplete(type: .all)
                    subscriber.onNext(true)
                }else {
                    let _ = BleOperator.shared.updateAGPComplete(type: .signle)
                    subscriber.onNext(true)
                }
                return Disposables.create()
            }
        }.filter({ [unowned self]bool in
            
            if self.binDatas.isEmpty {
                self.progressAction.progress.accept(.success)
                return false
            }else {
                return true
            }
        })
            .subscribe { [weak self] bool in
                self?.splitData()
                self?.startCloudWatchFaceTransfer()
            } onError: { e in
                
            }.disposed(by: bag)
    }
    
    
    //MARK: 4K切割数据
    func splitData() {
        
        guard let gpsFileSignle = binDatas.first else {
            return
        }
        
        self.splitDataBy4KArray.removeAll()
        let dataLength = gpsFileSignle.data.count
        
        let splitCount = dataLength / 4096
        let lastLeft   = dataLength % 4096
        
        for i in 0..<splitCount {
            let startIndex = gpsFileSignle.data.index(gpsFileSignle.data.startIndex, offsetBy: i * 4096)
            let endIndex = gpsFileSignle.data.index(startIndex, offsetBy: 4096)
            let subDataRange:Range = startIndex..<endIndex
            self.splitDataBy4KArray.append(gpsFileSignle.data.subdata(in: subDataRange))
        }
        
        if lastLeft > 0 {
            let startIndex = gpsFileSignle.data.index(gpsFileSignle.data.endIndex, offsetBy: -lastLeft)
            let subDataRange:Range = startIndex..<gpsFileSignle.data.endIndex
            self.splitDataBy4KArray.append(gpsFileSignle.data.subdata(in: subDataRange))
        }
    }
}

extension Ls02GPSUpgradeTransferManager {
    
    public func addTimeoutTimer(timeOutInterval:TimeInterval, repeats: Bool,  timerBlock: @escaping (() -> Void)) {
        self.timeoutTimer = Timer.init(timeInterval: timeOutInterval, repeats: repeats, block: { (timer) in
            timerBlock()
        })
        RunLoop.current.add(self.timeoutTimer!, forMode: .RunLoopMode.commonModes)
    }
    
    public func invalidateTimeoutTimer() {
        if self.timeoutTimer != nil {
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }
}

