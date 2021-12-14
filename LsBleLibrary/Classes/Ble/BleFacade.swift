//
//  BleFacade.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/19.
//  Copyright © 2020 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift


public enum BluetoothState : Int {
    case unknown = 0
    case resetting = 1
    case unsupported = 2
    case unauthorized = 3
    case poweredOff = 4
    case poweredOn = 5
    
}

public class BleFacade: NSObject, BleFacadeable {
    
    public static let shared: BleFacade = BleFacade()
    
    // 可选 有可能最开始不知道要连接某种设备
    public var bleDevice: Deviceable? {
        didSet {
            self.dataObserver02 = bleDevice?.dataObserver02
            self.dataObserver05s = bleDevice?.dataObserver05s
        }
    }
    
    var centralManager: CBCentralManager!
    
    public  var scaner: BluetoothScanable!
    var scanBuilder: BluetoothScanable.ScanBuilder?
    public  var connecter: BluetoothConnectable!
    var connectBuilder: BluetoothConnectable.ConnectBuilder?
    var isConnecting: Bool = false                  // 是否正在连接
    
    public var dataObserver02: Observable<UTEOriginalData>?
    public var dataObserver05s: Observable<LsBackData>?
    
    // 状态变化信号
    public typealias BluetoothEvent = (
        bluetoothState: PublishRelay<BluetoothState>,
        deviceDisconnect: PublishRelay<Void>
    )
    public let bleEvent: BluetoothEvent = (PublishRelay(), PublishRelay())
    
    public typealias Event = (bluetoothState: Observable<BluetoothState>,
                              deviceDisconnect: Observable<Void>)
    
    public lazy var event: Event = (bluetoothState: bleEvent.bluetoothState.asObservable(),
                                    deviceDisconnect: bleEvent.deviceDisconnect.asObservable())
    
    public func configBuider(_ scanBuilder: @escaping BluetoothScanable.ScanBuilder,
                             _ connectBuilder: @escaping BluetoothConnectable.ConnectBuilder) {
        self.scanBuilder = scanBuilder
        self.connectBuilder = connectBuilder
    }
    
    public func configDeviceInfo(_ config: BleScanDeviceConfig) {
        self.scaner = self.scanBuilder?((
            centralManager: self.centralManager,
            scanInfo: (
                services: config.services,
                deviceCategory: config.deviceCategory,
                deviceType: config.deviceType
            )
        ))
        
    }
    
    
    public func configConnectDeviceInfo(_ config: BleConnectDeviceConfig) {
        var connectInfo : (String,  String?)?
        if config.connectName != nil {
            connectInfo = (config.connectName!, config.deviceMacAddress)
        }
        self.connecter = self.connectBuilder?((
            centralManager: self.centralManager,
            scaner: scaner,
            connectInfo: connectInfo
        ))
    }
    
    private override init() {
        super.init()
        
        let options = [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBCentralManagerOptionRestoreIdentifierKey: "RESTORE_KEY"
        ] as [String: Any]
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil, options: options)
        
        _ = self.centralManager.rx.didDisconnectPeripheral
            .subscribe(onNext: {
                if self.bleDevice == nil {
                    return
                }
                guard $0.peripheral == self.bleDevice?.peripheral else {
                    return
                }
                self.bleEvent.deviceDisconnect.accept(())
                print("设备被断开...")
                self.bleDevice?.onException(.disConnect)
            })
        
        _ = self.centralManager.rx.didUpdateState
            .subscribe(onNext: {
                if $0 == .poweredOn {
                    self.bleEvent.bluetoothState.accept(BluetoothState(rawValue: 5)!)
                    print("蓝牙开关已打开")
                } else if($0 == .poweredOff) {
                    self.bleEvent.bluetoothState.accept(BluetoothState(rawValue: 4)!)
                    print("蓝牙开关已关闭")
                    self.bleDevice?.onException(.powerOff)
                }
            })
    }
    
    public func write(_ writeData: Data,
                      _ name: String,
                      _ duration: Int = 8,
                      _ endRecognition: (((Data) -> Bool)?) = nil)  -> Observable<BleResponse>  {
        return self.write(writeData, name, duration, 1, false, false, endRecognition)
    }
    
    
    /**
     App -> Device :  app 发送数据到设备， 如果设备未连接， 会尝试连接
     */
    public func write(_ writeData: Data,
                      _ name: String,
                      _ duration: Int = 8,
                      //               _ characteristic: CBCharacteristic? = nil,
                      _ expectNum: Int = 1,
                      _ ackInInterval: Bool = false,
                      _ endBySelf: Bool? = false,
                      _ endRecognition: ((Data) -> Bool)? = nil)  -> Observable<BleResponse> {
        
        return Observable.create { [weak self] (subscriber) -> Disposable in
            guard let `self` = self else {
                subscriber.onError(BleError.error("Released"))
                return Disposables.create()
            }
            
            guard self.centralManager.state == .poweredOn else {
                subscriber.onError(BleError.error("Bluetooth state error"))
                return Disposables.create()
            }
            
            if self.bleDevice?.connected ?? false  {
                
                _ = self.bleDevice?.write( data: writeData, name: name, expectNum: expectNum, duration: duration, ackInInterval: ackInInterval, endBySelf: endBySelf, trigger: true, endRecognition: endRecognition)
                    .subscribe(onNext: { (bleRes) in
                        subscriber.onNext(bleRes)
                    }, onError: { (e) in
                        subscriber.onError(e)
                    })
                
                return Disposables.create()
                
            }
            // 未连接 先放入队列， 不尝试发送
            _ = self.bleDevice?.write(data: writeData, name: name, expectNum: expectNum, duration: duration, ackInInterval: ackInInterval,  endBySelf: endBySelf, trigger: false, endRecognition: endRecognition)
                .subscribe(onNext: { (bleRes) in
                    subscriber.onNext(bleRes)
                }, onError: { (e) in
                    subscriber.onError(e)
                })
            
            if !self.isConnecting {
                self.isConnecting = true
                _ = self.connecter.connect(duration: duration)
                    .do(onNext: { (state, response) in
                        if state == .connectSuccessed {
                            print("只连接不知道具体特征")
                            guard let p = response?.peripheral else {
                                return
                            }
                            self.bleDevice?.peripheral = p
                        } else if (state == .dicoverChar) {
                            self.bleDevice?.updateCharacteristic(characteristic: response?.characteristics, statusCallback: nil)
                            // 到连接步骤， bleDevice 类型，必然已经知道，可以强解
                            if self.bleDevice?.connected ?? false {
                                print("现在，已经连接而且知道具体特征, 并且发送数据")
                                BleFacade.shared.connecter.finish()
                                
                                self.isConnecting = false
                            }
                        } else if (state == .timeOut) {
                            print("连接超时")
                            subscriber.onError(BleError.timeout)
                            self.isConnecting = false
                            self.bleDevice?.onException(.timeout)
                        }
                        
                    }, onError: { (error) in
                        subscriber.onError(error)
                        self.isConnecting = false
                        self.bleDevice?.onException(BleError.error(error.localizedDescription))
                    })
                        .subscribe()
                        }
            
            return Disposables.create()
        }
    }
    
    public func directWrite(_ data: Data, _ type: Int) {
        self.bleDevice?.directWrite(data, type)
    }
    
    func getPeripheralMaximumWriteValueLength() -> Int? {
        return self.bleDevice?.maximumWriteValueLength()
    }
    
    func bluetoothOn() -> Bool {
        return self.centralManager.state == .poweredOn
    }
    
    func bluetoothUnAuth() -> Bool {
        return self.centralManager.state == .unauthorized
    }
    
    public func deviceConnected() -> Bool {
        return self.bleDevice?.connected ?? false
    }
    
    public func readValue(type: Int) {
        self.bleDevice?.readValue(type)
    }
}

extension BleFacade: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        
    }
}
