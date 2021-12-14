//
//  NFCLSTool.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/27.
//

import Foundation
import RxCocoa
import RxSwift

enum NFCServiceOperate: UInt32 {
    case None = 0x00
    case Start
    case End = 0xFF
}


class NFCPBTool: NSObject {

    static let shared: NFCPBTool = NFCPBTool()
    private let bag: DisposeBag = DisposeBag()

    private override init() {
        super.init()
    }
    
    /**
     告知SE 开始 某业务
     */
    func openWriteChanel(service: NFCService) -> Observable<Bool> {
        printLog("open Write Chanel")
        return self.handleOperateEvent(service: service, operate: .Start)
    }
    
    /**
     告知SE 结束 某业务
     */
    func closeWriteChanel(service: NFCService) -> Observable<Bool> {
        printLog("执行关闭通道指令")
        return self.handleOperateEvent(service: service, operate: .End)
    }
    
    /**
     执行 告知 se 开始 和 结束 业务
     */
    func handleOperateEvent(service: NFCService, operate: NFCServiceOperate) -> Observable<Bool> {

        let bytes: [UInt8] = []

        let contentData =  Data.init(bytes: bytes, count: bytes.count)
        return Observable.create { (subscriber) -> Disposable in
//            NFCPBTool.shared.serializePbObj(nfcCmd:
//                                                PBModel.buildNfcOperateEvent(service: service,
//                                                              operate: operate,
//                                                              nfcData: contentData)
//            )
            
            NFCPBTool.shared.closeWriteChanel(service: .Blance)
            
            .subscribe { (hlCmds) in
//                guard let firstCmd = hlCmds.first, firstCmd.setNfcOperate.hasMNfcData else {
//                    subscriber.onError(NFCError.error("执行开启或关闭通道数据异常"))
//                    return
//                }
                
                printLog("exceult cmd success")

//                let nfcDataByte = [UInt8](firstCmd.setNfcOperate.mNfcData)
//                let resultString = nfcDataByte.hexString
//                let predicate = NSPredicate(format: "SELF MATCHES %@", ".*9000$")
//                let excuteFlag = predicate.evaluate(with: resultString)
                
                //暂时执行假数据 只要有返回就表示通道打开完成
                subscriber.onNext(true)
                subscriber.onCompleted()
                
//                if excuteFlag {
//                    subscriber.onNext(excuteFlag)
//                    subscriber.onCompleted()
//                } else {
//                    subscriber.onError(NFCError.error("startWriteChanel validateExcuteResult 数据校验不通过"))
//                }
            } onError: { (error) in
                printLog("通道指令执行失败")
                subscriber.onError(error)
            }
            .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     初始化 hl_cmds 对象
     */
    func buildCmdWithType(_ cmdType: hl_cmds.cmd_t) -> hl_cmds {
        var tcmd = hl_cmds()
        tcmd.seconds = UInt32(Date().timeIntervalSince1970)
        tcmd.response = false
        tcmd.timezone = Int32(TimeZone.current.secondsFromGMT() / (60 * 60))
        tcmd.cmd = cmdType
        return tcmd
    }
    
    /**
     构建 NFC 操作 hl_cmds
     */
    func buildNfcOperateEvent(service: NFCService, operate: NFCServiceOperate, nfcData: Data) -> hl_cmds {
        
        let writeDataBytes = [UInt8](nfcData)
        
        printLog("will config data : \(writeDataBytes.hexString)")
        
        var info = set_nfc_operate_t()
        info.mNfcOperateCode = service.rawValue
        info.mNfcErrCode = 0
        info.mNfcSubOperateCode = operate.rawValue
        info.mNfcData = nfcData
        var setNfcCmd = self.buildCmdWithType(.cmdSetNfcOperateCode)
        setNfcCmd.setNfcOperate = info
        return setNfcCmd
    }
    
    /**
     构建 NFC 操作 hl_cmds
     */
    func buildNfcSyncCityList(service: NFCService, operate: NFCServiceOperate, cityCodes: UInt64) -> hl_cmds {
        var info = set_nfc_operate_t()
        info.mNfcOperateCode = service.rawValue
        info.mNfcErrCode = 0
        info.mNfcSubOperateCode = operate.rawValue
        info.mNfcData = Data.init()
        info.mNfcCity = cityCodes
        var setNfcCmd = self.buildCmdWithType(.cmdSetNfcOperateCode)
        setNfcCmd.setNfcOperate = info
        return setNfcCmd
    }
    
    /**
        序列化 hl_cmds  pb 对象
     */
//    func serializePbObj(nfcCmd: hl_cmds, expectNum: Int = 1, duration: Int = 20, _ endRecognition: ((Any) -> Bool)? = nil) -> Observable<[hl_cmds]> {
//        return Observable.create { [weak self] (observer) -> Disposable in
//            guard let `self` = self else {
//                observer.onError(BleError.error("self == nil"))
//                return Disposables.create()
//            }
//            var tpbData: Data?
//            do {
//                tpbData = try nfcCmd.serializedData()
//            } catch {
//                print("cmd to pb: \(error)")
//                observer.onError(BleError.error("NFC PB 序列化错误"))
//                return Disposables.create()
//            }
//
//            guard let nfcPbData = tpbData else {
//                observer.onError(BleError.error("NFC PB 序列化数据 为 nil"))
//                return Disposables.create()
//            }
//
//            do {
//
//                try self.buildPBContent(nfcPbData, expectNum: expectNum, ackInInterval: true, duration: duration, cmdType: nfcCmd.cmd, endRecognition: endRecognition)
//                    .subscribe(onNext: { (bleResponse) in
//                        guard let pbDatas = bleResponse.pbDatas else {
//                            observer.onError(BleError.error("Nfc Pb Data 异常"))
//                            return
//                        }
//                        observer.onNext(pbDatas)
////                        observer.onCompleted()
//                    }, onError: { (error) in
//                        observer.onError(error)
//                    })
//                    .disposed(by: self.bag)
//
//            } catch {
//                observer.onError(BleError.error("\(error.localizedDescription)"))   // 蓝牙错误
//            }
//            return Disposables.create()
//        }
//    }
    
    
    /*
     解析出设备返回 Pb content Data
     */
    func analyticalPbData(hlObjs: [hl_cmds]) -> Observable<[Data]> {
        return Observable.create { (observer) -> Disposable in
            guard hlObjs.count > 0 else {
                observer.onError(BleError.error("analytical pbs is empty "))
                return Disposables.create()
            }
            let datas = hlObjs.filter({
                print("xxx1: \($0.cmd)")
                return $0.cmd == .cmdSetNfcOperateCode
            })
            .filter({
                print("xxx1: \($0.setNfcOperate.hasMNfcData)")
                return $0.setNfcOperate.hasMNfcData
            })
            .filter({
                return $0.setNfcOperate.mNfcErrCode == 0
            })
            .map({
                return $0.setNfcOperate.mNfcData
            })
            
            guard datas.count == hlObjs.count else {
                observer.onError(BleError.error("analytical pb content data not == \(datas.count) : \(hlObjs.count) "))
                return Disposables.create()
            }
            observer.onNext(datas)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    
    func buildCommandPbAndWrie(_ commands: [NFCCommand]) -> Observable<[hl_cmds]> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else {
                observer.onError(BleError.error("self == nil"))
                return Disposables.create()
            }
            commands.forEach { (p) in
                printLog("will send Command: \(p.command)")
            }
            let commandData = NFCCommandTool.shared.buildCommandData(commands)           // 构建 command data
            let comandDataByte = [UInt8](commandData)
            printLog("Command config ABxxCD: \(comandDataByte.hexString)")
            var info = set_nfc_operate_t()
            info.mNfcOperateCode = 1                        // code 操作的类型  【开卡、充值】等
            info.mNfcData = commandData
            info.mNfcErrCode = 0
            
            var setNfcCmd = NFCPBTool.shared.buildCmdWithType(.cmdSetNfcOperateCode)
            setNfcCmd.setNfcOperate = info
            
            var tpbData: Data?
            do {
                tpbData = try setNfcCmd.serializedData()
            } catch {
                observer.onError(BleError.error("NFC PB 序列化错误"))
                return Disposables.create()
            }
            guard let nfcPbData = tpbData else {
                observer.onError(BleError.error("NFC PB 序列化数据 为 nil"))
                return Disposables.create()
            }
            do {
                
                try NFCPBTool.shared.buildPBContent(nfcPbData, expectNum: 1, ackInInterval: true, duration: 20, cmdType: .cmdSetNfcOperateCode)
                    .subscribe(onNext: { (bleResponse) in
                        guard let pbDatas = bleResponse.pbDatas else {
                            observer.onError(BleError.error("Nfc Pb 蓝牙返回数据异常"))
                            return
                        }
                        observer.onNext(pbDatas)
                        observer.onCompleted()
                    }, onError: { (error) in
                        observer.onError(error)
                    })
                    .disposed(by: self.bag)
                
            } catch {
                observer.onError(BleError.error("BLE error: \(error.localizedDescription)"))   // 蓝牙错误
            }
            return Disposables.create()
        }
    }
    
    
    /**
        将 Command 组装固定格式，并转 PB
     */
    func buildCommandPbAndWrite(_ commands: [NFCCommand]) -> Observable<[hl_cmds]> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let `self` = self else {
                observer.onError(BleError.error("self == nil"))
                return Disposables.create()
            }
            commands.forEach { (p) in
                printLog("will send Command: \(p.command)")
            }
            let commandData = NFCCommandTool.shared.buildCommandData(commands)           // 构建 command data
            let comandDataByte = [UInt8](commandData)
            printLog("Command config ABxxCD: \(comandDataByte.hexString)")
            var info = set_nfc_operate_t()
            info.mNfcOperateCode = 1                        // code 操作的类型  【开卡、充值】等
            info.mNfcData = commandData
            info.mNfcErrCode = 0
            
            var setNfcCmd = NFCPBTool.shared.buildCmdWithType(.cmdSetNfcOperateCode)
            setNfcCmd.setNfcOperate = info
            
            var tpbData: Data?
            do {
                tpbData = try setNfcCmd.serializedData()
            } catch {
                observer.onError(BleError.error("NFC PB 序列化错误"))
                return Disposables.create()
            }
            guard let nfcPbData = tpbData else {
                observer.onError(BleError.error("NFC PB 序列化数据 为 nil"))
                return Disposables.create()
            }
            do {
                
                try NFCPBTool.shared.buildPBContent(nfcPbData, expectNum: 1, ackInInterval: true, duration: 20, cmdType: .cmdSetNfcOperateCode)
                    .subscribe(onNext: { (bleResponse) in
                        guard let pbDatas = bleResponse.pbDatas else {
                            observer.onError(BleError.error("Nfc Pb 蓝牙返回数据异常"))
                            return
                        }
                        observer.onNext(pbDatas)
                        observer.onCompleted()
                    }, onError: { (error) in
                        observer.onError(error)
                    })
                    .disposed(by: self.bag)
                
            } catch {
                observer.onError(BleError.error("BLE error: \(error.localizedDescription)"))   // 蓝牙错误
            }
            return Disposables.create()
        }
    }
    
    /**
        组装 协议 + PB 内容 并执行蓝牙发送
     */
    func buildPBContent(_ commandData: Data, expectNum: Int = 1, ackInInterval: Bool = false, duration: Int = 20, cmdType: hl_cmds.cmd_t?,  endRecognition: ((Any) -> Bool)? = nil) throws -> Observable<BleResponse> {
        //MARK: 构建最终需要发送的Data
        let commandContentData: Data = commandData
        var contentData = Data()
        let timeout: UInt8 = 5
        let headerBytes : [UInt8] = [0x7E, 0x6D, timeout]      //header  and  timeout
        let headerData = Data.init(bytes: headerBytes, count: headerBytes.count)
        contentData.append(headerData)
        
        var dataCount = commandContentData.count
        let dataCountData = Data(bytes: &dataCount, count: 2)   // pb data length
        contentData.append(dataCountData)
        
        var commandContentBytes = [UInt8](commandContentData)
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
        let data = contentData
//        return BleOperator.shared.sendNFCData(writeData: data, characteristic:0, expectNum:expectNum, ackInInterval:ackInInterval, cmdType:cmdType, duration:duration, typeData: data, endRecognition:endRecognition)
        
        return BleFacade.shared.write(contentData, "11")
        
//        return BleOperator.shared.sendNFCData(writeData: <#T##Data#>, characteristic: <#T##Int#>, duration: <#T##Int#>, endRecognition: <#T##((Any) -> Bool)?##((Any) -> Bool)?##(Any) -> Bool#>)
    }
    



        
}


