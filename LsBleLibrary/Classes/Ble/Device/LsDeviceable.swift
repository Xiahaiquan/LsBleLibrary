//
//  Deviceable.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/16.
//  Copyright © 2020 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift


/*
 设备接口
 包含
 1：peripheral：外设实例
 2：connected： 已连接计算 （设备已连接并不能表示一切正常， 还要知道 发送和接收特征是否都正常）
 3：updateCharacteristic 发现设备的特征值，通过该函数赋值给设备
 4：write 向该设备的某通道写
 5：transmitter 立即触发BLE 发送数据 （队列为空时，立刻发送，队列繁忙，则等待）
 5：onException 异常处理
 6: dataObserver 设备主动上报监听
 */
public protocol LsDeviceable {
    
    var deviceCategory: LSDeviceCategory { get }
    var watchType: LSSportWatchType { get }
    var watchSeries: LSSportWatchSeries { get }
    
    var peripheral: CBPeripheral? { get set}
    
    var connected: Bool { get }
    
    var dataObserver: Observable<BleBackDataProtocol>? { get }
    
    func updateCharacteristic(characteristic: [CBCharacteristic]?, statusCallback: ((Bool) ->Void)?)
    
    func write(data: Data, characteristic: Int, name: String, duration: Int?, endRecognition: ((Data) -> Bool)?) -> Observable<BleResponse>
    
    func maximumWriteValueLength() -> Int?
    
    func onException(_ error: BleError) -> Void
    
    func readValue(channel: Channel)
    
    func directWrite(_ data: Data, _ type: WitheType)
    
}

extension LsDeviceable {
    
    func onException(_ error: BleError) -> Void {
        
    }
    
    func readValue(channel: Channel) {
        
    }
    
    func directWrite(_ data: Data, _ type: WitheType) {
        
    }
    
    public var dataObserver: Observable<BleBackDataProtocol>? {
        return nil
    }
    
    public func maximumWriteValueLength() -> Int? {
        guard let p = self.peripheral, p.state == .connected else {
            return nil
        }
        return p.maximumWriteValueLength(for: .withoutResponse)
    }
}
extension LsDeviceable {
    
}

/// 设备类型
public enum LSDeviceCategory: Int {
    case unknown = 0x00 //未知设备
    case TWS = 0x01 //耳机
    case Watch = 0x02 //手表
    case BodyFatScale = 0x03 //体脂秤
    
    public init(rawValue: Int) {
        if rawValue == 0x01 {
            self = .TWS
        } else if rawValue == 0x02 {
            self = .Watch
        }else if rawValue == 0x03 {
            self = .BodyFatScale
        }else {
            self = .unknown
        }
    }
}

///  协议类型
public enum LSSportWatchSeries: Int {
    case UTE = 0x01 //优创亿的协议
    case LS = 0x02  //猎声的协议
    
    public init(type: LSSportWatchType) {
        if type == .LS02 || type == .LS03 || type == .LS04 || type == .LS05 {
            self = .UTE
        }else {
            self = .LS
        }
    }
    
}

/// 手表的类型
public enum LSSportWatchType: Int {
    case unknown = 0x00
    case LS02 = 0x02
    case LS03 = 0x03
    case LS04 = 0x04 //Haylou_RS3
    case LS05 = 0x05
    case LS05S = 0x06
    case LS06 = 0x07
    case LS02GPS = 0x08
    case LS09A = 0x09
    case LS09B = 0x0A
    case LS10 = 0x11
    case LS11 = 0x12
    case LS12 = 0x13
    
    public init(rawValue: Int) {
        if rawValue == 0x02 {
            self = .LS02
        } else if rawValue == 0x03 {
            self = .LS03
        }else if rawValue == 0x04 {
            self = .LS04
        }else if rawValue == 0x05 {
            self = .LS05
        }else if rawValue == 0x06 {
            self = .LS05S
        }else if rawValue == 0x07 {
            self = .LS06
        }else if rawValue == 0x08 {
            self = .LS02GPS
        }else if rawValue == 0x09 {
            self = .LS09A
        }else if rawValue == 0x0A {
            self = .LS09B
        }else if rawValue == 0x11 {
            self = .LS10
        }else if rawValue == 0x12 {
            self = .LS11
        }else if rawValue == 0x13 {
            self = .LS12
        }else {
            self = .unknown
        }
    }
    
    public var requestDialKey: String {
        if rawValue == 0x02 {
            return "LS02"
        } else if rawValue == 0x03 {
            return "LS03"
        }else if rawValue == 0x04 {
            return "LS04"
        }else if rawValue == 0x05 {
            return "LS05"
        }else if rawValue == 0x06 {
            return "LS05S"
        }else if rawValue == 0x07 {
            return "LS06"
        }else if rawValue == 0x08 {
            return "LS02GPS"
        }else if rawValue == 0x09 {
            return "LS09A"
        }else if rawValue == 0x0A {
            return "LS09B"
        }else if rawValue == 0x11 {
            return "LS10"
        }else if rawValue == 0x12 {
            return "LS11"
        }else if rawValue == 0x13 {
            return "LS12"
        }else {
            return ""
        }
    }
    
    /// 手表外观
    public var screenType: Int {
        switch rawValue {  //1方形    2圆形
        case 0x11:
            return 1
        default:
            return 2
        }
    }
}


extension hl_cmds.cmd_t {
    var name: String {
        return "\(self)"
    }
}
public enum LsBleLibraryError: Error {
    case error(messae: String)
}


