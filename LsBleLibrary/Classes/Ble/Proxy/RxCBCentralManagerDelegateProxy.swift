//
//  RxCBCentralManagerDelegateProxy.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/11.
//  Copyright © 2020 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

class RxCBCentralManagerDelegateProxy: DelegateProxy<CBCentralManager, CBCentralManagerDelegate>, DelegateProxyType, CBCentralManagerDelegate {
    
    // 系统代理会掉时，用于发送信号， 任何想知道扫描结果的都可以订阅
    var didUpdateStateSubject = PublishSubject<CBManagerState>()
    var didDiscoverPeripheralSubject = PublishSubject<ScanResponse>()
    
    var didConnectPeripheralSubject = PublishSubject<ScanResponse>()
    var didFailToConnectPeripheralSubject = PublishSubject<ScanResponse>()
    var didDisconnectPeripheralSubject = PublishSubject<ScanResponse>()
    
    init(_ centerManager: CBCentralManager) {
        super.init(parentObject: centerManager, delegateProxy: RxCBCentralManagerDelegateProxy.self)
    }
    
    /// 注册代理的实现为 RxCBCentralManagerDelegateProxy 实例
    static func registerKnownImplementations() {
        self.register {
            RxCBCentralManagerDelegateProxy($0)
        }
    }
    
    static func currentDelegate(for object: CBCentralManager) -> CBCentralManagerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CBCentralManagerDelegate?, to object: CBCentralManager) {
        object.delegate = delegate
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        _forwardToDelegate?.centralManagerDidUpdateState(central)
        /// 当代理回调 蓝牙状态发生变化 发送信号给订阅者
        didUpdateStateSubject.onNext(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /// 当代理回调扫描到设备时发送信号给订阅者
        didDiscoverPeripheralSubject.onNext(ScanResponse(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        didConnectPeripheralSubject.onNext(ScanResponse(peripheral: peripheral))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        didFailToConnectPeripheralSubject.onNext(ScanResponse(peripheral: peripheral))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        didDisconnectPeripheralSubject.onNext(ScanResponse(peripheral: peripheral))
    }
}

/// CBCentralManager 扩展RX属性 
extension Reactive where Base: CBCentralManager {
    
     var delegate: DelegateProxy<CBCentralManager, CBCentralManagerDelegate> {
        return RxCBCentralManagerDelegateProxy.proxy(for: base)
    }
    
     var didUpdateState: Observable<CBManagerState> {
        return RxCBCentralManagerDelegateProxy.proxy(for: base)
            .didUpdateStateSubject
            .asObservable()
    }
    
     var didDiscoverPeripheral: Observable<ScanResponse> {
        return RxCBCentralManagerDelegateProxy.proxy(for: base)
            .didDiscoverPeripheralSubject
            .asObservable()
    }
    
     var didConectPeripheral: Observable<ScanResponse> {
        return RxCBCentralManagerDelegateProxy.proxy(for: base)
            .didConnectPeripheralSubject
            .asObservable()
    }
    
     var didFailToConnectPeripheral: Observable<ScanResponse> {
        return RxCBCentralManagerDelegateProxy.proxy(for: base)
            .didFailToConnectPeripheralSubject
            .asObservable()
    }
    
     var didDisconnectPeripheral: Observable<ScanResponse> {
        return RxCBCentralManagerDelegateProxy.proxy(for: base)
            .didDisconnectPeripheralSubject
            .asObservable()
    }
    
}

