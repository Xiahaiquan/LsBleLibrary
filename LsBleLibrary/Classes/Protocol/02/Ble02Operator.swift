//
//  Ble02Facade.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/4.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift

public class Ble02Operator: NSObject {
    public static let shared: Ble02Operator = Ble02Operator()
    
    var bleFacade: BleFacadeable?
    
    let bag: DisposeBag = DisposeBag()
    public var dataObserver: Observable<BleBackData>?
    private var dataObserverPublishRelay: PublishRelay<BleBackData> = PublishRelay()
    
    var uteFunc: UTEFunctionTag?
    
    private override init() {
        super.init()
        self.dataObserver = self.dataObserverPublishRelay.asObservable()
    }
    
    public func configFacade(_ facade: BleFacadeable) {
        self.bleFacade = facade
        self.startObserver()
        
    }
}

extension Ble02Operator {
    
    func startObserver() {
        
        guard let obser = self.bleFacade?.dataObserver else {
            return
        }
        obser.subscribe { (data) in
            if let value = data as? UTEOriginalData {
                self.routerData(value)
            }
        } onError: { (error) in
            print("observer: \(error)")
        }
        .disposed(by: self.bag)
    }
    
    func routerData(_ routerData: UTEOriginalData) {
        
        let data = routerData.data
        let acceptBytes = [UInt8](data)
        let command = acceptBytes[0]
        
        //依据服务，判断的返回指令
        if routerData.from == Characteristic02.char6101 && acceptBytes.count == 2 {
            // 最大可写值
            let maxWriteValue = Int(Int(data[0]) << 8) + Int(data[1])
            mtu = Int(maxWriteValue)
        
            self.dataObserverPublishRelay.accept(BleBackData(type: .u6101maxvalue, data: UInt32(maxWriteValue)))

            return
        }
        
        //08000000000000076D63C13E590B0051704B254C
        if routerData.from == Characteristic02.char33F1 && acceptBytes.count == 20 {
            // 支持的功能列表
            guard let functionTag = self.analysisFunctionTag(data) else {
                return
            }
            Ble02Operator.shared.uteFunc = functionTag
            self.dataObserverPublishRelay.accept(BleBackData(type: .functionTag, data: functionTag))
            return
        }
    
        //依据指令，判断的返回指令
        switch command {
        case LS02CommandType.requestRealtimeSteps.rawValue:
            guard let realtimesport = self.analysisSport(data) else {
                return
            }
            
            self.dataObserverPublishRelay.accept(BleBackData(type: .stepUpdate, data: realtimesport))
            
        case LS02CommandType.sevenDaysHistorySleepingDataReceive.rawValue:
            let sleepData = self.analysisSleep(data)
            
            self.dataObserverPublishRelay.accept(BleBackData(type: .sleepdetail, data: sleepData))
        case LS02CommandType.requestRealtimeHeartRate.rawValue:
            let realtimeHrValue = self.analysisRealtimeHr(data)
            self.dataObserverPublishRelay.accept(BleBackData(type: .realtimehr, data: CurrentUIHR.init(act: UInt32(realtimeHrValue))))
        case LS02CommandType.historyHeartRateData.rawValue:
            let type = acceptBytes[1]
            if type == 4 { //返回手环当天心率最大值和最小值
                guard let statisticshrHrValue = self.analysisStatisticshrHr(data) else {
                    return
                }
                
                let uiHR = CurrentUIHR.init(avg: UInt32(statisticshrHrValue.avg), max: UInt32(statisticshrHrValue.max), min: UInt32(statisticshrHrValue.max), datetime: statisticshrHrValue.datetime)
                
                self.dataObserverPublishRelay.accept(BleBackData(type: .realtimehr, data: uiHR))
            } else if type == 3 { //每隔十分钟返回当前测试结果的心率数据
                guard let t10MinuterHrValue = self.analysis10MinuteHr(data) else {
                    return
                }
                
                self.dataObserverPublishRelay.accept(BleBackData.init(type: .statistics10Mhr, data: t10MinuterHrValue))
            } else if type == 0xFA { //同步心率历史数据指令
                guard let historyData = self.analysisHistoryHr(data) else {
                    return
                }
                self.dataObserverPublishRelay.accept(BleBackData(type: .heartratedetail, data: historyData))
            }
        case LS02CommandType.getWatchSkinTheme.rawValue, 0x26:
            //FIXME: 这里还要解析要发送表盘的具体信息
            if acceptBytes.count == 3 && acceptBytes[1] == LS02Placeholder.three.rawValue {
                
                self.dataObserverPublishRelay.accept(BleBackData(type: .cloudwatchface, data: (3, Int(acceptBytes[2]))))
                
            }
        case LS02CommandType.multiSport.rawValue:
            if acceptBytes.count == 14 {
                // 手机主动开启运动时， 运动数据会主动上传
                guard let sportModelInfo = self.analysisSportModelUpload(data) else {
                    return
                }
                //                19 FA 07 E5 0C 18 13 05 00 00
                let item = LSSportRealtimeItem.init(hr: UInt32(sportModelInfo.hr),
                                                    status: .unknown,
                                                    sportModel: sportModelInfo.model,
                                                    step: UInt32(sportModelInfo.step),
                                                    calories: UInt32(sportModelInfo.cal),
                                                    distance: UInt32(sportModelInfo.distance),
                                                    timeSeond: 0,
                                                    spacesKm: UInt32(sportModelInfo.pace),
                                                    count: UInt32(sportModelInfo.count))
                
                self.dataObserverPublishRelay.accept(BleBackData(type: .realtimeSporthr, data: item))
            } else if acceptBytes.count == 13 {
                // 运动设备状态变更 暂停、恢复等
                guard let sportModelInfo = self.analysisSportModelStateChange(data) else {
                    return
                }
                
                let item = LSSportRealtimeItem.init(status: sportModelInfo.state, sportModel: sportModelInfo.model, step: UInt32(sportModelInfo.step), calories: UInt32(sportModelInfo.cal), distance: UInt32(sportModelInfo.distance), timeSeond: 0, spacesKm: UInt32(sportModelInfo.pace), interval: sportModelInfo.interval)
                self.dataObserverPublishRelay.accept(BleBackData.init(type: .realtimeSporthr, data: item))
                
            } else if acceptBytes.count == 4 {
                //手表返回的运动开关状态（结束）
                let byte1 = acceptBytes[1]
                let byte2 = acceptBytes[2]
                let byte3 = acceptBytes[3]
                
                guard byte1 == 0x00 && byte2 == 0x01 && byte3 == 0x06 else {
                    return
                }
                
                let item = LSSportRealtimeItem.init(status: .stop, isStatueOnly: true)
                
                self.dataObserverPublishRelay.accept(BleBackData.init(type: .realtimeSporthr, data: item))
            }
            
        case LS02CommandType.bindingWatch.rawValue, LS02Placeholder.four.rawValue:
            let bindState = LsBleBindState.init(uteType: Int(acceptBytes[2]))
            
            
            self.dataObserverPublishRelay.accept(BleBackData(type: .bindState, data: bindState))
            
        case LS02CommandType.gpsCommand.rawValue:
            let type = acceptBytes[1]
            if type == 1 {
                guard let value = self.analysisGPSRealtime(data) else {
                    return
                }
                self.dataObserverPublishRelay.accept(BleBackData(type: .realtimeGPS, data: value))
            }
            
            let state = Ls02ReadyUpdateAGPSStatus.init(rawValue: acceptBytes[2])
            self.dataObserverPublishRelay.accept(BleBackData(type: .gpsUpgradeStatus, data: state))
        case LS02CommandType.historySpo2Data.rawValue:
            
            let type = acceptBytes[1]
            
            if acceptBytes.count == 4 {
                var valueSpo2: UInt8?
                if type == 0x11, acceptBytes[2] == 0x00 {
                    valueSpo2 = acceptBytes[3] //当前 BLE 测试完成的血氧数据，范围 89~99%
                }
                if type == 0x00, acceptBytes[2] == 0x00 {
                    valueSpo2 = acceptBytes[3]
                }
                self.dataObserverPublishRelay.accept(BleBackData(type: .spo2Update, data: valueSpo2))
            }
            
            if acceptBytes.count == 2 {
                if type == 0xFD {
                    self.dataObserverPublishRelay.accept(BleBackData(type: .spo2Update, data: LsSpo2Status.timeout))
                }
                if type == 0x0C {
                    self.dataObserverPublishRelay.accept(BleBackData(type: .spo2Update, data: LsSpo2Status.delete))
                }
            }
            
            if type == 0xFA {
                
            }
            
        case LS02CommandType.requestFunctionSetAndStatus.rawValue:
            
            guard let value = analysisWatchFunctionAndStateValue(data: data) else {
                return
            }
            self.dataObserverPublishRelay.accept((BleBackData(type: .shortcutSwitchStatus, data: value)))
            
        case LS02CommandType.watchBtnFunction.rawValue:
            
            guard let value = analysisWatchBtnFunction(data: data) else {
                return
            }
            
            self.dataObserverPublishRelay.accept(BleBackData(type: .findPhone, data: value))
            
            
        default:
            print("有未知的数据")
            
            self.dataObserverPublishRelay.accept(BleBackData(type: .unknow, data: routerData))
        }
    }
}

//MARK: 绑定和解除绑定
extension Ble02Operator: BleCommandProtocol {
    
    public func getmtu() ->Observable<Monitored> {
        
        return Observable.create { observer in
            self.dataObserverPublishRelay.filter { arg in
                return arg.type == .u6101maxvalue
            }.subscribe { arg in
                observer.onNext(arg.data as? UInt32 ?? 0)
                observer.onCompleted()
            } onError: { err in
                observer.onError(err)
            }.disposed(by: self.bag)

            Ble02Operator.shared.readValue(channel: .ute6101)
            
            return Disposables.create()
        }
    }
    public func bindDevice(userId: UInt32,
                                     gender: LsGender,
                                     age: UInt32,
                                     height: UInt32,
                                     weight: UInt32,
                                     wearstyle: WearstyleEnum) ->Observable<LSDeviceModel> {
        let bindCmd: [UInt8] = [LS02CommandType.bindingWatch.rawValue,
                                LS02Placeholder.two.rawValue,
                                UInt8((userId >> 24) & 0xFF),
                                UInt8((userId >> 16) & 0xFF),
                                UInt8((userId >> 8) & 0xFF),
                                UInt8(userId & 0xFF)]
        let bindData = Data.init(bytes: bindCmd, count: bindCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            
            self.bleFacade?.write(bindData, 0,LS02CommandType.bindingWatch.name, 30, { (data) in
                let bindBytes = [UInt8](data)
                guard bindBytes.count >= 3 else {
                    return false
                }
                return bindBytes[0] == 0x20 && bindBytes[1] == 4 && bindBytes[2] == 1               // 1 表示绑定完成
            })
                .subscribe { (bleResponse) in
                    
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let bindBytes = [UInt8](data)
                    guard bindBytes.count >= 3, bindBytes[0] == 0x20 else {
                        subscriber.onError(BleError.error("设备返回数据不匹配"))
                        return
                    }
                    let bindState = LsBleBindState(uteType: Int(bindBytes[2]))
                    
                    print("Ble02Operator.bindDevice", bindState)

                    subscriber.onNext(LSDeviceModel.init(bindStatus: bindState))
                    if bindState == .success {
                        return
                    }
                    
                    if bindState == .confirm {
                        
                        print("is the first bind")
                        
                        Observable.just(()).delay(.seconds(10), scheduler: MainScheduler.instance)
                            .flatMap { _ in
                                BleFacade.shared.connecter.connect(duration: 10)
                            }
                            .subscribe(onNext: {  (state, response) in
                                if state == .connectSuccessed {
                                    print("已连接  等待扫描服务及特征")
                                    BleFacade.shared.bleDevice?.peripheral = response?.peripheral
                                    
                                } else if (state == .dicoverChar) {
                                    BleFacade.shared.bleDevice?.updateCharacteristic(characteristic: response?.characteristics, statusCallback: { status in
                                        if status {
                                            self.bindDevice(userId: userId, gender: gender, age: age, height: height, weight: weight, wearstyle: wearstyle)
                                                .subscribe { (state) in
                                                    printLog("\(state)")
                                                    if state.bindStatus == .success {
                                                        print("第一次绑定完成了")
                                                        subscriber.onNext(LSDeviceModel.init(bindStatus: .success))
                                                        subscriber.onCompleted()
                                                    }
                                                } onError: { (error) in
                                                    print("bind device error 3: \(error)")
                                                }
                                                .disposed(by: self.bag)
                                        }
                                    })
                                    if ((BleFacade.shared.bleDevice?.connected) != nil) { BleFacade.shared.connecter.finish() }
                                    print("发现了当前设备的服务")
                                }
                            }, onError: { error in
                                
                                print("error")
                            }, onCompleted: {
                                print("onCompleted")
                            }).disposed(by: self.bag)
                        
                        
                    }
                    
                } onError: { (error) in
                    print("bindDevice, err", error)
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    /**
     无结果返回， 会断连
     */
    public func unBindDevice(mode: UInt32) -> Observable<Bool> {
        let resetCmd: [UInt8] = [LS02CommandType.requstFactoryReset.rawValue, LS02Placeholder.zero.rawValue]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        self.bleFacade?.write(resetData, 0,LS02CommandType.requstFactoryReset.name, 3, nil)
            .subscribe { (bleResponse) in
                print("bleResponse", bleResponse)
            } onError: { (error) in
                print("unBindDevice", error)
            }
            .disposed(by: self.bag)
        return Observable.just(true)
    }
}

//MARK: 运动和睡眠部分
extension Ble02Operator {
    
    /**
     获取 心率历史数据
     */
    public func getHistoryHeartrateData(dateByFar: Date) -> Observable<(datetime: String, heartRateDatas: [UInt8])> {
        // 加时间
        let yearByte1 = UInt8(((dateByFar.day()>>8)&0xFF))
        let yearByte2 = UInt8(dateByFar.day()&0xFF)
        let getCmd: [UInt8] = [LS02CommandType.historyHeartRateData.rawValue, 0xFA, yearByte1, yearByte2,
                               UInt8(dateByFar.month()),
                               UInt8(dateByFar.day()),
                               UInt8(dateByFar.hour())]
        
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        var crcN: UInt8 = 0
        return Observable.create { (subscriber) -> Disposable in
            var crc: UInt8 = 0
            self.bleFacade?.write(getData, 0,LS02CommandType.historyHeartRateData.name,8,  { (data) -> Bool in
                var dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }
                
                let dataType = dataBytes[1]
                guard dataType != 1, dataType != 2,  dataType != 3, dataType != 4 else {
                    return false
                }
                
                if dataBytes.count == 3 {
                    return dataBytes[0] == LS02CommandType.historyHeartRateData.rawValue && dataBytes[1] == LS02CommandType.generalEnds.rawValue && crc == dataBytes[2]      // 结束标识
                } else {
                    dataBytes.removeFirst()
                    dataBytes.forEach { (v) in
                        crc = crc ^ v
                    }
                    return false
                }
            })
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        return
                    }
                    var dataBytes = [UInt8](data)
                    guard dataBytes.count >= 3 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    
                    let dataType = dataBytes[1]
                    guard dataType != 1, dataType != 2,  dataType != 3, dataType != 4 else {
                        return
                    }
                    
                    if dataBytes.count == 3 {
                        if dataBytes[0] == 0x18 && dataBytes[1] == 0xFD && crcN == dataBytes[2] {
                            subscriber.onCompleted()
                        }
                    } else {
                        dataBytes.removeFirst()
                        dataBytes.forEach { (v) in              // CRC 计算
                            crcN = crcN ^ v
                        }
                        guard let heartRateItem = self.analysisHistoryHr(data) else {
                            return
                        }
                        subscriber.onNext(heartRateItem)
                    }
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    public func getHistorySp02Data(dateByFar: Date) -> Observable<(datetime: String, spo2s: [UInt8])> {
        // 加时间
        let yearByte1 = UInt8(((dateByFar.hour()>>8)&0xFF))
        let yearByte2 = UInt8(dateByFar.hour()&0xFF)
        let getCmd: [UInt8] = [LS02CommandType.historySpo2Data.rawValue, 0xFA, yearByte1, yearByte2,
                               UInt8(dateByFar.month()),
                               UInt8(dateByFar.day()),
                               UInt8(dateByFar.hour())]
        
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        var crcN: UInt8 = 0
        return Observable.create { (subscriber) -> Disposable in
            var crc: UInt8 = 0
            self.bleFacade?.write(getData, 0,LS02CommandType.historySpo2Data.name,8,  { (data) -> Bool in
                var dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }
                
                let dataType = dataBytes[1]
                guard dataType != 1, dataType != 2,  dataType != 3, dataType != 4 else {
                    return false
                }
                
                if dataBytes.count == 3 {
                    return dataBytes[0] == LS02CommandType.historySpo2Data.rawValue && dataBytes[2] == 0xFA && crc == dataBytes[2]      // 结束标识
                } else {
                    dataBytes.removeFirst()
                    dataBytes.forEach { (v) in
                        crc = crc ^ v
                    }
                    return false
                }
            })
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        return
                    }
                    var dataBytes = [UInt8](data)
                    guard dataBytes.count >= 3 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    
                    let dataType = dataBytes[1]
                    guard dataType != 1, dataType != 2,  dataType != 3, dataType != 4 else {
                        return
                    }
                    
                    if dataBytes.count == 3 {
                        if dataBytes[0] == LS02CommandType.historySpo2Data.rawValue && dataBytes[2] == 0xFA && crcN == dataBytes[2] {
                            subscriber.onCompleted()
                        }
                    } else {
                        dataBytes.removeFirst()
                        dataBytes.forEach { (v) in              // CRC 计算
                            crcN = crcN ^ v
                        }
                        guard let spo2Item = self.analysisHisorySpor(data: data) else {
                            return
                        }
                        subscriber.onNext(spo2Item)
                    }
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    /**
     获取 7 天运动历史数据
     */
    public func getHistoryDayData(dateByFar: Date) -> Observable<Ls02SportInfo> {
        
        let yearByte1 = UInt8(((dateByFar.hour()>>8)&0xFF))
        let yearByte2 = UInt8(dateByFar.hour()&0xFF)
        let getCmd: [UInt8] = [LS02CommandType.requestSevenDaysHistorySteps.rawValue, yearByte1, yearByte2,
                               UInt8(dateByFar.month()),
                               UInt8(dateByFar.day()),
                               UInt8(dateByFar.hour())]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        var crcN: UInt8 = 0
        return Observable.create { (subscriber) -> Disposable in
            var crc: UInt8 = 0
            self.bleFacade?.write(getData,0,LS02CommandType.requestSevenDaysHistorySteps.name, 8,  { (data) -> Bool in
                var dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }
                if dataBytes.count == 3 {
                    return dataBytes[0] == LS02CommandType.requestSevenDaysHistorySteps.rawValue &&
                    dataBytes[1] == LS02CommandType.generalEnds.rawValue &&
                    crc == dataBytes[2]      // 结束标识
                } else {
                    dataBytes.removeFirst()
                    dataBytes.forEach { (v) in
                        crc = crc ^ v
                    }
                    return false
                }
            })
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        return
                    }
                    var dataBytes = [UInt8](data)
                    guard dataBytes.count >= 3 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    if dataBytes.count == 3 {
                        if dataBytes[0] == LS02CommandType.requestSevenDaysHistorySteps.rawValue &&
                            dataBytes[1] == LS02CommandType.generalEnds.rawValue &&
                            crcN == dataBytes[2] {
                            subscriber.onCompleted()
                        }
                    } else {
                        dataBytes.removeFirst()
                        dataBytes.forEach { (v) in          // CRC 计算
                            crcN = crcN ^ v
                        }
                        guard let sport = self.analysisSport(data) else {
                            return
                        }
                        subscriber.onNext(sport)
                    }
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     获取 7 天睡眠历史数据
     
     6001 发送 1d 01,   6002 返回 日期 和数量A。
     6102 返回数量A 条  1E xxxxxxxxxxxx
     */
    public func getHistorySleepData(dateByFar: Date) -> Observable<[Ls02SleepInfo]> {
        
        let yearByte1 = UInt8(((dateByFar.hour()>>8)&0xFF))
        let yearByte2 = UInt8(dateByFar.hour()&0xFF)
        let getCmd: [UInt8] = [LS02CommandType.sevenDaysHistorySleepingDataSend.rawValue, 0x01,yearByte1, yearByte2,
                               UInt8(dateByFar.min()),
                               UInt8(dateByFar.day()),
                               UInt8(dateByFar.hour())]
        
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        
        var sleepDetailBag: DisposeBag!         // 递归上传睡眠， 控制释放
        var sleepDatas: [Ls02SleepInfo] = []
        
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.sevenDaysHistorySleepingDataSend.name, 8, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let dataBytes = [UInt8](data)
                    
                    var sleepDetail: [Ls02SleepItem] = []
                    if dataBytes.count == 2 {
                        if dataBytes[0] == 0x1D && dataBytes[1] == 0x02 {
                            subscriber.onNext(sleepDatas)                   // 所有数据上传结束
                            subscriber.onCompleted()
                        }
                    }
                    
                    guard dataBytes.count >= 7 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    sleepDetailBag = DisposeBag()
                    
                    let year = (Int(dataBytes[2]) << 8) + Int(dataBytes[3])
                    let month = Int(dataBytes[4])
                    let day = Int(dataBytes[5])
                    let dataCount = Int(dataBytes[6])
                    
                    // 监听数据上传
                    guard let obser = BleHandler.shared.dataObserver else {
                        return
                    }
                    obser.subscribe { (p) in
                        switch p {
                        case let (_, sleepItems) as (MonitoredType, [Ls02SleepItem]):            // 监听感兴趣的数据类型
                            sleepDetail.append(contentsOf: sleepItems)
                            if sleepDetail.count == dataCount {         // 收到数据 与 期待数据 一致
                                sleepDatas.append(Ls02SleepInfo(year: year, month: month, day: day, dataCount: dataCount, sleepItems: sleepDetail))
                            }
                        default :
                            print("其他上报数据1...")
                        }
                    } onError: { (error) in
                        print("异常")
                    }
                    .disposed(by: sleepDetailBag)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    /**
     解析主动读取的历史数据  1807E6   03 17 0E 4A546043FFFFFFFFFF56475B
     */
    public func analysisHistoryHr(_ data: Data) -> (datetime: String, heartRateDatas: [UInt8])? {
        guard data.count > 17 else {
            return nil
        }
        let dataBytes: [UInt8] = [UInt8](data)
        let year = (Int(dataBytes[1]) << 8) + Int(dataBytes[2])
        let month = Int(dataBytes[3])
        let day = Int(dataBytes[4])
        let hour = Int(dataBytes[5])
        let historyData: [UInt8] = [
            dataBytes[6],
            dataBytes[7],
            dataBytes[8],
            dataBytes[9],
            dataBytes[10],
            dataBytes[11],
            dataBytes[12],
            dataBytes[13],
            dataBytes[14],
            dataBytes[15],
            dataBytes[16],
            dataBytes[17]
        ]
        return ("\(year)-\(month)-\(day)-\(hour)", historyData)
    }
    
    func analysisHisorySpor(data: Data) -> (datetime: String, spo2s: [UInt8])? {
        guard data.count > 11 else {
            return nil
        }
        let dataBytes: [UInt8] = [UInt8](data)
        let year = (Int(dataBytes[3]) << 8) + Int(dataBytes[4])
        let month = Int(dataBytes[5])
        let day = Int(dataBytes[6])
        let hour = Int(dataBytes[7])
        let minute = Int(dataBytes[8])
        let historyData: [UInt8] = [
            dataBytes[9],
            dataBytes[10],
            dataBytes[11],
            dataBytes[12],
            dataBytes[13],
            dataBytes[14],
            dataBytes[15],
            dataBytes[16],
            dataBytes[17],
            dataBytes[18],
            dataBytes[19]
        ]
        return ("\(year)-\(month)-\(day)-\(hour)-\(minute)", historyData)
    }
    
    
    public func changeSpo2switch(status: LsSpo2Status) -> Observable<Bool> {
        let resetCmd: [UInt8] = [LS02CommandType.historySpo2Data.rawValue, status.rawValue]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, 0,LS02CommandType.historySpo2Data.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    guard [UInt8](datas).count > 1 else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    subscriber.onNext(LsSpo2Status.init(rawValue: [UInt8](datas)[1]) == status)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func inquireSpo2TestStatus() -> Observable<LsSpo2Status.InquireStatus> {
        let resetCmd: [UInt8] = [LS02CommandType.historySpo2Data.rawValue, LS02Placeholder.aa.rawValue]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, 0,LS02CommandType.historySpo2Data.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    guard [UInt8](datas).count > 2 else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    subscriber.onNext(LsSpo2Status.InquireStatus.init(rawValue: [UInt8](datas)[3]) ?? .notSupport)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func setSpo2CollectTime(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionTime) -> Observable<LsSpo2Status.CollectionTime> {
        let resetCmd: [UInt8] = [LS02CommandType.historySpo2Data.rawValue, LS02Placeholder.three.rawValue,
                                 status.rawValue,
                                 UInt8(((type.rawValue>>8)&0xFF)),
                                 UInt8(((type.rawValue)&0xFF))]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, 0,"setSpo2CollectTime", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    guard [UInt8](datas).count > 2 else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    let collectionTime: UInt16 = datas.scanValue(at: 3)
                    
                    guard let s = LsSpo2Status.CollectionTime.init(rawValue: collectionTime) else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    subscriber.onNext(s)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func setSpo2CollectPeriod(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionPeriod) -> Observable<Ls02SwitchReverse> {
        let resetCmd: [UInt8] = [LS02CommandType.historySpo2Data.rawValue, LS02Placeholder.four.rawValue,
                                 status.rawValue,
                                 UInt8(((type.rawValue>>8)&0xFF)),
                                 UInt8(((type.rawValue)&0xFF))]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, 0,"setSpo2CollectPeriod", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    guard [UInt8](datas).count > 2 else {
                        subscriber.onError(BleError.error(""))
                        return
                    }
                    
                    subscriber.onNext(Ls02SwitchReverse.init(rawValue: [UInt8](datas)[2]) ?? .close)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    /**
     解析实时心率
     */
    public func analysisRealtimeHr(_ data: Data) -> UInt8 {
        guard data.count > 3 else {
            return 0
        }
        let dataBytes: [UInt8] = [UInt8](data)
        let validedValue = dataBytes[2]
        if validedValue == 0 {
            return dataBytes[3]
        }
        return 0
    }
    
    /**
     解析 设备间隔 10 分钟上报的数据
     */
    func analysis10MinuteHr(_ data: Data) -> (datetime: String, value: UInt8)? {
        guard data.count > 8 else {
            return nil
        }
        let dataBytes: [UInt8] = [UInt8](data)
        let year = (Int(dataBytes[2]) << 8) + Int(dataBytes[3])
        let month = Int(dataBytes[4])
        let day = Int(dataBytes[5])
        let h = Int(dataBytes[6])
        let m = Int(dataBytes[7])
        let value = Int(dataBytes[8])
        return ("\(year)-\(month)-\(day)-\(h)-\(m)", UInt8(value))
    }
    
    /**
     解析 设备上报 最大值、最小值、平均值
     0x07E4 02 0A 0801。
     */
    public func analysisStatisticshrHr(_ data: Data) -> (datetime: String, max: UInt8, min: UInt8, avg: UInt8)? {
        guard data.count > 10 else {
            return nil
        }
        
        let dataBytes: [UInt8] = [UInt8](data)
        
        
        let year = (Int(dataBytes[2]) << 8) + Int(dataBytes[3])
        let month = Int(dataBytes[4])
        let day = Int(dataBytes[5])
        let h = Int(dataBytes[6])
        let m = Int(dataBytes[7])
        
        let max = Int(dataBytes[8])
        let min = Int(dataBytes[9])
        let avg = Int(dataBytes[10])
        
        return ("\(year)-\(month)-\(day)-\(h)-\(m)", UInt8(max), UInt8(min), UInt8(avg))
    }
    
    /**
     解析睡眠数据
     */
    public func analysisSleep(_ data: Data) -> [Ls02SleepItem] {
        guard data.count > 6 else {
            return []
        }
        var sleepItems: [Ls02SleepItem] = []
        var dataBytes: [UInt8] = [UInt8](data)
        dataBytes.removeFirst()
        let itemCount = dataBytes.count / 6
        for i in 0 ..< itemCount {
            let index = i * 6
            let startHour = Int(dataBytes[index])
            let startMin = Int(dataBytes[index + 1])
            let state = Ls02SleepState(rawValue: Int(dataBytes[index + 2])) ?? .unknow
            let flag = Ls02SleepFlag(rawValue: Int(dataBytes[index + 3])) ?? .unknow
            let sleepDuration = (Int(dataBytes[index + 4]) << 8) + Int(dataBytes[index + 5])
            sleepItems.append(Ls02SleepItem(startHour: startHour, startMin: startMin, sleepDuration: sleepDuration, state: state, flag: flag))
        }
        return sleepItems
    }
    
    /**
     解析运动数据
     */
    public func analysisSport(_ data: Data) -> Ls02SportInfo? {
        
        guard data.count >= 18 else {
            return nil
        }
        
        let acceptBytes = [UInt8](data)
        let year = (Int(acceptBytes[1]) << 8) + Int(acceptBytes[2])
        let month = Int(acceptBytes[3])
        let day = Int(acceptBytes[4])
        let hour = Int(acceptBytes[5])
        
        let totalStep = (Int(acceptBytes[6]) << 8) + Int(acceptBytes[7])
        
        let runStart = Int(acceptBytes[8])
        let runEnd = Int(acceptBytes[9])
        let runDuration = Int(acceptBytes[10])
        let runStep = (Int(acceptBytes[11]) << 8) + Int(acceptBytes[12])
        
        let walkStart = Int(acceptBytes[13])
        let walkEnd = Int(acceptBytes[14])
        let walkDuration = Int(acceptBytes[15])
        let walkStep = (Int(acceptBytes[16]) << 8) + Int(acceptBytes[17])
        
        return Ls02SportInfo(year: year, month: month, day: day, hour: hour, totalStep: totalStep, runStart: runStart, runEnd: runEnd, runDuration: runDuration, runStep: runStep, walkStart: walkStart, walkEnd: walkEnd, walkDuration: walkDuration, walkStep: walkStep, calorieTotal: 0, distanceTotal: 0, durationTotal: 0, activityTotal: 0)
    }
    
    public func analysisFunctionTag(_ data: Data) -> UTEFunctionTag? {
        guard data.count == 20 else {
            return nil
        }
        let acceptBytes = [UInt8](data)
        let function16 = acceptBytes[16]
        let function13 = acceptBytes[13]
        let function8 = acceptBytes[8]
        let function7 = acceptBytes[7]
        let function6 = acceptBytes[6]
        let function5 = acceptBytes[5]
        
        let mlsEnable = function16&0x08 > 0
        let gpsEnable = function16&0x02 > 0
        
        let queryLEnable = function13&0x20 > 0
        
        let updateLEnable = function8&0x10 > 0
        let smssacEnable = function8&0x40 > 0
        
        let sportControlSynEnable = function7&0x02 > 0
        let bloodOxyGenEnable = function7&0x40 > 0
        let languageMenuEnable = function6&0x01 > 0
        let nfcEnable = function6&0x02 > 0
        let gpsUpdateEnable = function6&0x04 > 0
        let customDataTransferEnable = function6&0x20 > 0
        let pumpBloodEnable = function6&0x80 > 0
        
        let multiSportDuration = function5&0x04 > 0
        
        return UTEFunctionTag(muLanguageShow: mlsEnable, queryLanguage: queryLEnable, updateLanguage: updateLEnable, languageMenu: languageMenuEnable, sportModelStatiStepAndCal: smssacEnable, sportControlSyn: sportControlSynEnable, bloodOxygen: bloodOxyGenEnable, GPS: gpsEnable, NFC: nfcEnable, gPSAndAGPSUpdate: gpsUpdateEnable, CustomDataTransfer: customDataTransferEnable, PumpBloodOxygen: pumpBloodEnable, multiSportDuration: multiSportDuration)
    }
    func analysisWatchFunctionAndStateValue(data: Data) -> Ls02sShortcutSwitchsOpenStatus? {
        guard data.count == 20 else {
            return nil
        }
        
        let acceptBytes = [UInt8](data)
        
        let byte0 = acceptBytes[2]
        
        let foundWristband = byte0 & 0b0000_0001 > 0//查找手环
        let lightWhenWristUp = byte0 & 0b0000_0010 > 0//抬手亮屏
        let longSitNotification = byte0 & 0b0000_0100 > 0//久坐提醒
        let noDisturb = byte0 & 0b0000_1000 > 0//勿扰模式
        let lossPrevent = byte0 & 0b0001_0000 > 0 //智能防丢
        let messageNotification = byte0 & 0b0010_0000 > 0 //短信提醒
        let heartRate = byte0 & 0b0100_0000 > 0 //心率
        
        return Ls02sShortcutSwitchsOpenStatus.init(foundWristband: foundWristband,
                                                   lightWhenWristUp: lightWhenWristUp,
                                                   longSitNotification: longSitNotification,
                                                   noDisturb: noDisturb,
                                                   lossPrevent: lossPrevent,
                                                   messageNotification: messageNotification,
                                                   heartRate: heartRate)
        
    }
    
    func analysisWatchBtnFunction(data: Data) ->Ls02BraceletKeyEvent? {
        guard data.count > 1 else {
            return nil
        }
        
        let acceptBytes = [UInt8](data)
        
        return Ls02BraceletKeyEvent.init(rawValue: acceptBytes[1])
        
    }
}

//MARK:  天气部分
extension Ble02Operator {
    public func setWeatherData(_ weathData: [LSWeather]) -> Observable<Bool> {
        
        let datas = Ble02CmdsConfig.shared.buildWeatherData(weathData: weathData)
        
        var currentIndex = 0
        
        return Observable.create { (observer) -> Disposable in
            
            Observable.from(datas)
                .enumerated()
                .flatMap() { index, item -> Observable<Data> in
                    return self.writeData(item, LS02CommandType.sendWeatherInfo.name)
                }
                .subscribe(onNext: {
                    //                    print("currentIndex",currentIndex)
                    currentIndex += 1
                    
                    if currentIndex == datas.count {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                    print($0)
                })
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func writeData(_ data: Data, _ name: String) -> Observable<Data> {
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(data, 0,name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(Ls02Error.error("数据异常"))
                        return
                    }
                    subscriber.onNext(data)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
}


extension Ble02Operator {
    
    public func readValue(channel: Channel) {
        self.bleFacade?.readValue(channel: channel)
    }
    
    /**
     不入队列 直接发送
     */
    public func directWrite(_ data: Data, _ type: WitheType) {
        
        self.bleFacade?.directWrite(data, type)
    }
}

extension Ble02Operator {
    
    public func sendNFCData(writeData: Data, characteristic: Int, duration: Int, endRecognition: ((Any) -> Bool)? = nil) -> Observable<BleResponse> {
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(writeData, 0,"NFC", duration, endRecognition)
                .subscribe { (bleResponse) in
                    subscriber.onNext(bleResponse)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
}


//Tips
/*
 UTE距离返回的是KM
 
 保存的一天内都是12个点
 
 */



