//
//  BLEConstant.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/21.
//

import Foundation

public typealias ScanItem = (uuid: String, deviceName: String, rssi: NSNumber, macAddress: String, category: LSDeviceCategory, type: LSSportWatchType, series: LSSportWatchSeries)

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
