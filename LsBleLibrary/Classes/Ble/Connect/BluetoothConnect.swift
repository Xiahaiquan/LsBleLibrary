//
//  BluetoothConnect.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/12.
//  Copyright © 2020 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

public enum ConnectState: Int {
    case connectSuccessed
    case connectComplete
    case connectFailed
    case disConect
    case dicoverChar
    case timeOut
    case powerOn
}

enum ConnectError: Error {
    case error(messae: String, _ state: BluetoothState? = .unknown)
}

/*
 连接设备返回结果， 外设对象 和 特征值
 */

public class ConnectResponse {
    public var peripheral: CBPeripheral
    
    public var characteristics: [CBCharacteristic]?
    
    public init(peripheral: CBPeripheral, characteristics: [CBCharacteristic]? = nil) {
        self.peripheral = peripheral
        self.characteristics = characteristics
    }
}

/*
 连接设接口
 需要参数 1： CentralManager 通常全局统一， 2 ：扫描器  3: 连接信息
 connect： 连接设备， 并指定超时时间。
 finish: 外部可以主动停止连接过程
 */
public protocol BluetoothConnectable {
    
    var centralManager : CBCentralManager { get }
    var scaner : BluetoothScanable { get }
    var connectInfo: (connectDevice: String,  macAddress: String?)? { get }
    
    var peripherals: [CBPeripheral] { get set}
    
    typealias Input = (
        centralManager: CBCentralManager,
        scaner: BluetoothScanable,
        connectInfo: (connectDevice: String,  macAddress: String?)?
    )
    
    typealias ConnectBuilder = (BluetoothConnectable.Input) -> BluetoothConnectable
    
    func connect(duration: Int?) -> Observable<(state: ConnectState, response: ConnectResponse?)>            // 如不想用 响应式 方式， 可以定义block 方式接口

    func finish()
}

/*
 连接实现类
 */
public class BluetoothConnect: BluetoothConnectable {
    
    public var peripherals: [CBPeripheral] = []
    public var centralManager: CBCentralManager
    public var connectInfo: (connectDevice: String,  macAddress: String?)?
    public var scaner: BluetoothScanable
    public var connectTimer: Timer?
    
    public init(centralManager: CBCentralManager,
                connectInfo: (connectDevice: String,  macAddress: String?)?,
                scaner: BluetoothScanable) {
        self.centralManager = centralManager
        self.connectInfo = connectInfo
        self.scaner = scaner
    }
    
    // 信号管理
    var disposeBag: DisposeBag!
    
    public func connect(duration: Int?) -> Observable<(state: ConnectState, response: ConnectResponse?)> {
        return Observable.create { [centralManager, connectInfo, scaner] (subscriber) -> Disposable in
            
            guard centralManager.state == .poweredOn else {
                subscriber.onError(ConnectError.error(messae: "Bluetooth state error", BluetoothState(rawValue: centralManager.state.rawValue)))
                return Disposables.create()
            }
            
            guard let connectInfo = connectInfo else {
                subscriber.onError(ConnectError.error(messae: "Connection information is missing", BluetoothState(rawValue: centralManager.state.rawValue)))
                return Disposables.create()
            }
            
            if duration != nil {
                self.connectTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration!), repeats: false, block: { (_) in
                    centralManager.stopScan()
                    subscriber.onNext((state: .timeOut, response: nil))
                    subscriber.onCompleted()
                })
            }
            
            _ = scaner.scan(duration: duration)
                .filter({
                    $0.state == .nomal
                })
                .filter({
                    $0.response != nil
                })
                .filter({
                    $0.response?.filter({
                        $0.peripheral.name?.hasPrefix(connectInfo.connectDevice) ?? false               // 匹配设备前缀
                    }).count ?? 0 > 0
                })
                .filter({
                    // 连接时如没有提供mac 地址
                    if connectInfo.macAddress == nil {
                        return true
                    }
                    
                    // 如有提供mac 地址 过滤掉不符合的
                    if let macaddress = connectInfo.macAddress {
                        
                        return $0.response?.filter({
                            
                            if $0.advertisementData == nil,  $0.peripheral.identifier.uuidString == BleDeviceArchiveModel.get()?.uuid {
                                return true
                            }
                            
                            guard let advData = $0.advertisementData, let sd = advData[CBAdvertisementDataManufacturerDataKey] as? Data else {
                                return false
                            }
                            let macAddressData = [UInt8](sd)
                            let macAddressHex = macAddressData.hexString.lowercased()
                            //                            print("scaned uuid: \($0.peripheral.identifier.uuidString), mac: \(macAddressHex)")
                            return macAddressHex.hasSuffix(macaddress.lowercased())
                        })
                            .count ?? 0 > 0
                    }
                    return false
                })
                .subscribe(onNext: { (state, response) in
                    if let scanPeripheral = response!.filter({
                        ($0.peripheral.name?.hasPrefix(connectInfo.connectDevice) ?? false)
                    })
                        .first?.peripheral {
                        self.disposeBag = DisposeBag()
                        self.subscribeCentralManagerObservable(subscriber)          // 扫描到设备， 订阅相关信号
                        self.subscribeDiscoverCharacteristicsObservable(scanPeripheral, subscriber)
                        self.peripherals.append(scanPeripheral)
                        centralManager.connect(scanPeripheral, options: nil)        // 发起连接
                    }
                    self.finish()
                }, onError: { error in
                    subscriber.onError(error)
                })
            return Disposables.create()
        }
    }
    public func directConnect() {
        
    }
    //MARK: 订阅 找到设备广播特征
    func subscribeDiscoverCharacteristicsObservable(_ scanPeripheral: CBPeripheral, _ subscriber: RxSwift.AnyObserver<(state: ConnectState, response: ConnectResponse?)>) {
        _ = scanPeripheral.rx.didDiscoverCharacteristics
            .subscribe(onNext: { (p, s, c) in
                subscriber.onNext((state: .dicoverChar, response: ConnectResponse(peripheral: p, characteristics: c)))
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: 订阅 连接成功、连接失败、 断开连接 特征
    func subscribeCentralManagerObservable(_ subscriber: RxSwift.AnyObserver<(state: ConnectState, response: ConnectResponse?)>) {
        _ = centralManager.rx.didConectPeripheral
            .map({ ConnectResponse(peripheral: $0.peripheral) })
            .subscribe(onNext: {
                subscriber.onNext((state: .connectSuccessed, response: $0))
                $0.peripheral.discoverServices(nil)           // 查找所有服务
            })
            .disposed(by: disposeBag)
        
        _ = centralManager.rx.didFailToConnectPeripheral
            .map({ ConnectResponse(peripheral: $0.peripheral) })
            .subscribe(onNext: {
                subscriber.onNext((state: .connectFailed, response: $0))
            })
            .disposed(by: disposeBag)
        
        _ = centralManager.rx.didDisconnectPeripheral
            .map({ ConnectResponse(peripheral: $0.peripheral) })
            .subscribe(onNext: {
                subscriber.onNext((state: .disConect, response: $0))
            })
            .disposed(by: disposeBag)
    }
    
    public func finish() {
        self.centralManager.stopScan()
        self.connectTimer?.invalidate()
        self.connectTimer = nil
    }
}
