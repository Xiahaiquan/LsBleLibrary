//
//  LsCloudWatchFaceTeansfer05sManger.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/19.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

public enum DialUpgradeProcess {
    case success                        // 成功
    case progress(_ value: Float)       // 进度条
    case dataerror                      // 升级bin 文件异常
    case timeout                        // 发送数据超时
    case notaccept                      // 设备不接受传输
    case crcerror                       // crc 校验失败
    case spaceerror                     // 空间不够
    case discontinuous                  // 序列号不连续
    case unknow                         // 未知
    case existed
    case complete
}

public class Ls05sWatchFaceTransferManager {
    
    private struct Constant {
        static let endFlag = 0xFFFF
    }
    
    private var serialNo: Int = 0               //发送的编号
    
    private var timeoutTimer: Timer?
    
    private var binData: Data!                  // 需要升级的bin 文件
    private var splitDataBy4KArray: [Data] = [] //按 4 k 切分好的数据
    private var currentWriteData: Data?         //当前正在处理的 4k数据
    
    private let bag: DisposeBag = DisposeBag()
    
    public init(binData: Data) {
        self.binData = binData
        self.splitData(data: binData)
        
    }
    
    deinit {
        print("LsCloudWatchFaceTransfer05sManger init")
    }
    
    // 信号中转器，功能： 监听 cell 的点击，信号转发到外部
    typealias RouterAction = (
        progress: PublishRelay<DialUpgradeProcess>, ()
    )
    
    private let progressAction: RouterAction = (
        PublishRelay(), ()
    )
    
    typealias Routing = (
        event: Observable<DialUpgradeProcess>, ()
    )
    
    lazy var progressEvent: Routing = (
        event: progressAction.progress.asObservable(), ()
    )
    
    public func start() -> Observable<DialUpgradeProcess> {
        self.requestCloudWatchFaceTransfer()
        addObesver()
        return progressEvent.event
    }
    
    func requestCloudWatchFaceTransfer() {
        
        Ble05sOperator.shared.checkWatchFaceStatus(data: binData, type: .dial)
            .subscribe { [weak self](isCanUpgrade) in
                print("isCanUpgrade", isCanUpgrade)
                
                if isCanUpgrade {
                    self?.startCloudWatchFaceTransfer()
                }else {
                    self?.progressAction.progress.accept(.existed)
                }
                
            } onError: { [weak self](err) in
                self?.progressAction.progress.accept(.unknow)
            }.disposed(by: bag)
        
    }
    

    func startCloudWatchFaceTransfer() {
        guard self.splitDataBy4KArray.count > 0 else {
            self.progressAction.progress.accept(.dataerror)           // 传入的数据为空
            return
        }
        
        if serialNo == Constant.endFlag {
            self.progressAction.progress.accept(.complete)
            return
        }
        
        if serialNo >= splitDataBy4KArray.count - 1 {
            self.currentWriteData = self.splitDataBy4KArray.last
            self.serialNo = Constant.endFlag
        }else {
            self.currentWriteData = self.splitDataBy4KArray[self.serialNo]
        }
        
        
        self.writeBinData()
        
    }
    
    func continueNext4k() {
        self.invalidateTimeoutTimer()       // 继续发送，定时器作废
        
        self.startCloudWatchFaceTransfer()
    }
    
    
    func writeBinData() {
        
        let writeData = Ble05sSendDataConfig.shared.dialPB(sn: UInt32(serialNo), data: currentWriteData!)
        
        Ble05sOperator.shared.directWrite(writeData, 1)
                
        let progress: Float = Float(self.serialNo) / (Float(self.splitDataBy4KArray.count) )
        self.progressAction.progress.accept(.progress(progress > 1 ? 1 : progress))
        
    }
    
    private func addObesver() {
        guard let obser = BleOperator.shared.dataObserver else {
            return
        }
        obser.subscribe { [unowned self] (data) in
            
            guard let ls = data.ls,
               let cmds = ls.data["data"] as? hl_cmds,
               cmds.cmd == .cmdSetBinDataUpdate,
               cmds.rErrorCode.err == 0 else {
                
                self.serialNo += 1
                self.continueNext4k()
                
                return
    
            }
            
            print("升级失败")
            
        } onError: { (error) in
            print("error", error)
        }
        .disposed(by: bag)
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

extension Ls05sWatchFaceTransferManager {
    
    func addTimeoutTimer(timeOutInterval:TimeInterval, repeats: Bool,  timerBlock: @escaping (() -> Void)) {
        self.timeoutTimer = Timer.init(timeInterval: timeOutInterval, repeats: repeats, block: { (timer) in
            timerBlock()
        })
        RunLoop.current.add(self.timeoutTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func invalidateTimeoutTimer() {
        if self.timeoutTimer != nil {
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }
}
