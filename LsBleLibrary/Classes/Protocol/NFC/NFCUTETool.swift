//
//  NFCUTETool.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/27.
//

import Foundation

enum CityIndex: Int {
    case beijing = 0
    case guangxi
    case hainan
    case xiameng
    case taizhou
    case ningbo
    case hefei
    case wuhang
    case zhengzhou
    case suzhou
    case nantong
    case qingdao
    case hebei
    case xian
    case jili
    case haerbing
    case shijiazhuang
    case tianjin
    case dalian
    case shengyan
    case shiyan
    case shaoxing
    case xizang
    case yuling
    case wuxi
    case changsha
    case changzhou
    case card0
    case card1
    case card2
    case card3
    
    static func getIndex(_ cityCode: String) -> CityIndex? {
        var result: CityIndex?
        switch cityCode {
        case "9005":
            result = .beijing
        case "9002":
            result = .guangxi
        case "0898":
            result = .hainan
        case "1592":
            result = .xiameng
        case "1576":
            result = .taizhou
        case "0574":
            result = .ningbo
        case "2551":
            result = .hefei
        case "0027":
            result = .wuhang
        case "1371":
            result = .zhengzhou
        case "1512":
            result = .suzhou
        case "9009":
            result = .nantong
        case "0532":
            result = .qingdao
        case "9001":
            result = .hebei
        case "1029":
            result = .xian
        case "0432":
            result = .jili
        case "0451":
            result = .haerbing
        case "0311":
            result = .shijiazhuang
        case "1022":
            result = .tianjin
        case "0411":
            result = .dalian
        case "0024":
            result = .shengyan
        case "0719":
            result = .shiyan
        case "1575": //老的 0575
            result = .shaoxing
        case "0891":
            result = .xizang
        case "0912":
            result = .yuling
        case "0510":
            result = .wuxi
        case "0731":
            result = .changsha
        case "0519":
            result = .changzhou
        case "010200":
            result = .card0
        case "010201":
            result = .card1
        case "010202":
            result = .card2
        case "010203":
            result = .card3
        default:
            result =  nil
        }
        return result
    }
}


import Foundation
import RxSwift

public enum Ycy04BindState : Int {
    case completed = 1
    case confirm = 2
    case exsitValidId = 3
    case notExsitValidId = 4
    case cancel = 5
}

public class NFCUTETool: NSObject {
    
    public static let shared: NFCUTETool = NFCUTETool()
    private let bag: DisposeBag = DisposeBag()
    
    /**
     SE 打开通道
     */
    public func openWriteChanel() -> Observable<Bool> {
        printLog("start open channle")
        let bytes: [UInt8] = [0x84, 0x00, 0x01]
        let openData =  Data.init(bytes: bytes, count: bytes.count)
        
        return BleOperator.shared.sendNFCData(writeData: openData, characteristic: 6101, duration: 3, endRecognition: nil)
            .map({ bleResponse -> Bool in
                guard let datas = bleResponse.datas, let data = datas.first else {
                    return false
                }
                let dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }
                let dataType = dataBytes[2]
                guard dataType == 2 else {
                    return false
                }
                printLog("open channle success =========")
                return true
            })
    }
    
    /**
     SE 关闭通道
     */
    public func closeWriteChanel() -> Observable<Bool> {
        
        printLog("start close chanel")
        let bytes: [UInt8] = [0x84, 0x00, 0x00]
        let closeData =  Data.init(bytes: bytes, count: bytes.count)
        return BleOperator.shared.sendNFCData(writeData: closeData, characteristic: 6101, duration: 3, endRecognition: nil)
            .map({ bleResponse -> Bool in
                guard let datas = bleResponse.datas, let data = datas.first else {
                    return false
                }
                let dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }
                let dataType = dataBytes[2]
                guard dataType == 4 else {
                    return false
                }
                printLog("finish close chanel")
                return true
            })
    }
    
    /**
     更新
     */
    public func updatedCard(_ installCardCodes: [String]) -> Observable<Bool> {
        
        var value: UInt64 = 0
        installCardCodes.forEach { (cityCode) in
            let index = CityIndex.getIndex(cityCode)
            if let i = index {
                value = value | (0x01 << i.rawValue)
            }
        }
        
        let cityByte1 = UInt8(((value>>56)&0xFF))
        let cityByte2 = UInt8(((value>>48)&0xFF))
        let cityByte3 = UInt8(((value>>40)&0xFF))
        let cityByte4 = UInt8(((value>>32)&0xFF))
        let cityByte5 = UInt8(((value>>24)&0xFF))
        let cityByte6 = UInt8(((value>>16)&0xFF))
        let cityByte7 = UInt8(((value>>8)&0xFF))
        let cityByte8 = UInt8(value&0xFF)
        
        printLog("执行YCY触发更新指令")
        let bytes: [UInt8] = [0x84, 0x04, cityByte8, cityByte7, cityByte6, cityByte5, cityByte4, cityByte3, cityByte2, cityByte1]
        let closeData =  Data.init(bytes: bytes, count: bytes.count)
        return BleOperator.shared.sendNFCData(writeData: closeData, characteristic: 6101, duration: 3)
            .map({ bleResponse -> Bool in
                guard let datas = bleResponse.datas, let data = datas.first else {
                    return false
                }
                let dataBytes = [UInt8](data)
                guard dataBytes.count >= 1 else {
                    return false
                }
                let dataType = dataBytes[1]
                guard dataType == 4 else {
                    return false
                }
                printLog("执行YCY触发更新城市成功=========")
                return true
            })
    }
    
    // 空白门禁卡备注名
    public func remarkNameAccessCard(_ data: Data) -> Observable<UInt8> {
        
        printLog("执行YCY更改门禁卡备注名指令")
        let bytes: [UInt8] = [0x84, 0x05]
        var closeData = Data.init(bytes: bytes, count: bytes.count)
        closeData.append(data)
        
        return BleOperator.shared.sendNFCData(writeData: closeData, characteristic: 6101, duration: 3, endRecognition: nil)
            .map({ bleResponse -> UInt8 in
                guard let datas = bleResponse.datas, let data = datas.first else {
                    return 0
                }
                let dataBytes = [UInt8](data)
                guard dataBytes.count >= 1 else {
                    return 0
                }
                let dataType = dataBytes[1]
                guard dataType == 5 else {
                    return 0
                }
                printLog("执行YCY更改门禁卡备注名指令=========")
                return 1
            })
    }
    
    // 模拟门禁卡开卡
    public func simulateAccessControlCardOpening() -> Observable<Data> {
        printLog("开始执行YCY模拟门禁卡开卡指令")
        let excuteCmd: [UInt8] = [0x84, 0x06]
        let excuteData =  Data.init(bytes: excuteCmd, count: excuteCmd.count)
        
        var totalLength: Int = 0
        var finalResultData: Data = Data()
        
        return Observable.create { (subscriber) -> Disposable in
                        
            BleOperator.shared.sendNFCData(writeData: excuteData, characteristic: 6101, duration: 30) { (data) -> Bool in
                
                return totalLength != 0 && finalResultData.count == totalLength
            }.map({ bleResponse -> UInt8 in
            
                guard let datas = bleResponse.datas, let data = datas.first else {
                    subscriber.onError(BleError.error("数据异常"))
                    return 0
                }
        
                let dataBytes = [UInt8](data)
                guard dataBytes.count > 3 else {
                    subscriber.onError(BleError.error("数据异常"))
                    return 0
                }
                
                if dataBytes[0] == 0x84 && dataBytes[1] == 6  {
                    totalLength = Int(dataBytes[3]) << 8 + Int(dataBytes[2])
                }

                guard dataBytes[0] == 0x84 && dataBytes[1] == 7 else {
                    return 0
                }
                
                let startIndex = data.index(data.startIndex, offsetBy: 2)
                let subDataRange: Range = startIndex..<data.endIndex
                let resultData = data.subdata(in: subDataRange)
                finalResultData.append(resultData)
                if finalResultData.count == totalLength {
                    
                    subscriber.onNext(finalResultData)
                    printLog("成功了执行YCY模拟门禁卡开卡指令")
                }
                
                return 1
            })
            .subscribe(onNext: { _ in
                printLog("")
            }, onError: { err in
                subscriber.onError(BleError.error("数据异常"))
            })
            .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func selectCRS(crs: String) -> Observable<Data> {
        let crsData = crs.hexToData
        let bytes: [UInt8] = [0x00, 0xA4, 0x04, 0x00]
        let headerData = Data.init(bytes: bytes, count: bytes.count)
        var contentData = Data()
        contentData.append(headerData)              // header
        var dataCount = crsData.count
        let dataCountData = Data(bytes: &dataCount, count: 1)
        contentData.append(dataCountData)           // data length
        contentData.append(crsData)                 // data
        return self.excute(contentData)
    }
    
    public func buildCommandDataAndWrite(_ command: NFCCommand) -> Observable<Data> {
        return self.excute(command.command.hexToData)
    }

    /**
     SE 执行指令
     */
    public func excute(_ commandData: Data) -> Observable<Data>  {
        printLog("excute SE cmd")
        let packageContentData = NFCCommandTool.shared.buildNFCCmdContent(commandData, startIndex: 0)
        return self.excuteCmdInfo(packageContentData)
            .flatMap({ _ in
                self.excuteCmd(packageContentData)
            })
    }
    
    /**
     SE 执行指令 已组装
     */
    public func excutePackage(_ commandData: Data) -> Observable<Data>  {
        printLog("excute SE cmd")
        return self.excuteCmdInfo(commandData)
            .flatMap({ _ in
                self.excuteCmd(commandData)
            })
    }
    
    /**
     SE 执行指令
     */
    public func excute(_ commandDatas: [Data]) -> Observable<Data>  {
        printLog("excute SE cmd")
        let packageContentData = NFCCommandTool.shared.buildCommandData(commandDatas, startIndex: 0)
        return self.excuteCmdInfo(packageContentData)
            .flatMap({ _ in
                self.excuteCmd(packageContentData)
            })
    }
    
    private func excuteCmd(_ commandData: Data) -> Observable<Data> {
        let excuteCmd: [UInt8] = [0x84, 0x02]
        let excuteData =  Data.init(bytes: excuteCmd, count: excuteCmd.count)
        
        var totalLength: Int = 0
        var finalResultData: Data = Data()
        
        return Observable.create { (subscriber) -> Disposable in
            BleOperator.shared.sendNFCData(writeData: excuteData, characteristic: 6101, duration: 8) { (data) -> Bool in

//            BleFacade.shared.write(commandData, 6101, 1, false, nil, 8, excuteData) { (data) -> Bool in
                return totalLength != 0 && finalResultData.count == totalLength
            }.map({ bleResponse -> Void in
                guard let datas = bleResponse.datas, let data = datas.first else {
                    subscriber.onError(BleError.error("数据异常"))
                    return
                }
                let dataBytes = [UInt8](data)
                guard dataBytes.count > 2 else {
                    subscriber.onError(BleError.error("数据异常"))
                    return
                }
                
                if dataBytes[0] == 0x84 && dataBytes[1] == 1 {
                    totalLength = Int(dataBytes[3]) << 8 + Int(dataBytes[2])
                }
                
                guard dataBytes[0] == 0x84 && dataBytes[1] == 2 else {
                    return
                }
                
                let startIndex = data.index(data.startIndex, offsetBy: 2)
                let subDataRange: Range = startIndex..<data.endIndex
                let resultData = data.subdata(in: subDataRange)
                finalResultData.append(resultData)
                if finalResultData.count == totalLength {
                    subscriber.onNext(finalResultData)
                    printLog("finish task =========")
                }
            })
            .subscribe()
            .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    private func excuteCmdInfo(_ commandData: Data) -> Observable<Bool> {
        let dataCount = commandData.count
        let dataCountByte1 = UInt8(((dataCount>>24)&0xFF))
        let dataCountByte2 = UInt8(((dataCount>>16)&0xFF))
        let dataCountByte3 = UInt8(((dataCount>>8)&0xFF))
        let dataCountByte4 = UInt8(dataCount&0xFF)
        
        let commandBytes = [UInt8](commandData)
        let crcNumber = checksum(bytes: commandBytes)
        let crcByte1 = UInt8(((crcNumber>>24)&0xFF))
        let crcByte2 = UInt8(((crcNumber>>16)&0xFF))
        let crcByte3 = UInt8(((crcNumber>>8)&0xFF))
        let crcByte4 = UInt8(crcNumber&0xFF)
        let excuteCmd: [UInt8] = [0x84, 0x01, dataCountByte4, dataCountByte3, dataCountByte2, dataCountByte1, crcByte4, crcByte3, crcByte2, crcByte1]
        let excuteData =  Data.init(bytes: excuteCmd, count: excuteCmd.count)
        
        return Observable.create { (subscriber) -> Disposable in
            BleOperator.shared.sendNFCData(writeData: excuteData, characteristic: 6101, duration: 3, endRecognition: nil)
                .map({ bleResponse -> Void in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("数据异常"))
                        return
                    }
                    let dataBytes = [UInt8](data)
                    guard dataBytes.count >= 3 else {
                        subscriber.onError(BleError.error("数据异常"))
                        return
                    }
                    let dataType = dataBytes[2]
                    guard dataType == 0 else {
                        subscriber.onError(BleError.error("执行指令失败"))
                        return
                    }
                    printLog("excute YCY cmd success =========")
                    subscriber.onNext(true)
                })
                .subscribe(onNext: nil, onError: { (error) in
                    subscriber.onError(error)
                })
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     选择 Aid  并 解析 校验
     */
    public func selectCardAidAndValidate(aid: String) -> Observable<String> {
        return self.selectCardToOperate(order: "00A40400", cardInfo: aid)                     // 选择 aid
            .flatMap({
                NFCCommandTool.shared.analysisCmdExcuteResultFromData($0)                                            // 解析
            })
            .flatMap({ excuteResults  in
                NFCCommandTool.shared.validateExcuteResult(result: excuteResults.first!.excuteResult)              // 验证
            })
    }
    
    /**
     选择 要操作的卡 可能存在多级选择， AID ->  1001 ->
     */
    public func selectCardToOperate(order: String, cardInfo: String) -> Observable<Data> {
        let aidData = cardInfo.hexToData
        let headerData = order.hexToData
        var contentData = Data()
        contentData.append(headerData)              // header
        var dataCount = aidData.count
        let dataCountData = Data(bytes: &dataCount, count: 1)
        contentData.append(dataCountData)           // data length
        contentData.append(aidData)                 // data
        
        return self.excute(contentData)
    }
    
    /**
        cityCode 判断是否要继续选择 还是 读余额
     */
    public func selectCardInfoOrGetBlance(aid: String, cityCode: String) -> Observable<String> {
        if cityCode == "0027" {
            return self.selectCardInfoAndValidate(cardInfo: "1001")
                .flatMap({ _ in
                    self.getBlanceAndValidate(aid: aid, service: .Blance)
                })
        } else if cityCode == "0574" {
            return self.selectCardInfoAndValidate(cardInfo: "3F01")
                .flatMap({ _ in
                    self.getBlanceAndValidate(aid: aid, service: .Blance)
                })
        }
        else {
            return self.getBlanceAndValidate(aid: aid, service: .Blance)
        }
    }
    //更改自定义卡名称
    public func selectCardInfOrGetBlance(aid: String, cityCode: String) -> Observable<String> {
        if cityCode == "0027" {
            return self.selectCardInfoAndValidate(cardInfo: "1001")
                .flatMap({ _ in
                    self.getBlanceAndValidate(aid: aid, service: .Blance)
                })
        } else if cityCode == "0574" {
            return self.selectCardInfoAndValidate(cardInfo: "3F01")
                .flatMap({ _ in
                    self.getBlanceAndValidate(aid: aid, service: .Blance)
                })
        }
        else {
            return self.getBlanceAndValidate(aid: aid, service: .Blance)
        }
    }
    
    /**
        读余额 武汉 宁波 需要 选中 Aid 后， 再选中指定的 卡信息，cardinfo 即对应的卡信息
     */
    public func selectCardInfoAndValidate(cardInfo: String) -> Observable<String> {
        return self.selectCardToOperate(order: "00A40000", cardInfo: cardInfo)
            .flatMap({
                NFCCommandTool.shared.analysisCmdExcuteResultFromData($0)                                            // 解析
            })
            .flatMap({ excuteResults  in
                NFCCommandTool.shared.validateExcuteResult(result: excuteResults.first!.excuteResult)              // 验证
            })
    }
    
    /**
     读取余额 并解析 校验
     */
    public func getBlanceAndValidate(aid: String, service: NFCService) -> Observable<String> {
        let blanceData = "805C000204".hexToData
        return self.excute(blanceData)
            .flatMap({
                NFCCommandTool.shared.analysisCmdExcuteResultFromData($0)                                            // 解析
            }).flatMap({ excuteResults  in
                NFCCommandTool.shared.validateExcuteResult(result: excuteResults.first!.excuteResult)              // 验证
            })
    }
    
    /**
    CityCode 判断是否要继续选择 还是 读状态
     
     1: 宁波需要先选择 3F01
     2: 武汉读状态指令为 00B08A0000
     
     */
    public func selectCardInfoOrGetState(aid: String, cityCode: String) -> Observable<String> {
        // 宁波 和 哈尔滨
        if cityCode == "0574" {
            return self.selectCardInfoAndValidate(cardInfo: "3F01")
                .flatMap({ _ in
                    self.getStateAndValidate(aid: aid, order: "00B0950000")
                })
        } else {
            if cityCode == "0027" {
                return self.getStateAndValidate(aid: aid, order: "00B08A0000")
            } else {
                return self.getStateAndValidate(aid: aid, order: "00B0950000")
            }
        }
    }
    
    /**
     读取状态 并解析 校验
     */
    public func getStateAndValidate(aid: String, order: String) -> Observable<String> {
        let blanceData = order.hexToData
        return self.excute(blanceData)
                    .flatMap({
                        NFCCommandTool.shared.analysisCmdExcuteResultFromData($0)                                            // 解析
                    }).flatMap({ excuteResults  in
                        NFCCommandTool.shared.validateExcuteResult(result: excuteResults.first!.excuteResult)              // 验证
                    })
    }
    
}
