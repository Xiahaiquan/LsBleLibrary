//
//  NFCCommandTool.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/27.
//

import Foundation
import RxSwift

public class NFCCommandTool: NSObject {
    
    public static let shared: NFCCommandTool = NFCCommandTool()
    /*
     Command 构建成 Data, [command 部分] 结构： length 0xAB index length data 0xCD ...
     */
    public func buildCommandData(_ commands: [NFCCommand]) -> Data {
        var contentData = Data()
        var commandCount = commands.count
        let commandCountData = Data(bytes: &commandCount, count: 2)   // pb data length
        contentData.append(commandCountData)
        
        _ = commands.map({ cmd -> Data in
            var itemData = Data()
            
            let headerBytes : [UInt8] = [0xAB]
            let headerData = Data.init(bytes: headerBytes, count: headerBytes.count)
            itemData.append(headerData)             // 头部
            
            var dataIndex = cmd.index
            let dataIndexData = Data(bytes: &dataIndex, count: 2)   // pb data length
            itemData.append(dataIndexData)
            
            let commandData = cmd.command.hexToData
            var cmdLengthCount = commandData.count
            let cmdLengthData = Data.init(bytes: &cmdLengthCount, count: 2)
            itemData.append(cmdLengthData)          // 命令长度
            itemData.append(commandData)            //内容
            
            let endBytes : [UInt8] = [UInt8(0xCD)]
            let endData = Data.init(bytes: endBytes, count: endBytes.count)
            itemData.append(endData)            // 尾部
            return itemData
        }).map({ (arg) in
            contentData.append(arg)
        })
        return contentData
    }
    
    /*
     Command 构建成 Data, [command 部分] 结构： length 0xAB index length data 0xCD ...
     */
    public func buildCommandData(_ datas: [Data], startIndex: Int = 1) -> Data {
        var contentData = Data()
        var commandCount = datas.count
        let commandCountData = Data(bytes: &commandCount, count: 2)   // pb data length
        contentData.append(commandCountData)
        
        let space = startIndex == 0 ? 1 : 0
        for i in 1...datas.count {
            var itemData = Data()
            let headerBytes : [UInt8] = [0xAB]
            let headerData = Data.init(bytes: headerBytes, count: headerBytes.count)
            itemData.append(headerData)             // 头部
            
            var dataIndex = i - space       // 下标可能从0 开始 也可能从1 开始
            let dataIndexData = Data(bytes: &dataIndex, count: 2)   // pb data length
            itemData.append(dataIndexData)
            
            let commandData = datas[i - 1]
            var cmdLengthCount = commandData.count
            let cmdLengthData = Data.init(bytes: &cmdLengthCount, count: 2)
            itemData.append(cmdLengthData)          // 命令长度
            itemData.append(commandData)            //内容
                
            let endBytes : [UInt8] = [UInt8(0xCD)]
            let endData = Data.init(bytes: endBytes, count: endBytes.count)
            itemData.append(endData)            // 尾部
            contentData.append(itemData)
        }
        
        return contentData
    }

    
    /*
     data 组装成 0xABFFFF0xCD
     */
    public func buildNFCCmdContent(_ data: Data, startIndex: Int = 1) -> Data {
        var contentData = Data()
        
        var commandCount = 1
        let commandCountData = Data(bytes: &commandCount, count: 2)   // pb data length
        contentData.append(commandCountData)
            
        var itemData = Data()
            
        let headerBytes : [UInt8] = [0xAB]
        let headerData = Data.init(bytes: headerBytes, count: headerBytes.count)
        itemData.append(headerData)             // 头部
        
        var dataIndex = startIndex
        let dataIndexData = Data(bytes: &dataIndex, count: 2)   // pb data length
        itemData.append(dataIndexData)
            
        let commandData = data
        var cmdLengthCount = commandData.count
        let cmdLengthData = Data.init(bytes: &cmdLengthCount, count: 2)
        itemData.append(cmdLengthData)          // 命令长度
        itemData.append(commandData)            //内容
            
        let endBytes : [UInt8] = [UInt8(0xCD)]
        let endData = Data.init(bytes: endBytes, count: endBytes.count)
        itemData.append(endData)            // 尾部
        
        contentData.append(itemData)
        return contentData
    }


    /**
     验证执行结果
     */
    public func validateExcuteResult(result: String) -> Observable<String> {
        return Observable.create { (subscriber) -> Disposable in
            let predicate = NSPredicate(format: "SELF MATCHES %@", ".*9000$")
            let excuteFlag = predicate.evaluate(with: result)
            if excuteFlag {
                subscriber.onNext(result)
                subscriber.onCompleted()
            } else {
                subscriber.onError(NFCError.error("validateExcuteResult 数据校验不通过"))
            }
            return Disposables.create()
        }
    }
    
    /*
      从 Data 递归解析出 执行结果
     */
    public func analysisCmdExcuteResultFromData(_ data: Data) -> Observable<[ExcuteResult]> {
        
        let cmdBytes = [UInt8](data)
        let cmdHexString = cmdBytes.hexString
        
        printLog("The original data:\(cmdHexString)")
        
        return Observable.create { (observer) -> Disposable in
            guard data.count > 5 else {                                            // 至少应有一条cmd ，长度至少有 头尾
                observer.onError(BleError.error("需要解析的数据至少应该有5个字节"))
                return Disposables.create()
            }
            let expectCmdLength: UInt16 = data.scanValue(at: 0)                      // 第 1， 2 字节为指令条数
            
            let startIndex = data.index(data.startIndex, offsetBy: 2)               //
            let endIndex = data.endIndex
            let subDataRange: Range = startIndex..<endIndex
            let commandData = data.subdata(in: subDataRange)                        // command 部分
            
            var iterationData = commandData                                         // 命令部分
            let protocolLength: UInt16 = 6                                          // AB头 1 + 序号2 + 命令长度2 + CD结尾1 （占 5 个字节）
            var results: [ExcuteResult] = []
            var continueCondition = true
            
            // 遍历读出所有 cmd result
            while continueCondition {
                let cmdLength: UInt16 = iterationData.scanValue(at: 3)               // cmd 长度
                let signItemLength = protocolLength + cmdLength                     // cmd 长度 + pb 协议长度
                guard iterationData.count >= signItemLength else {
                    observer.onError(BleError.error("遍历解析时，超出了数据总长度"))
                    continueCondition = false
                    continue
                }
                let itemStartIndex = iterationData.startIndex
                let itemEndIndex = iterationData.index(iterationData.startIndex, offsetBy: Int(signItemLength))
                let itemDataRange: Range = itemStartIndex..<itemEndIndex
                let itemData = iterationData.subdata(in: itemDataRange)
                let itemBytes = [UInt8](itemData)
                guard itemBytes.count == signItemLength, itemBytes.first == 0xAB && itemBytes.last == 0xCD  else {
                    observer.onError(BleError.error("解析命令数据时头尾长度异常"))
                    continueCondition = false
                    continue
                }
                let index: UInt16 = itemData.scanValue(at: 1)
                let cmdStartData = itemData.index(itemData.startIndex, offsetBy: 5)         // 去掉前4 个（ 1 头 AB + 2 index + 2 length )
                let cmdEndData = itemData.index(itemData.endIndex, offsetBy: -1)            // 去掉 尾巴
                
                let cmdDataRange: Range = cmdStartData..<cmdEndData
                let cmdData = itemData.subdata(in: cmdDataRange)
                let cmdBytes = [UInt8](cmdData)
                let cmdHexString = cmdBytes.hexString
                printLog("handle excel result:\(cmdHexString)")
                let excuteResult: ExcuteResult = (Int(index), cmdHexString)
                results.append(excuteResult)
                
                let leftStartIndex = itemEndIndex
                let leftDataRange: Range = leftStartIndex..<iterationData.endIndex
                iterationData = iterationData.subdata(in: leftDataRange)                    // 剩下的数据
                continueCondition = iterationData.count > 0                                 // 数据长度判断是否继续
            }
            // 如果和期待命令条数不一致
            guard results.count == expectCmdLength else {
                observer.onError(BleError.error("解析时 头部携带数据和解析数据结果不一致"))
                return Disposables.create()
            }
            observer.onNext(results)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /**
     验证执行结果
     */
    public func validateExcuteResults(result: [String]) -> Observable<[String]> {
        return Observable.create { (subscriber) -> Disposable in
            let predicate = NSPredicate(format: "SELF MATCHES %@", ".*9000$")
            var excuteFlag = true
            for r in result {
                excuteFlag = predicate.evaluate(with: r)
                if !excuteFlag {
                    break
                }
            }
            if excuteFlag {
                subscriber.onNext(result)
                subscriber.onCompleted()
            } else {
                subscriber.onError(NFCError.error("validateExcuteResult: data validate failule"))
            }
            return Disposables.create()
        }
    }

}
