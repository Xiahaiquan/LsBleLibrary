//
//  PBConfig.swift
//  ble_debugging
//
//  Created by Antonio on 2021/5/31.
//
/*配置发送命令的pb包头*/
import Foundation

 struct Ble05sCmdsConfig {
    
    static var shared = Ble05sCmdsConfig()
    private init() {}
    
    func configCmds(_ cmdType: hl_cmds.cmd_t) ->hl_cmds {
        var tcmd = hl_cmds()
        tcmd.seconds = UInt32(Date().timeIntervalSince1970)
        tcmd.response = false
        tcmd.timezone = Int32(BleHelper.getTimeZone())
        tcmd.cmd = cmdType
        return tcmd
    }
    
}

extension Ble05sCmdsConfig {
    /// 根据每个字段的长度，对数据分段处理
    /// - Parameters:
    ///   - data: 原始数据
    ///   - chunkSize: 字段的长度
    /// - Returns: 分段后的数据数组
    func chunked(data: Data, chunkSize: Int) ->[Data] {
        
        let dataCount = data.count
        var dataArr =  [Data]()
        
        for index in stride(from: 0, to: dataCount, by: chunkSize)  {
            let end = index + chunkSize
            if end > dataCount { break }
            let subData = data[index ..< end]
            dataArr.append(subData)
        }
        
        let remainder = dataCount % chunkSize
        
        if remainder > 0 {
            let divisor = dataCount / chunkSize
            dataArr.append(data[divisor * chunkSize ..< dataCount])
        }
        
        return dataArr
    }
    
    func chunked(dataArray: [Float], chunkSize: Int) ->[Float] {
        
        let dataCount = dataArray.count
        var dataArr = [Float]()
        
        for index in stride(from: 0, to: dataCount, by: chunkSize)  {
            let end = index + chunkSize
            if end > dataCount { break }
            let subArr = dataArray[index ..< end]
            let sum = subArr.reduce(0,{$0 + $1})
            dataArr.append(sum)
        }
        
        let remainder = dataCount % chunkSize
        
        if remainder > 0 {
            let divisor = dataCount / chunkSize
            let subArr = dataArray[divisor * chunkSize ..< dataCount]
            let sum = subArr.reduce(0,{$0 + $1})
            dataArr.append(sum)
        }
        
        return dataArr
    }
    
    //序列化cmds
    func serializedData(cmds: hl_cmds) ->Data {
        guard let binaryData: Data = try? cmds.serializedData(partial: true) else {
            print("binaryData error")
            return Data()
        }
        return binaryData
    }
    
    //根据包大小，获取超时时间
    func getTimeoutInterval(_ data: Data) ->UInt8 {
        let interval = (Double(data.count) / Double(mtu)) * 0.3
        return UInt8(interval) + 5
    }
    
    func buildPBContent(_ commandData: Data) ->Data  {
        //MARK: 构建最终需要发送的Data
        let commandContentData: Data = commandData
        var contentData = Data()
        let timeout: UInt8 = getTimeoutInterval(commandContentData)
        let headerBytes : [UInt8] = [0x7E, 0x6D, timeout]      //header  and  timeout
        let headerData = Data.init(bytes: headerBytes, count: headerBytes.count)
        contentData.append(headerData)
        
        var dataCount = commandContentData.count
        let dataCountData = Data(bytes: &dataCount, count: 2)   // pb data length
        contentData.append(dataCountData)
        
        let commandContentBytes = [UInt8](commandContentData)
        let crcNumber = crc16ccitt(data: commandContentBytes)
        var tempCrcNumber = crcNumber
        let crcData = Data(bytes: &tempCrcNumber, count: 2)   // pb data crc
        contentData.append(crcData)
        
        let contentBytes = [UInt8](contentData)
        let contentSum: UInt16 = contentBytes.reduce(0, { x, y in
            UInt16(x) + UInt16(y)
        })
        
        var tempContentSum = contentSum
        let contentSumData = Data(bytes: &tempContentSum, count: 2)
        contentData.append(contentSumData)                       //(header) sum with out pb
        contentData.append(commandContentData)                   // pb data
        
        return contentData
        
    }
}
