//
//  BleHelper.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/12/10.
//

import Foundation

struct BleHelper {
    
    static func getOperateSwitch(value: UInt32, type: LSSupportFunctionEnum) ->Bool {
        
        if (value >> type.rawValue) & 1 == 1 {
            return true
        }
        
        return false
    }
}


public func crc16ccitt(data: [UInt8],seed: UInt16 = 0x0000, final: UInt16 = 0xffff)->UInt16{
    var crc = seed
    data.forEach { (byte) in
        crc ^= UInt16(byte) << 8
        (0..<8).forEach({ _ in
            crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1
        })
    }
    return crc & final
}


//CRC32
public func checksum(bytes: [UInt8]) -> UInt32 {
    return ~(bytes.reduce(~UInt32(0), { crc, byte in
        (crc >> 8) ^ table[(Int(crc) ^ Int(byte)) & 0xFF]
    }))
}


var table: [UInt32] = {
    return (0...255).map { i -> UInt32 in
        (0..<8).reduce(UInt32(i)) { (c, _) -> UInt32 in
            if c % 2 == 0 {
                return c >> 1
            } else {
                return 0xEDB88320 ^ (c >> 1)
            }
        }
    }
}()

extension BleHelper {
    
    /// 获取手表可用的时间戳
    /// - Parameter timestamp: App的时间戳
    /// - Returns: 手表可用的时间戳
    static func getCurrentTimeWithSecond(timestamp: UInt32) ->Double  {
        let timeZone = getTimeZone()
        if timeZone < -50 || timeZone > 50 {
            return Double(timestamp) - Double(timeZone * (3600 - 36))
        }
        
        return Double(timestamp)
    }
    
    /// 获取手表可使用的时区
    /// - Returns: 时区
    static func getTimeZone() ->CGFloat {
        
        var timezone = CGFloat(TimeZone.current.secondsFromGMT()) / CGFloat(60 * 60)
        //app的时区要乘于100.防止半时区丢精度的问题
        if isAccurateTimestamp {
            timezone *= 100
        }
        return timezone
    }
    
}
