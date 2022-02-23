//
//  Ls05sDevice.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/2.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

/*
 具体外设类 （可能有很多不同的设备， 通道都不一样）
 */

public class Ls05sDevice: NSObject, LsDeviceable {
    
    private struct Characteristic {
        static let mainChar = "000001FF-3C17-D293-8E48-14FE2E4DA212"
        static let sendDataChar = "000002FF-3C17-D293-8E48-14FE2E4DA212"
        static let receiveAckChar = "000003FF-3C17-D293-8E48-14FE2E4DA212"
        static let sendAckChar = "000004FF-3C17-D293-8E48-14FE2E4DA212"
        static let receiveDataChar = "000005FF-3C17-D293-8E48-14FE2E4DA212"
    }
    
    public var dataObserver: Observable<BleBackDataProtocol>?
    
    var char0002: CBCharacteristic?
    var char0003: CBCharacteristic?
    var char0004: CBCharacteristic?
    var char0005: CBCharacteristic?
    
    // 只有状态为 连接 并且 所有的特征通道都正常
    public var connected: Bool {
        guard self.peripheral?.state == .connected,
              let _ = self.char0002,
              let _ = self.char0003,
              let _ = self.char0004,
              let _ = self.char0005
        else {
            return false
        }
        return true
    }
    
    var timeoutTimer: Timer?
    
    // 设备返回数据解析器
    var parser: Ble05sParser = Ble05sParser()
    
    var bag: DisposeBag = DisposeBag()
    
    var receiveTimer: Timer?
    var isDataTransmission = false
    
    lazy private var dataObserverPublishRelay: PublishRelay<BleBackDataProtocol> = PublishRelay()
    
    public override init() {
        super.init()
        
        self.dataObserver = self.dataObserverPublishRelay.asObservable()
    }
    
    
    public var peripheral: CBPeripheral? {
        didSet {
            // 避免多次订阅
            guard oldValue != peripheral else {
                return
            }
            
            QueueManager.shared.addObserver()
            
            // 监听 外设 返回的数据
            peripheral?.rx.didUpdateValue
                .subscribe(onNext: { [weak self] (p, characteristic, error) in
                    // 被释放过滤
                    guard let `self` = self else {
                        return
                    }
                    // 出错过滤
                    guard error == nil else {
                        return
                    }
                    guard self.peripheral == p else {
                        printLog("收到不是本外设对象数据 过滤")
                        return
                    }
                    // 数据错误过滤
                    guard let acceptData = characteristic.value else {
                        printLog("收到的数据异常")
                        return
                    }
                    
                    print("back data", acceptData.desc())
                    
                    let acceptBytes = [UInt8](acceptData)
                    
                    
                    if acceptBytes.count > 1 && acceptBytes[0] == 0x66 && acceptBytes[1] == 0x77 {
                        printLog("receive ack data")
                        return
                    }
                    
                    let parserState = self.parser.accept(data: acceptData)
                    if parserState == .dataEnd || parserState == .dataItemEnd || parserState == .pbDataNotMatch {
                        self.responseAck()
                    }
                    
                    if parserState != .dataItemEnd { return }
                    
                    guard let cmds = self.parser.receiveArray.first else {
                        return
                    }
                    
                    if self.parser.bigDataParserState == .invalid {
                        //读取的
//                        print("一般的数据")
                        self.callbackData(cmd: cmds)
                        self.parser.resetAcceptancePackage()
                        
                        return
                    }
                    
                    if self.parser.bigDataParserState == .start {
                        print("开始收大数据")
                        self.isDataTransmission = true
                        self.startReceiveTimer()
                        return
                    }
                    
                    if self.parser.bigDataParserState == .end {
                        
                        self.isDataTransmission = true
                        
                        self.invalidateReceiveTimer()
                        print("大数据接收完成")
                        if self.parser.dataType == .historicalData {
                            self.callbackBigData(cmd: cmds, data: self.parser.bigDataItems)
                        }else if self.parser.dataType == .sportData {
                            self.callbackBigData(cmd: cmds, data: self.parser.bigSportDataItems)
                        }else {
                            //运动完后主动上报的
                            self.callbackData(cmd: cmds)
                        }
                        
                        self.parser.resetAcceptancePackage()
                        
                        return
                    }
                    
                    if self.parser.bigDataParserState == .dataContinue {
                        self.isDataTransmission = true
                    }
                    
                    
                }, onError: { e in
                    print(e, "didUpdateValue.err")
                })
                .disposed(by: bag)
            
            peripheral?.rx.didUpdateNotification.subscribe(onNext: { (p, d, e) in
                print("isNotifying", d.isNotifying, "error", e)
            }, onError: { e in
                print(e, "didUpdateNotification.err")
            })
                .disposed(by: bag)
        }
    }
    
    /// 更新设备特征通道， 并设置 notify
    /// - Parameter characteristic: <#characteristic description#>
    /// - Returns: 设备是否连接完成
    public func updateCharacteristic(characteristic: [CBCharacteristic]?, statusCallback: ((Bool) ->Void)?) {
        guard let chars = characteristic else {
            return
        }
        
        chars.forEach { (c) in
            
            switch c.uuid.uuidString {
                
            case Characteristic.sendDataChar:
                self.char0002 = c
            case Characteristic.receiveAckChar:
                self.char0003 = c
                self.peripheral?.setNotifyValue(true, for: c)
            case Characteristic.sendAckChar:
                self.char0004 = c
            case Characteristic.receiveDataChar:
                self.char0005 = c
                self.peripheral?.setNotifyValue(true, for: c)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {  statusCallback?(true)  }
            default:
                break
                //                print("\(c.uuid.uuidString) 此特征不属于该对象")
            }
        }
        
    }
    
    public func write(data: Data, characteristic: Int, name: String, duration: Int?, endRecognition: (((Data) -> Bool)?) = nil) -> Observable<BleResponse> {
        
        guard let p = self.peripheral, let c = self.char0002 else {
            return Observable.error(BleError.disConnect)
            
        }
        
        return Observable.create { [unowned self] (subscriber) -> Disposable in
            
            let dataArr = Ble05sCmdsConfig.shared.chunked(data: data, chunkSize: mtu)
            
            let operation = BleOperation.init(dataArr: dataArr, peripheral: p, characteristic: c, name: name, observer: subscriber, timeoutTimeInterval: TimeInterval(duration!))
            
            QueueManager.shared.enqueueToQueue(operation)
            
            return Disposables.create()
        }
    }
    
}
//MARK: - 接收定时器
extension Ls05sDevice {
    
    func startReceiveTimer() {
        //This action not in main thread
        
        invalidateReceiveTimer()
        
        receiveTimer = Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(receiveTimerTick), userInfo: nil, repeats: true)
        
    }
    
    @objc func receiveTimerTick() {
        
        printLog("")
        if !self.isDataTransmission {
            
            if let operation = QueueManager.shared.syncDataQueue.operations.first as? BleOperation {
                operation.observer?.onNext(.init(writeError: WriteError.error(messae: "No big data in 10 seconds")))
                printLog("Finish curernt operation")
                operation.finish()
            }
            invalidateReceiveTimer()
            parser.resetAcceptancePackage()
        }
        
        isDataTransmission = false
        
    }
    
    func invalidateReceiveTimer() {
        printLog("")
        receiveTimer?.invalidate()
        receiveTimer = nil
    }
    
}


extension Ls05sDevice {
    func responseAck() {
        
        guard let characteristic = self.char0004 else {
            return
        }
        
        let ackBytes : [UInt8] = [0x66, 0x77, 0x00, 0x00, 0x00, 0x00, 0x00]
        let ackData = Data.init(bytes: ackBytes, count: ackBytes.count)
        print("send ack to fw, \(ackBytes.hexString))")
        self.peripheral!.writeValue(ackData, for: characteristic, type: .withResponse)
    }
}
extension Ls05sDevice {
    
    func clearCharacteristic() {
        self.char0002 = nil
        self.char0003 = nil
        self.char0004 = nil
        self.char0005 = nil
    }
    public func onException(_ error: BleError) -> Void {
        QueueManager.shared.syncDataQueue.cancelAllOperations()
    }
    public func directWrite(_ data: Data, _ type: WitheType) {
        
        guard let p = self.peripheral, let c = self.char0002, self.connected == true else {
            return
        }
        
        let dataArr = Ble05sCmdsConfig.shared.chunked(data: data, chunkSize: mtu)
        for data in dataArr {
            print("direct send data:", data.desc())
            p.writeValue(data, for: c, type: CBCharacteristicWriteType.init(rawValue: type.rawValue) ?? .withoutResponse)
        }
        
    }
    
    public func readValue(channel: Channel) {
        
    }
}

extension Ls05sDevice {
    public var deviceCategory: LSDeviceCategory {
        return .Watch
    }
    
    public var watchType: LSSportWatchType {
        return .LS05S
    }
    
    public var watchSeries: LSSportWatchSeries {
        return .LS
    }
}
extension Ls05sDevice {
    
    func callbackData(cmd: hl_cmds) {
        
        print("一般的数据")
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == cmd.cmd.name
        }) as? BleOperation else {
            
            self.dataObserverPublishRelay.accept(cmd)
            return
        }
        
        operation.observer?.onNext(.init(pbDatas: [cmd]))
        
        
        if cmd.cmd == .cmdBindDevice {
            if cmd.rBindDevice.mBindOperate == 1 {
                operation.finish()
            }
        }else {
            operation.finish()
        }
    }
    
    func callbackBigData(cmd: hl_cmds, data: [BigDataProtocol]) {
        
        print("历史数据",data.count)
        
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == cmd.cmd.name
        }) as? BleOperation else {
            return
        }
        
        operation.observer?.onNext(.init(item: data))
        operation.finish()
        
    }
    
    func callbackBigData(cmd: hl_cmds, data: [SportModelItem]) {
        
        print("运动记录",data.count)
        
        let items = LSWorkoutItem.init(value: data)
        
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == cmd.cmd.name
        }) as? BleOperation else {
            self.dataObserverPublishRelay.accept(cmd)
            return
        }
        
        operation.observer?.onNext(.init(sprotItems: items))
        operation.finish()
        
    }
    
}

