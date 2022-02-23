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
    public var bleDevice: LsDeviceable? {
        didSet {
            self.dataObserver = bleDevice?.dataObserver
        }
    }
    
    var centralManager: CBCentralManager!
    
    public  var scaner: BluetoothScanable!
    var scanBuilder: BluetoothScanable.ScanBuilder?
    public  var connecter: BluetoothConnectable!
    var connectBuilder: BluetoothConnectable.ConnectBuilder?
    var isConnecting: Bool = false                  // 是否正在连接
    
    public var dataObserver: Observable<BleBackDataProtocol>?
    
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
            CBCentralManagerOptionRestoreIdentifierKey: "RESTORE_KEY",
            CBCentralManagerScanOptionAllowDuplicatesKey: false
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
                    self.bleDevice?.onException(.disConnect)
                }
            })
    }
    
    public func write(_ writeData: Data,
                      _ characteristic: Int = 0,
                      _ name: String,
                      _ duration: Int = 8,
                      _ endRecognition: (((Data) -> Bool)?) = nil)  -> Observable<BleResponse>  {
        
        return Observable.create { [weak self] (subscriber) -> Disposable in
            guard let `self` = self else {
                subscriber.onError(BleError.error("Released"))
                return Disposables.create()
            }
            
            guard self.centralManager.state == .poweredOn else {
                subscriber.onError(BleError.error("Bluetooth state error"))
                return Disposables.create()
            }
            
            guard let isConnected = self.bleDevice?.connected, isConnected else {
                subscriber.onError(BleError.error("Bluetooth not connect"))
                return Disposables.create()
            }
            
            
            _ = self.bleDevice?.write(data: writeData,characteristic: characteristic, name: name,  duration: duration, endRecognition: endRecognition)
                .subscribe(onNext: { (bleRes) in
                    subscriber.onNext(bleRes)
                }, onError: { (e) in
                    subscriber.onError(e)
                })
            
            return Disposables.create()
            
        }
    }
    
    public func directWrite(_ data: Data, _ type: WitheType) {
        self.bleDevice?.directWrite(data, type)
    }
    
    public func getPeripheralMaximumWriteValueLength() -> Int? {
        return self.bleDevice?.maximumWriteValueLength()
    }
    
    public func bluetoothOn() -> Bool {
        return self.centralManager.state == .poweredOn
    }
    
    public func bluetoothUnAuth() -> Bool {
        return self.centralManager.state == .unauthorized
    }
    
    public func deviceConnected() -> Bool {
        return self.bleDevice?.connected ?? false
    }
    
    public func readValue(channel: Channel) {
        self.bleDevice?.readValue(channel: channel)
    }
}

extension BleFacade: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        
    }
}
