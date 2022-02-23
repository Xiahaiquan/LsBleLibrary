//
//  BleDevice.swift
//  SDK_Test
//
//  Created by antonio on 2021/11/4.
//

import Foundation

public class BleDeviceArchiveModel: NSObject, NSCoding, NSSecureCoding {
    public static var supportsSecureCoding: Bool {
        return true
    }
    
    // 从object 解析回来
    public required init?(coder: NSCoder) {
        super.init()
        uuid = coder.decodeObject(forKey: "uuid") as? String ?? ""
        address = coder.decodeObject(forKey: "address") as? String ?? ""
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        category = coder.decodeInteger(forKey: "category")
        type = coder.decodeInteger(forKey: "type")
        series = coder.decodeInteger(forKey: "series")
        
    }
    
    public override init() {
        self.uuid = ""
        self.address = ""
        self.name = ""
        self.category = 0
        self.type = 0
        self.series = 1 //1代表ls 2代表ute
    }
    
    public convenience init(uuid: String, address: String , name: String, category: Int, type: Int, series: Int) {
        self.init()
        self.uuid = uuid
        self.address = address
        self.category = category
        self.name = name
        self.type = type
        self.series = series
    }
    
    
    // 编码成object
    public func encode(with coder: NSCoder) {
        coder.encode(uuid, forKey: "uuid")
        coder.encode(address, forKey: "address")
        coder.encode(name, forKey: "name")
        coder.encode(category, forKey: "category")
        coder.encode(type, forKey: "type")
        coder.encode(series, forKey: "series")
    }
    
    public var uuid: String = ""
    public var address: String = ""
    public var name: String = ""
    public var category: Int = 0
    public var type: Int = 0
    public var series: Int = 0
}

extension BleDeviceArchiveModel {
    public static func get() ->BleDeviceArchiveModel? {
        // 路径
        let file = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        // 拼接路径 自动带斜杠的
        let filePath = (file as NSString).appendingPathComponent("BleDeviceArchiveModel.archiver")
        do {
            let data = try Data.init(contentsOf: URL(fileURLWithPath: filePath))
            // 当用户首次登陆, 直接从沙盒获取数据, 就会为nil  所以这里需要使用as?
            let model = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? BleDeviceArchiveModel
            return model!
        } catch {
//            print("获取data数据失败: \(error)")
        }
        
        return nil
    }
    
    public static func save(model: BleDeviceArchiveModel) {
        // 路径
        let file = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        // 拼接路径 自动带斜杠的
        let filePath = (file as NSString).appendingPathComponent("BleDeviceArchiveModel.archiver")
        // 保存
        let data = NSKeyedArchiver.archivedData(withRootObject: model)
        do {
            _ = try data.write(to: URL(fileURLWithPath: filePath))
            //            print("archiver success")
        } catch {
            print("data写入本地失败: \(error)")
        }
        
    }
    
    public static func delete() {
        let file = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        // 拼接路径 自动带斜杠的
        let filePath = (file as NSString).appendingPathComponent("BleDeviceArchiveModel.archiver")
        
        try? FileManager.default.removeItem(atPath: filePath)
        
    }
}
