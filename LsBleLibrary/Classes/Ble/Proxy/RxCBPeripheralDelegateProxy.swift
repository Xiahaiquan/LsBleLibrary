//
//  RxCBPeripheralDelegateProxy.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/15.
//  Copyright © 2020 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

class RxCBPeripheralDelegateProxy: DelegateProxy<CBPeripheral, CBPeripheralDelegate>, DelegateProxyType, CBPeripheralDelegate {

    var didDiscoverCharacteristicsSubject = PublishSubject<(p: CBPeripheral, s: CBService, c: [CBCharacteristic]?)>()
    
    var didUpdateValueForSubject = PublishSubject<(p: CBPeripheral, data: CBCharacteristic, error: Error?)>()
    
    var didWriteValueForSubject = PublishSubject<(p: CBPeripheral, data: CBCharacteristic, error: Error?)>()

    var didUpdateNotificationSubject = PublishSubject<(p: CBPeripheral, data: CBCharacteristic, error: Error?)>()
    
    init(_ peripheral: CBPeripheral) {
        super.init(parentObject: peripheral, delegateProxy: RxCBPeripheralDelegateProxy.self)
    }
    
    /// 注册代理的实现为 RxCBPeripheralDelegateProxy 实例
    static func registerKnownImplementations() {
        self.register {
            RxCBPeripheralDelegateProxy($0)
        }
    }
    
    static func currentDelegate(for object: CBPeripheral) -> CBPeripheralDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CBPeripheralDelegate?, to object: CBPeripheral) {
        object.delegate = delegate
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let serviceArray = peripheral.services {
            for service  in serviceArray {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        didDiscoverCharacteristicsSubject.onNext((p: peripheral, s: service, c: service.characteristics))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        didUpdateValueForSubject.onNext((p: peripheral, data: characteristic, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        didWriteValueForSubject.onNext((p: peripheral, data: descriptor.characteristic!, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        didUpdateNotificationSubject.onNext((p: peripheral, data: characteristic, error: error))
    }
    
}

// CBCentralManager 扩展RX属性
extension Reactive where Base: CBPeripheral {
    
     var delegate: DelegateProxy<CBPeripheral, CBPeripheralDelegate> {
        return RxCBPeripheralDelegateProxy.proxy(for: base)
    }
    
     var didDiscoverCharacteristics: Observable<(p: CBPeripheral, s: CBService, c: [CBCharacteristic]?)> {
        return RxCBPeripheralDelegateProxy.proxy(for: base)
            .didDiscoverCharacteristicsSubject
            .asObservable()
    }
    
     var didUpdateValue: Observable<(p: CBPeripheral, data: CBCharacteristic, error: Error?)> {
        return RxCBPeripheralDelegateProxy.proxy(for: base)
            .didUpdateValueForSubject
            .asObservable()
    }
    
     var didWriteValue: Observable<(p: CBPeripheral, data: CBCharacteristic, error: Error?)> {
        return RxCBPeripheralDelegateProxy.proxy(for: base)
            .didWriteValueForSubject
            .asObservable()
    }
    
     var didUpdateNotification: Observable<(p: CBPeripheral, data: CBCharacteristic, error: Error?)> {
        return RxCBPeripheralDelegateProxy.proxy(for: base)
            .didUpdateNotificationSubject
            .asObservable()
    }
    
}

