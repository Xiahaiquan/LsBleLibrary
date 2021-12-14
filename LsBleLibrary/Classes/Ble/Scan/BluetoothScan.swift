//
//  BluetoothConnecter.swift
//  Liesheng
//
//  Created by guotonglin on 2020/12/11.
//  Copyright © 2020 Liesheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import RxCocoa

public enum ScanState: Int {
    case nomal
    case powerOn
    case end
}

enum ScanError: Error {
    case error(messae: String, _ state: BluetoothState? = .unknown)
}

public class ScanResponse {
    public var peripheral: CBPeripheral
    public var advertisementData: [String : Any]?
    public var rssi: NSNumber
    init(peripheral: CBPeripheral,
         advertisementData: [String : Any]? = nil,
         rssi: NSNumber = NSNumber.init(value: 0)) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}

public protocol BluetoothScanable {
    var scanInfo: (services: [CBUUID], deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType]) { get }
    var centralManager : CBCentralManager { get }
    
    typealias Input = (
        centralManager: CBCentralManager,
        scanInfo: (services: [CBUUID], deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType])
    )
    
    typealias ScanBuilder = (BluetoothScanable.Input) -> BluetoothScanable
    
    func scan(duration: Int?) -> Observable<(state: ScanState, response : [ScanResponse]?)>          // 如不想用 响应式 方式， 可以定义block 方式接口
}

public class BluetoothScan: BluetoothScanable {
    public var scanInfo: (services: [CBUUID], deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType])
    public var centralManager: CBCentralManager
    
    public init(centralManager: CBCentralManager, scanInfo: (services: [CBUUID],deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType])) {
        self.centralManager = centralManager
        self.scanInfo = scanInfo
    }
    
    public func scan(duration: Int?) -> Observable<(state: ScanState, response : [ScanResponse]?)> {
        return Observable<(state: ScanState, response : [ScanResponse]?)>.create { [centralManager, scanInfo] (subscriber) -> Disposable in
            
            guard centralManager.state == .poweredOn else {
                subscriber.onError(ScanError.error(messae: "Bluetooth state error", BluetoothState(rawValue: centralManager.state.rawValue)))
                return Disposables.create()
            }
            // 获取已连接
            let connected = centralManager.retrieveConnectedPeripherals(withServices: scanInfo.services)
            //            connected = connected.filter({ p in
            //                return (scanInfo.scanPrefix.filter({(p.name?.hasPrefix($0) ?? false)}).count) > 0
            //            })
            let scanResponses = connected.map({ ScanResponse(peripheral: $0) })
            if scanResponses.count > 0 {
                subscriber.onNext((state: .nomal, response: scanResponses))
            }
            // 订阅扫描结果
            _ = centralManager.rx.didDiscoverPeripheral
                .subscribe(onNext: { (response) in
                    
                    guard let advData = response.advertisementData, let manufacturerData = advData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.count > 4 else {
                        return
                    }
                    
                    let deviceCategory = Int(manufacturerData[3])
                    let deviceType = Int(manufacturerData[4])
                    
                    let isContainCaegory = scanInfo.deviceCategory.contains { cat in
                        return cat.rawValue == deviceCategory
                    }
                    
                    let isContainType = scanInfo.deviceType.contains { cat in
                        return cat.rawValue == deviceType
                    }
                    
                    
                    if isContainCaegory, isContainType {
                        subscriber.onNext((state: .nomal, response: [response]))
                    }
                    
                })
            
            // 开始扫描
            if UIApplication.shared.applicationState == .background {
                centralManager.scanForPeripherals(withServices: scanInfo.services , options: nil)
            } else {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
            
            if duration != nil {
                // 指定时间停止扫描
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration!)) {
                    centralManager.stopScan()
                    subscriber.onNext((state: .end, response: []))
                    subscriber.onCompleted()
                }
            }

            return Disposables.create()
        }
    }
}
