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
 蓝牙发送任务
 1: 发送特征通道
 2：发送数据
 3：期待返回条数
 4：超时时间
 5：订阅者
 */
class BleTask {
    
    var name: String
    var characteristic: CBCharacteristic?
    var writeData: Data
    var expectNum: Int?
    var duration: Int?
    var isAck: Bool?        // 特殊命令，数据是紧接着 ACK 而来。
    var endBySelf: Bool?
    var endRecognition: ((Data) -> Bool)?
    var subscriber: AnyObserver<BleResponse>
    
    init(_ name: String,
         _ characteristic: CBCharacteristic?,
         _ writeData: Data,
         _ expectNum: Int?,
         _ duration: Int?,
         _ endRecognition: ((Data) -> Bool)?,
         _ subscriber: AnyObserver<BleResponse>) {
        self.name = name
        self.characteristic = characteristic
        self.writeData = writeData
        self.expectNum = expectNum
        self.duration = duration
        self.endRecognition = endRecognition
        self.subscriber = subscriber
    }
}

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
public protocol Deviceable {
    
    var deviceCategory: LSDeviceCategory { get }
    var watchType: LSSportWatchType { get }
    var watchSeries: LSSportWatchSeries { get }
    
    var peripheral: CBPeripheral? { get set}
    
    var connected: Bool { get }
    
    var dataObserver02: Observable<UTEOriginalData>? { get }
    var dataObserver05s: Observable<LsBackData>? { get }
    
    func updateCharacteristic(characteristic: [CBCharacteristic]?, statusCallback: ((Bool) ->Void)?)
    
    func write(
        data: Data,
        name: String,
        expectNum: Int?,
        duration: Int?,
        ackInInterval: Bool?,
        endBySelf: Bool?,
        trigger: Bool,
        endRecognition: ((Data) -> Bool)?) -> Observable<BleResponse>             // 如不想用 响应式 方式， 可以定义 block 方式接口
    
    func maximumWriteValueLength() -> Int?
    
    func readValue(_ type: Int)
    
    func directWrite(_ data: Data, _ type: Int)
    
}

extension Deviceable {
    
    func onException(_ error: BleError) -> Void {
        
    }
    
    public func readValue(_ type: Int = 0) {
        
    }
    
    func directWrite(_ data: Data, _ type: Int) {
        
    }
    
    public var dataObserver02: Observable<UTEOriginalData>? {
        return nil
    }
    
    public var dataObserver05s: Observable<LsBackData>? {
        return nil
    }
    
    
    public func maximumWriteValueLength() -> Int? {
        guard let p = self.peripheral, p.state == .connected else {
            return nil
        }
        return p.maximumWriteValueLength(for: .withoutResponse)
    }
}
extension Deviceable {
    
}

public enum LSDeviceCategory: Int {
    case TWS = 0x01
    case Watch = 0x02
    case BodyFatScale = 0x03
    case Others = 0x00
    
    public init(rawValue: Int) {
        if rawValue == 0x01 {
            self = .TWS
        } else if rawValue == 0x02 {
            self = .Watch
        }else if rawValue == 0x03 {
            self = .BodyFatScale
        }else {
            self = .Others
        }
    }
}

public enum LSSportWatchSeries: Int {
    case UTE = 0x01
    case LS = 0x02
    
    public init(type: LSSportWatchType) {
        if type == .LS02 || type == .LS03 || type == .LS04 || type == .LS05 {
            self = .UTE
        }else {
            self = .LS
        }
    }
    
}

public enum LSSportWatchType: Int {
    
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
            self = .LS05S
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
