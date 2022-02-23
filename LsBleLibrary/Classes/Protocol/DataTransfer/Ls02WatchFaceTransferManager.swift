//
//  Ls02WatchFaceTransferManager.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/12/27.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

public enum CloudWatchFaceProcess {
    case success                        // 成功
    case progress(_ value: Float)       // 进度条
    case dataerror                      // 升级bin 文件异常
    case timeout                        // 发送数据超时
    case notaccept                      // 设备不接受传输
    case crcerror                       // crc 校验失败
    case spaceerror                     // 空间不够
    case discontinuous                  // 序列号不连续
    case unknow                         // 未知
}

public class Ls02WatchFaceTransferManager {
    
    private var writeMaxValue: Int = 125        //每一包可发送的最大字节数 （默认 128 - 3 个头字节）
    private var serialNo: Int = 0               //发送的编号
    private var totalPackageNumber: Int = 0     //总共需要发送的次数
    private var currentSendIndex: Int = 0       //记录在 4K中 次发送中的第几次
    private var remainByteNumber: Int = 0       //最后一包的字节数
    private var writeDataSuspend: Bool = false  //暂停递归发送数据
    private var timeoutTimer: Timer?
    
    private var binData: Data!                  // 需要升级的bin 文件
    private var splitDataBy4KArray: [Data] = [] //按 4 k 切分好的数据
    private var currentWriteData: Data?         //当前正在处理的 4k数据
    
    private let bag: DisposeBag = DisposeBag()
    
    public init(binData: Data) {
        self.binData = binData
        self.splitData(data: binData)
        self.cloudWatchFaceValueObserver()
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
    
    public func start() -> Observable<CloudWatchFaceProcess> {
        self.requestCloudWatchFaceTransfer()
        return progressEvent.event
    }
    
    func requestCloudWatchFaceTransfer() {
        Ble02Operator.shared.requestCloudWatchFaceTransfer()
            .subscribe { [weak self] (prepare) in
                print("设备接受传输")
                self?.startCloudWatchFaceTransfer()
            } onError: {[weak self] (error) in
                print("设备不接受传输，请检查是否已存在或空间是否足够")
                self?.progressAction.progress.accept(.notaccept)
            }
            .disposed(by: self.bag)
    }
    
    func cloudWatchFaceValueObserver() {
        guard let obser = Ble02Operator.shared.dataObserver else {
            return
        }
        obser.subscribe { [weak self] (arg) in
            
            if arg.type == .u6101maxvalue {
                self?.writeMaxValue = (arg.data as! Int) - 3
            }
            print("MTU(最大发送值): \(String(describing: self?.writeMaxValue))")
            
            if arg.type == .cloudwatchface {
                let orders = arg.data as? (Int, Int)
                print("===== 表盘控制指令\(orders!.0)  \(orders!.1)")
                self?.transferControl(orders!.1, nil)
            }
            
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
        
        // 查看6101可发送的最大值
        BleHandler.shared.getmtu().subscribe {[weak self] (mtu) in
            print(mtu, "back mtu")
            if let m = mtu as? UInt32{
                self?.writeMaxValue = Int(m - 3)
            }
        } onError: { (err) in
            print(err)
        }.disposed(by: bag)
        
    }
    
    func transferControl(_ processCode: Int, _ resumeSerialNo: Int?) {
        switch processCode {
        case 4:
            print("收到继续传输指令，发送下一个4k")
            self.continueNext4k()
        case 1:
            print("失败 CRC 校验失败")
            self.progressAction.progress.accept(.crcerror)
            self.invalidateTimeoutTimer()
        case 2:
            print("失败 表盘数据太大")
            self.progressAction.progress.accept(.spaceerror)
            self.invalidateTimeoutTimer()
        case 3:
            print("失败 序号不匹配")
            self.progressAction.progress.accept(.discontinuous)
            self.invalidateTimeoutTimer()
        default:
            print("=====其他异常情况 : \(processCode)")
            self.progressAction.progress.accept(.unknow)
            self.invalidateTimeoutTimer()
        }
    }
    
    func startCloudWatchFaceTransfer() {
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
    
    func continueNext4k() {
        self.invalidateTimeoutTimer()       // 继续发送，定时器作废
        if self.splitDataBy4KArray.count > 0 {
            self.splitDataBy4KArray.removeFirst()
        }
        self.writeDataSuspend = false
        self.startCloudWatchFaceTransfer()
    }
    
    func writeComplete() {
        Ble02Operator.shared.writeComplete()
            .subscribe { (result) in
                print("升级完成")
                self.invalidateTimeoutTimer()   // 停止定时器
                self.progressAction.progress.accept(.success)
            } onError: { (error) in
                print("升级失败")
                self.progressAction.progress.accept(.unknow)
                self.invalidateTimeoutTimer()
            }
            .disposed(by: self.bag)
    }
    
    func writeBinData() {
        
        let serialByte1 = UInt8((serialNo>>8)&0xff)
        let serialByte2 = UInt8(serialNo&0xff)
        
        let writeCmd: [UInt8] = [LS02CommandType.sendWatchSkinTheme.rawValue, serialByte1, serialByte2]
        var writeData = Data.init(bytes: writeCmd, count: writeCmd.count)
        
        if(totalPackageNumber == self.currentSendIndex) {
            guard self.remainByteNumber > 0 else {
                return
            }
            let tempRemainCount = self.remainByteNumber
            let startIndex = self.currentWriteData!.index(self.currentWriteData!.startIndex, offsetBy: self.currentSendIndex * self.writeMaxValue)
            let endIndex = self.currentWriteData!.index(startIndex, offsetBy: tempRemainCount)
            let subDataRange:Range = startIndex..<endIndex
            let subData = self.currentWriteData!.subdata(in: subDataRange)
            writeData.append(subData)
            Ble02Operator.shared.directWrite(writeData, .withResponse)
            self.writeDataSuspend = true
            self.addTimeoutTimer(timeOutInterval: TimeInterval(8), repeats: false) {
                print("发送表盘文件过程中等待超时")
                self.progressAction.progress.accept(.timeout)
                self.invalidateTimeoutTimer()
            }
            self.serialNo += 1
            if self.splitDataBy4KArray.count == 1 {
                self.writeComplete()
            }
        } else {
            let startIndex = self.currentWriteData!.index(self.currentWriteData!.startIndex, offsetBy: self.currentSendIndex * self.writeMaxValue)
            let endIndex = self.currentWriteData!.index(startIndex, offsetBy: self.writeMaxValue)
            let subDataRange:Range = startIndex..<endIndex
            let subData = self.currentWriteData!.subdata(in: subDataRange)
            writeData.append(subData)
            Ble02Operator.shared.directWrite(writeData, .withResponse)
            self.serialNo += 1
            self.currentSendIndex += 1
        }
        
        let progress: Float = Float(self.serialNo) / (Float(self.binData.count) / Float(self.writeMaxValue))
        self.progressAction.progress.accept(.progress(progress))
        
        // 递归发送bin内容数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            guard self.writeDataSuspend == false else {
                return
            }
            self.writeBinData()
        }
    }
    
    //MARK: 4K切割数据
    func splitData(data: Data) {
        
        self.splitDataBy4KArray.removeAll()
        let dataLength = data.count
        
        let splitCount = dataLength / 4096
        let lastLeft   = dataLength % 4096
        
        for i in 0..<splitCount {
            let startIndex = data.index(data.startIndex, offsetBy: i * 4096)
            let endIndex = data.index(startIndex, offsetBy: 4096)
            let subDataRange:Range = startIndex..<endIndex
            self.splitDataBy4KArray.append(data.subdata(in: subDataRange))
        }
        
        if lastLeft > 0 {
            let startIndex = data.index(data.endIndex, offsetBy: -lastLeft)
            let subDataRange:Range = startIndex..<data.endIndex
            self.splitDataBy4KArray.append(data.subdata(in: subDataRange))
        }
    }
}

extension Ls02WatchFaceTransferManager {
    
    func addTimeoutTimer(timeOutInterval:TimeInterval, repeats: Bool,  timerBlock: @escaping (() -> Void)) {
        self.timeoutTimer = Timer.init(timeInterval: timeOutInterval, repeats: repeats, block: { (timer) in
            timerBlock()
        })
        RunLoop.current.add(self.timeoutTimer!, forMode: .common)
    }
    
    func invalidateTimeoutTimer() {
        if self.timeoutTimer != nil {
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }
}
