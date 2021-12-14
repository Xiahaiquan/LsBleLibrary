//
//  Ls02ConnectAndScanVc.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/5.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
import Toast_Swift
import LsBleLibrary

class Ls02ConnectAndScanVc: UIViewController, Storyboardable {

    let bag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: [ScanItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "连接&扫描"
        
        testSDKFunc()
    }
    
    func testSDKFunc() {
        
        //监听系统蓝牙开关状态
        BleFacade.shared.event.bluetoothState.subscribe { state in
            print("bluetoothState", state)
            
            if state == .poweredOff {
                
            }
    
        } onError: { er in
            
        }
        .disposed(by: bag)
        
       //监听蓝牙断开连接状态
        BleFacade.shared.event.deviceDisconnect.filter({ _ in
            return BleFacade.shared.bleDevice?.connected == false
        })
        .flatMap { _ in
            return BleFacade.shared.connecter.connect(duration: nil)
        }.subscribe { (state, response) in
            if state == .connectSuccessed {
                print("已连接  等待扫描服务及特征")
                
            } else if (state == .dicoverChar) {
                BleFacade.shared.bleDevice?.updateCharacteristic(characteristic: response?.characteristics, statusCallback: { _ in
                    self.view.makeToast("连接成功，需要发送绑定指令，否则无法通讯，设备会主动断开", duration: TimeInterval(6), position: .center)
                })
                if ((BleFacade.shared.bleDevice?.connected) != nil) {
                    BleFacade.shared.connecter.finish()
                }
            } else if (state == .timeOut) {
                print("连接超时，未找到配置信息指定设备")
                self.view.makeToast("连接超时, 请重试")
            }
        } onError: { e in
            
        } .disposed(by: bag)

    }
    
    @IBAction func clickScanBtn(_ sender: UIButton) {
        
        self.dataSource.removeAll()
        self.tableView.reloadData()
        
        BleFacade.shared.scaner
            .scan(duration: 8)
            .subscribe(onNext: { (state, response) in
                if state == .nomal {
                    let devices = response?.filter({ $0.peripheral.name != nil })
                        .map({ res -> ScanItem in
                            var macAddress = ""
                            var category: LSDeviceCategory = .TWS
                            var type: LSSportWatchType = .LS05S
                            var series: LSSportWatchSeries = .LS
                           
                            if let advData = res.advertisementData, let sd = advData[CBAdvertisementDataManufacturerDataKey] as? Data {
                                //新扫描出的设备
                                let macAddressData = [UInt8](sd)
                                let macAddressHex = macAddressData.hexString.lowercased()
                                macAddress = macAddressHex
                                
                                category = LSDeviceCategory.init(rawValue: Int(macAddressData[3]))
                                type = LSSportWatchType.init(rawValue: Int(macAddressData[4]))
                                series = LSSportWatchSeries.init(type: type)
//                                print("type1", type.rawValue, "address", macAddress)
                            }else if res.rssi == 0 {
                                //系统已连接的设备
//                                printLog("\(res.peripheral.identifier)")
                                
                                if let m = BleDeviceArchiveModel.get(), res.peripheral.identifier.uuidString == m.uuid {

//                                    BleFacade.shared.centralManager.stopScan()

                                    let retryScanItem = (res.peripheral.identifier.uuidString, m.name, res.rssi, m.address, category, LSSportWatchType(rawValue: m.type), series)
                                    
                                    self.selectDevice(retryScanItem)
                                }
                                
                            }
//                            print("type2", type.rawValue, "address", macAddress)
                            let item: ScanItem = (res.peripheral.identifier.uuidString, res.peripheral.name!, res.rssi, macAddress, category, type, series)
                            return item
                        }) ?? []
                    self.dataSource.append(contentsOf: devices)
                    self.tableView.reloadData()
                } else if (state == .end) {
                    print("扫描结束")
                }
            }, onError: { error in
                print("\(error)")
            })
            .disposed(by: bag)
    }
    
    @IBAction func clickConnectBtn(_ sender: UIButton) {
        self.doConnect()
    }
}

extension Ls02ConnectAndScanVc {
    func selectDevice(_ item: ScanItem) {
                
//        BleFacade.shared.connecter.finish()
        
        print("selectDevice", item)
        
        var macAddress: String?
        if !item.macAddress.isEmpty {
            let startIndex = item.macAddress.index(item.macAddress.endIndex, offsetBy: -12)
            let macRange: Range = startIndex..<item.macAddress.endIndex
            macAddress = String(item.macAddress[macRange])
        }
        
        
        let config = BleConnectDeviceConfig.init(connectName: item.deviceName, deviceMacAddress: macAddress, services: [CBUUID.init(string: "FEE7")])
        BleFacade.shared.configConnectDeviceInfo(config)
        print("config", config)
        
        let uuid = item.uuid
        print("uuid",uuid)
        
//        BleDeviceArchiveModel.save(model: BleDeviceArchiveModel.init(uuid: uuid, address: item.macAddress, name: item.deviceName, type: item.type.rawValue))
                
        BleDeviceArchiveModel.save(model: BleDeviceArchiveModel.init(uuid: item.uuid, address: item.macAddress, name: item.deviceName, category: item.category.rawValue, type: item.type.rawValue, series: item.series.rawValue))
        
        if item.type == .LS04 {
            BleFacade.shared.bleDevice = Ls02Device()
            Ble02Operator.shared.configFacade(BleFacade.shared)
        }else {
            BleFacade.shared.bleDevice = Ls05sDevice()
            Ble05sOperator.shared.configFacade(BleFacade.shared)
        }
        
        BleOperator.shared.setStrategy(series: BleFacade.shared.bleDevice?.watchSeries ?? .LS)
        
        self.doConnect()
    }
    
    func doConnect() {

        // 连接前 需要 调用 BleFacade.shared.configDeviceInfo(config) 配置设备信息
    
        guard BleFacade.shared.bleDevice?.connected == false else {
            print("已连接 终止")
            return
        }
        BleFacade.shared.connecter.connect(duration: 12)
            .subscribe(onNext: { (state, response) in
                if state == .connectSuccessed {
                    print("已连接  等待扫描服务及特征")
                    BleFacade.shared.bleDevice?.peripheral = response?.peripheral
                } else if (state == .dicoverChar) {
                    BleFacade.shared.bleDevice?.updateCharacteristic(characteristic: response?.characteristics, statusCallback: nil)
                    if ((BleFacade.shared.bleDevice?.connected) != nil) {
                        // 必要特征已找到 即可认为已连接， 此处可能执行多次（还有其他非必要特征）
                        BleFacade.shared.connecter.finish()
//                        print("已经连接而且知道具体特征， 可以发送数据")
                        self.view.makeToast("连接成功，需要发送绑定指令，否则无法通讯，设备会主动断开", duration: TimeInterval(6), position: .center)
                    }
                } else if (state == .timeOut) {
                    print("连接超时，未找到配置信息指定设备")
                    self.view.makeToast("连接超时, 请重试")
                }
            }, onError: { error in
                print("\(error)")
            })
            .disposed(by: bag)
    }
}

extension Ls02ConnectAndScanVc : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectDevice(self.dataSource[indexPath.row])
    }
}

extension Ls02ConnectAndScanVc : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "deviceCell")
        if indexPath.row >= self.dataSource.count {
            return cell
        }
        let item = self.dataSource[indexPath.row]
        cell.textLabel?.text = item.deviceName
        cell.detailTextLabel?.text = "rssi:\(item.rssi); mac:\(item.macAddress)"
        
        return cell
    }
    
}
