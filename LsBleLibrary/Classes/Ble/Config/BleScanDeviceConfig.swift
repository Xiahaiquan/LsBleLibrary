//
//  BleDeviceConfig.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/23.
//  Copyright © 2020 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BleScanDeviceConfig {
    
    //
    var services: [CBUUID]
    var deviceCategory: [LSDeviceCategory] //手表、耳机、体脂称
    var deviceType: [LSSportWatchType] // 05、11
    var timeout: Int = 8
    
    
    public init(services: [CBUUID],
                deviceCategory: [LSDeviceCategory],
                deviceType: [LSSportWatchType],
                timeout: Int = 8) {
        self.services = services
        self.deviceCategory = deviceCategory
        self.deviceType = deviceType
        self.timeout = timeout
    }
    
}


public class BleConnectDeviceConfig {
    
    var connectName: String?
    var deviceMacAddress: String?
    var timeout: Int = 8
    
    public init(connectName: String?,
                deviceMacAddress: String?,
                services: [CBUUID],
                timeout: Int = 8) {
        self.connectName = connectName
        self.deviceMacAddress = deviceMacAddress
        self.timeout = timeout
    }
    
}
