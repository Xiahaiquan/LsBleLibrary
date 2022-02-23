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
    case failed
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
    var scanInfo: (services: [CBUUID]?, deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType]) { get }
    var centralManager : CBCentralManager { get }
    
    typealias Input = (
        centralManager: CBCentralManager,
        scanInfo: (services: [CBUUID]?, deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType])
    )
    
    typealias ScanBuilder = (BluetoothScanable.Input) -> BluetoothScanable
    
    func scan(duration: Int?) -> Observable<(state: ScanState, response : [ScanResponse]?)>          // 如不想用 响应式 方式， 可以定义block 方式接口
}

public class BluetoothScan: BluetoothScanable {
    public var scanInfo: (services: [CBUUID]?, deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType])
    public var centralManager: CBCentralManager
    
    public init(centralManager: CBCentralManager, scanInfo: (services: [CBUUID]?,deviceCategory: [LSDeviceCategory], deviceType: [LSSportWatchType])) {
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
            if let identifier = UserDefaults.standard.object(forKey: peripheralIdentifierCurrent) as? String,
                let uuid = UUID.init(uuidString: identifier) {
                let connected =  centralManager.retrievePeripherals(withIdentifiers: [uuid])
                
                let scanResponses = connected.map({ ScanResponse(peripheral: $0) })
                if !scanResponses.isEmpty {
                    subscriber.onNext((state: .nomal, response: scanResponses))
                }
                
            }

            // 订阅扫描结果
            let sub = centralManager.rx.didDiscoverPeripheral
                .subscribe(onNext: { (response) in
                    guard let advData = response.advertisementData, let manufacturerData = advData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.count > 10 else {
                        return
                    }
                    
                    if scanInfo.deviceCategory.isEmpty || scanInfo.deviceType.isEmpty {
                        subscriber.onNext((state: .nomal, response: [response]))
                        return
                    }
                
                    
                    let deviceCategory = Int(manufacturerData[3])
                    let deviceType = Int(manufacturerData[4])
                
                    let isContainCaegory = scanInfo.deviceCategory.contains { cat in
                        return cat.rawValue == deviceCategory
                    }
                    
                    if isContainCaegory {
//                        print("搜索到的ID，", deviceCategory)
                    }
                    
                    //包含了体脂秤，就不用判断具体的设备型号了
                    //4c533c03 01070000 9a333620 d80ca0c8 b95a0da8
                    if isContainCaegory, deviceCategory == LSDeviceCategory.BodyFatScale.rawValue {
                        subscriber.onNext((state: .nomal, response: [response]))
                        return
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
                if scanInfo.services == nil {
                    printLog("后台扫描要有Services")
                }
//                assert(scanInfo.services != nil, "后台扫描要有Services")
                centralManager.scanForPeripherals(withServices: scanInfo.services, options: nil)
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

            return Disposables.create([sub])
        }
    }
}


extension BluetoothScan {
    
    func asyncState() ->Observable<AsyncCentralState> {
        
        return Observable<AsyncCentralState>.create { [unowned self] observer in
            
            switch self.centralManager.state {
            case .unknown:
                observer.onNext(.unknown)
            case .resetting:
                observer.onNext(.unknown)
            case .unsupported:
                observer.onNext(.unsupported)
            case .unauthorized:
                observer.onNext(.unauthorized)
            case .poweredOff:
                observer.onNext(.poweredOff)
            case .poweredOn:
                observer.onNext(.poweredOn)
            @unknown default:
                observer.onNext(.unknown)
            }
            
            return Disposables.create()
        }
        
    }

}


public enum AsyncCentralState: Int {
    case unsupported = 2
    case unauthorized = 3
    case poweredOff = 4
    case poweredOn = 5
    case unknown = -1
}
