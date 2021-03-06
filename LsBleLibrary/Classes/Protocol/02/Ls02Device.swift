//
//  Ls02Device.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/2/7.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

public class Ls02Device: NSObject, LsDeviceable {
    
    var char6001: CBCharacteristic?
    var char6002: CBCharacteristic?
    
    var char6101: CBCharacteristic?
    var char6102: CBCharacteristic?
    
    var char33f1: CBCharacteristic?
    
    // 只有状态为 连接 并且 所有的特征通道都正常
    public var connected: Bool {
        guard self.peripheral?.state == .connected,
              let _ = self.char6001,
              let _ = self.char6002,
              let _ = self.char6101,
              let _ = self.char6102,
              let _ = self.char33f1
        else {
            return false
        }
        return true
    }
    
    var timeoutTimer: Timer?
    
    var bag: DisposeBag = DisposeBag()
    
    public var dataObserver: Observable<BleBackDataProtocol>?
    
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
                    guard let acceptData = characteristic.value else {
                        return
                    }
                    print("from: \(characteristic.uuid.uuidString) === values : \(acceptData.desc())")
                    
                    guard let `self` = self, error == nil else {
                        return
                    }
                    
                    guard let operation = QueueManager.shared.syncDataQueue.operations.first as? BleOperation else {
                        //                        let sss = UTEOriginalData.init(from: characteristic.uuid.uuidString, data: acceptData)
                        self.dataObserverPublishRelay.accept(UTEOriginalData.init(from: characteristic.uuid.uuidString, data: acceptData))
                        return
                    }
                    
                    // 校验 如与发送数据不匹配 过滤
                    guard operation.ble02Parser?.validate(acceptData) == true else {
                        self.dataObserverPublishRelay.accept(UTEOriginalData.init(from: characteristic.uuid.uuidString, data: acceptData))
                        return
                    }
                    
                    if operation.endRecognition != nil {
                        operation.observer?.onNext(.init(datas: [acceptData]))
                        
                        let operateEnd = operation.endRecognition!(acceptData)
                        
                        if operateEnd {
                            operation.finish()
                        }
                    } else {
                        
                        operation.ble02Parser?.accept(data: acceptData)
                        
                        if let datas = operation.ble02Parser?.receiveArray {
                            operation.observer?.onNext(.init(datas: datas))
                        }
                        operation.finish()
                        
                    }
                })
                .disposed(by: bag)
        
        }
    }
    
    /*
     更新设备特征通道， 并设置 notify
     */
    public func updateCharacteristic(characteristic: [CBCharacteristic]?, statusCallback: ((Bool) ->Void)?)  {
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
                        print("header: \(uuidHeader)")
            
            switch uuidHeader {
            case "6001":
                self.char6001 = c
            case "6002":
                self.char6002 = c
                self.peripheral?.setNotifyValue(true, for: c)
            case "6101":
                self.char6101 = c
            case "6102":
                self.char6102 = c
                self.peripheral?.setNotifyValue(true, for: c)
            case "33F1":
                self.char33f1 = c
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {  statusCallback?(true)  }
            default:
                break
            }
        }
        
    }
    
    public func write(data: Data, characteristic: Int, name: String, duration: Int?, endRecognition: ((Data) -> Bool)? = nil) -> Observable<BleResponse> {
        
        guard let p = self.peripheral else {
            return Observable.error(BleError.disConnect)
            
        }
        
        var char: CBCharacteristic!
        if characteristic == 0,  self.char6001 != nil {
            char = char6001!
        }else if characteristic == 6101 {
            char = char6101!
        }
        
        return Observable.create { [unowned  self] (subscriber) -> Disposable in
            //一般数据的传输默认就20个byte 在传输表盘等大数据是，才用大于20的mtu
            let dataArr = Ble05sCmdsConfig.shared.chunked(data: data, chunkSize: 20)
            
            let parser = Ble02Parser(writeData: data)
            
            let operation = BleOperation.init(dataArr: dataArr, peripheral: p, characteristic: char, name: name, endRecognition:endRecognition,ble02Parser: parser, observer: subscriber, timeoutTimeInterval: TimeInterval(duration!))
            
            QueueManager.shared.enqueueToQueue(operation)
            
            return Disposables.create()
        }
    }
}

extension Ls02Device {
    
    func clearCharacteristic() {
        self.char6001 = nil
        self.char6002 = nil
        self.char6101 = nil
        self.char6002 = nil
    }
    
    public func readValue(channel: Channel) {
        guard let p = self.peripheral, self.connected == true else {
            return
        }
        if channel == .ute6001 {
            p.readValue(for: self.char6001!)
        } else if channel == .ute6101 {
            p.readValue(for: self.char6101!)
        } else if channel == .ute33F1 {
            p.readValue(for: self.char33f1!)
        }
    }
    
    public func onException(_ error: BleError) -> Void {
        QueueManager.shared.syncDataQueue.cancelAllOperations()
    }
    
    public func directWrite(_ data: Data, _ type: WitheType) {
        guard let p = self.peripheral, let c = self.char6101, self.connected == true else {
            return
        }
        print("directWrite", data.bytes.hexString)
        
        DispatchQueue.global().async { [self] in
            p.writeValue(data, for: c, type: .withoutResponse)
        }
        
    }
}

extension Ls02Device {
    public func addTimeoutTimer(timeOutInterval:TimeInterval, repeats: Bool,  timerBlock: @escaping (() -> Void)) {
        self.timeoutTimer = Timer.init(timeInterval: timeOutInterval, repeats: repeats, block: { (timer) in
            timerBlock()
        })
        //        RunLoop.current.add(self.timeoutTimer!, forMode: RunLoop.Mode.common)
    }
    
    public func invalidateTimeoutTimer() {
        if self.timeoutTimer != nil {
            self.timeoutTimer?.invalidate()
            self.timeoutTimer = nil
        }
    }
}

extension Ls02Device {
    func routerData(_ routerData: (from: String, data: Data)) {
        
        
        let data = routerData.data
        let acceptBytes = [UInt8](data)
        
        
        let command = LS02CommandType.init(rawValue: acceptBytes[0])
        
        guard let operation = QueueManager.shared.syncDataQueue.operations.first(where: { (op) -> Bool in
            return op.name == command?.name
        }) as? BleOperation else {
            
            self.dataObserverPublishRelay.accept(UTEOriginalData.init(from: routerData.from, data: routerData.data))
            return
        }
        
        switch command {
            
        case .bindingWatch:
            let bindState = LsBleBindState.init(uteType: Int(acceptBytes[2]))
            
            operation.observer?.onNext(.init(uteData: bindState))
            
            if bindState == .success {
                operation.finish()
            }
            
        default:
            print("有未知命令的数据")
        }
        
    }
}

extension Ls02Device {
    public var deviceCategory: LSDeviceCategory {
        return .Watch
    }
    
    public var watchType: LSSportWatchType {
        return .LS02
    }
    
    public var watchSeries: LSSportWatchSeries {
        return .UTE
    }
}

