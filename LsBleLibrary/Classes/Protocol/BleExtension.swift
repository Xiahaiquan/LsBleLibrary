//
//  BleExtension.swift
//  SDK_Test
//
//  Created by antonio on 2021/11/8.
//

import Foundation

public extension String {
    var hexToData: Data {
        var data = Data(capacity: self.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        return data
    }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        return self.compactMap { String(format: "%02x", $0).uppercased() }
        .joined(separator: "")
    }
}
//extension UInt32 {
//    var data: Data {
//        var int = self
//        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
//    }
//}
extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
}
public extension Data {
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.copyBytes(to:&number, count: MemoryLayout<UInt8>.size)
            return number
        }
    }
    
    var uint16: UInt16 {
        get {
            let i16array = self.withUnsafeBytes { $0.load(as: UInt16.self) }
            return i16array
        }
    }
    
    var uint32: UInt32 {
        get {
            let i32array = self.withUnsafeBytes { $0.load(as: UInt32.self) }
            return i32array
        }
    }
    
    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.count)
            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
            return NSUUID(uuidBytes: bytes)
        }
    }
    var stringASCII: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
    
    var stringUTF8: String? {
        get {
            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }

    var bytes : [UInt8] {
        return [UInt8](self)
    }
    
}
public extension Data {
    func scanValue<T: FixedWidthInteger>(at index: Data.Index) -> T {
        let start = index
        let end = index + MemoryLayout<T>.size
        
        if end > self.count {
            return 0
        }
        
        let number: T = self.subdata(in: start ..< end).withUnsafeBytes({ $0.load(as: T.self)})
        
        return number
    }
    
    func desc() -> String {
        let bytes = [UInt8](self)
        
        return "\(bytes.hexString)"
    }
    
}
extension Date {

      // - Returns: 年份
      func year() -> Int {
          let calendar = Calendar.current
          let com = calendar.dateComponents([.year,.month,.day], from: self)
          return com.year!
      }

      // 月份
      func month() -> Int {
          let calendar = Calendar.current
          let com = calendar.dateComponents([.year,.month,.day], from: self)
          return com.month!
      }


      // MARK:日期
      func day() -> Int {
          let calendar = Calendar.current
          let com = calendar.dateComponents([.year,.month,.day], from: self)
          return com.day!
      }
    
    // MARK:时
    func hour() -> Int {
        let calendar = Calendar.current
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: self)
        return com.hour!
    }

    
    
    // MARK:分
    func min() -> Int {
        let calendar = Calendar.current
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: self)
        return com.minute!
    }
}
