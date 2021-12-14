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

public class Ls05sDevice: NSObject, Deviceable {
    
    public var dataObserver05s: Observable<LsBackData>?
    
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
    
    var continueToAccept: Bool = true
    
    lazy private var dataObserverPublishRelay: PublishRelay<LsBackData> = PublishRelay()
    
    public override init() {
        super.init()
        
        self.dataObserver05s = self.dataObserverPublishRelay.asObservable()
    }
    
    
    public var peripheral: CBPeripheral? {
        didSet {
            // 避免多次订阅
            guard oldValue != peripheral else {
                return
            }
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
                    
//                    print("back data：\(acceptData.count)")
                    
                    let acceptBytes = [UInt8](acceptData)
                    
                    
                    if acceptBytes.count > 1 && acceptBytes[0] == 0x66 && acceptBytes[1] == 0x77 {
                        printLog("receive ack data")
                        return
                    }
                    
                    let parserState = self.parser.accept(data: acceptData)
                    if parserState == .dataEnd || parserState == .dataItemEnd || parserState == .pbDataNotMatch {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) {
                            self.responseAck()
                        }
                    }
                    
                    if parserState != .dataItemEnd { return }
                    
                    guard let cmds = self.parser.receiveArray.first else {
                        return
                    }
                                        
                    if self.parser.bigDataParserState == .invalid {
                        //读取的
                        print("一般的数据")
                        self.callbackData(cmd: cmds)
                        self.parser.resetAcceptancePackage()
                        
                        return
                    }
                    
                    if self.parser.bigDataParserState == .start {
                        print("开始收大数据")
                        return
                    }
                    
                    if self.parser.bigDataParserState == .end {
                        print("大数据接收完成")
                        if !self.parser.bigDataItems.isEmpty {
                            self.callbackBigData(cmd: cmds, data: self.parser.bigDataItems)
                        }else if self.parser.bigSportDataItems.isEmpty {
                            self.callbackBigData(cmd: cmds, data: self.parser.bigSportDataItems)

                        }else {
                            //运动完后主动上报的
                            self.callbackData(cmd: cmds)
                        }
                        
                        self.parser.resetAcceptancePackage()
                        
                        return
                    }
                    
                    
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
            let uuid = c.uuid.uuidString
            var uuidHeader = uuid
            if uuid.count > 10 {
                let startIndex = uuid.index(uuid.startIndex, offsetBy: 2)
                let endIndex = uuid.index(uuid.startIndex, offsetBy: 6)
                uuidHeader = String(uuid[startIndex..<endIndex])
            }
//            print("识别到UUID: \(uuidHeader)")
            switch uuidHeader {
            case "0002":
                self.char0002 = c
            case "0003":
                self.char0003 = c
                self.peripheral?.setNotifyValue(true, for: c)
            case "0004":
                self.char0004 = c
            case "0005":
                self.char0005 = c
                self.peripheral?.setNotifyValue(true, for: c)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  statusCallback?(true)  }
            default:
                break
//                print("\(c.uuid.uuidString) 此特征不属于该对象")
            }
        }
    }
    
    
    
    public func write(data: Data, name: String, expectNum: Int?, duration: Int?, ackInInterval: Bool?, endBySelf: Bool?, trigger: Bool, endRecognition: (((Data) -> Bool)?) = nil) -> Observable<BleResponse> {
        
        guard let p = self.peripheral, let c = self.char0002 else {
            return Observable.error(BleError.disConnect)
            
        }
    
        return Observable.create { (subscriber) -> Disposable in
            
            let dataArr = Ble05sCmdsConfig.shared.chunked(data: data, chunkSize: 180)
            
            let operation = BLEOperation.init(dataArr: dataArr, peripheral: p, characteristic: c, name: name, observer: subscriber, timeoutTimeInterval: TimeInterval(duration!))
            
            QueueManager.shared.enqueueToQueue(operation)
            
            return Disposables.create()
        }
    }
    
}
extension Ls05sDevice {
    func responseAck() {
        let ackBytes : [UInt8] = [0x66, 0x77, 0x00, 0x00, 0x00, 0x00, 0x00]
        let ackData = Data.init(bytes: ackBytes, count: ackBytes.count)
        print("send ack to fw, \(ackBytes.hexString))")
        self.peripheral!.writeValue(ackData, for: self.char0004!, type: .withResponse)
    }
}
extension Ls05sDevice {
    
    func clearCharacteristic() {
        self.char0002 = nil
        self.char0003 = nil
        self.char0004 = nil
        self.char0005 = nil
    }
    func onException(_ error: BleError) -> Void {
        QueueManager.shared.syncDataQueue.cancelAllOperations()
    }
    public func directWrite(_ data: Data, _ type: Int) {
        
        guard let p = self.peripheral, let c = self.char0002, self.connected == true else {
            return
        }
        
        let dataArr = Ble05sCmdsConfig.shared.chunked(data: data, chunkSize: 180)
        for data in dataArr {
            print("send data:", data.desc())
            p.writeValue(data, for: c, type: CBCharacteristicWriteType.init(rawValue: type) ?? .withoutResponse)
        }
        
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
        
//        print("callbackData", cmd)
        
        var data = [String: Any]()
        switch cmd.cmd {
        case .cmdSetFindPhone:
            data["status"] = RingStatus.init(rawValue: cmd.rFindPhone.mRingStatus)
        case .cmdDisturbSwitch:
            data["status"] = DisturbSwitchStatus.init(rawValue:cmd.rGetDisturbEn.mDisturbEn)
        case .cmdBindDevice:
            data["status"] = LsBleBindState.init(rawValue:Int(cmd.rBindDevice.mBindOperate))
        case .cmdGetUiHrsValue:
            data["data"] = CurrentUIHR.init(act:cmd.rGetUiHrs.mUiActHr,
                                            max:cmd.rGetUiHrs.mUiMaxHr,
                                            min:cmd.rGetUiHrs.mUiMinHr)
        case .cmdGetActiveRecordData:
            let activeRecord = cmd.rGetActiveRecord
            
            let startTime =  activeRecord.mActiveStartSecond
            data["status"] = SportModelItem.init(sportModel: .badminton, heartRateNum: 1, startTime: "", endTime: "", step: Int(activeRecord.mActiveStep), count: 0, cal: Int(activeRecord.mActiveCalories), distance: activeRecord.mActiveDistance.description, hrAvg: Int(activeRecord.mActiveAvgHr), hrMax: Int(activeRecord.mActiveMaxHr), hrMin: Int(activeRecord.mActiveMinHr), pace: Int(activeRecord.mActiveSpeed), hrInterval: Int(activeRecord.mActiveHrCount), heartRateData: Data())
        default:  break
        }
        
        
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == cmd.cmd.name
        }) as? BLEOperation else {
            data["data"] = cmd
            self.dataObserverPublishRelay.accept((type: LsBackDataTypeEnum.init(rawValue: cmd.cmd.rawValue)!, data: data))
            return
        }
        let lsBackDataTypeEnum = LsBackDataTypeEnum.init(rawValue: cmd.cmd.rawValue)!
        if lsBackDataTypeEnum != .invalid {
            operation.observer?.onNext(.init(backData: (type: lsBackDataTypeEnum, data: data)))
        }else {
            operation.observer?.onNext(.init(pbDatas: [cmd]))
        }
        
        if cmd.cmd == .cmdBindDevice {
            if cmd.rBindDevice.mBindOperate == 1 {
                operation.finish()
            }
        }else {
            operation.finish()
        }
    }
    
    func callbackBigData(cmd: hl_cmds, data: [BigDataProtocol]) {
        
        print("all big data finisn",data.count)
        
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == cmd.cmd.name
        }) as? BLEOperation else {
            return
        }
        
        operation.observer?.onNext(.init(item: data))
        operation.finish()
        
    }
    
    func callbackBigData(cmd: hl_cmds, data: [SportModelItem]) {
        
        print("all big data finisn",data.count)
        
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == cmd.cmd.name
        }) as? BLEOperation else {
            return
        }
        
        operation.observer?.onNext(.init(sprotItems: data))
        operation.finish()
        
        
    }
    

}

