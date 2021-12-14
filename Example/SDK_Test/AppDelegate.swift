//
//  AppDelegate.swift
//  SDK_Test
//
//  Created by 夏海泉 on 2021/11/1.
//

import UIKit
import CoreBluetooth
import LsBleLibrary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        configBleLibrary()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window?.rootViewController = UINavigationController.init(rootViewController: Ls02FunctionVc.instantiate("L02Function"))
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    
    func configBleLibrary() {
        // 扫描 和 连接 的具体实现
        let scanBuilder: BluetoothScanable.ScanBuilder = {
            BluetoothScan(centralManager: $0.centralManager, scanInfo: $0.scanInfo)
        }
        let connectBuilder: BluetoothConnectable.ConnectBuilder = {
            BluetoothConnect(
                centralManager: $0.centralManager,
                connectInfo: $0.connectInfo,
                scaner: $0.scaner
            )
        }
        
        
        // 配置扫描和连接实现
        BleFacade.shared.configBuider(scanBuilder, connectBuilder)
        
        // 如果已经知道要连接的设备信息 （比如已经绑定过，可以直接连接）
        let config = BleScanDeviceConfig(
            services: [CBUUID.init(string: "60FF"), CBUUID.init(string: "FEE7")],
            deviceCategory: [.Watch],
            deviceType: [.LS04, .LS05S]
        )
        // 如果不确定连接设备，至少要知道 设备前缀 和 广播服务 （无法直接连接，只能先扫描，再手动连接，比如绑定过程）
        //let config = BleDeviceConfig(["Haylou Solar"], [CBUUID.init(string: "60FF")])
        BleFacade.shared.configDeviceInfo(config)

    }
    
}

//case SportWatch_LS02 = 0x02
//case SportWatch_LS03 = 0x03
//case SportWatch_Haylou_RS3 = 0x04
//case SportWatch_LS05 = 0x05
//case SportWatch_LS05S = 0x06
//case SportWatch_LS006 = 0x07
//case SportWatch_LS02GPS = 0x08
//case SportWatch_LS09A = 0x09
//case SportWatch_LS09B = 0x0A
//case SportWatch_LS10 = 0x11
//case SportWatch_LS11 = 0x12
//case SportWatch_LS12 = 0x13






