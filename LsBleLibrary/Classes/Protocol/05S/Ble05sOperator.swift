//
//  Ble05sOperator.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/2.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

enum Ls05sDeviceUploadDataType : Int {
    case dialUpgrade                               // 实时运动
    
}

public class Ble05sOperator: NSObject {
    public static let shared: Ble05sOperator = Ble05sOperator()
    
    private var bleFacade: BleFacadeable?
    
    let bag: DisposeBag = DisposeBag()
    var dataObserver05S: Observable<BleBackData>?
    private var dataObserverPublishRelay: PublishRelay<BleBackData> = PublishRelay()
    
    public override init() {
        super.init()
        self.dataObserver05S = self.dataObserverPublishRelay.asObservable()
    }
    
    public func configFacade(_ facade: BleFacadeable) {
        self.bleFacade = facade
        self.startObserver()
    }
}

extension Ble05sOperator {
    
    func startObserver() {
        guard let obser = self.bleFacade?.dataObserver05s else {
            return
        }
        
        
        obser.subscribe { (data) in
            self.routerData(data)
//            self.dataObserverPublishRelay = (ute: nil, ls: data)
        } onError: { (error) in
            print("observer: \(error)")
        }
        .disposed(by: self.bag)
    }
    
    func routerData(_ backData : LsBackData) {
        print(backData, "backData")
        
        self.dataObserverPublishRelay.accept((ute: nil, backData))
        
        //        print("routerData", routerData.debugDescription)
        
        //        var responseObj: hl_cmds!
        //        do {
        //            responseObj = try hl_cmds(serializedData: responsePbData)
        //        } catch {
        //            print("PB 反序列化 Error")
        //        }
        //
        //        guard let pbObj = responseObj else {
        //            print("PB 反序列化 obj Error")
        //            return .pbDataError
        //        }
        //
        
        //        print("deviceCmd", routerData.deviceCmd)
        
        
        
    }
    
}

extension Ble05sOperator: BleCommandProtocol {
    
    public func getmtu() -> Observable<Int> {
        
        let contentData = Ble05sSendDataConfig.shared.getMUT()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetSyncMtu", 3, nil).subscribe(onNext: { (response) in
                guard let mMtu = response.pbDatas?.first?.rGetMtuSize.mMtu else {
                    observer.onNext(0)
                    return
                }
                
                observer.onNext(Int(mMtu))
                observer.onCompleted()
            }, onError: { (err) in
                print("")
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    //设置用户信息。 也可当成app绑定手环的功能用 app->fw
    public func setUserInfo(userId: UInt32,
                            gender: Ls02Gender,
                            age: UInt32,
                            height: UInt32,
                            weight: UInt32,
                            wearstyle: WearstyleEnum) ->Observable<LsBleBindState> {
        
        let contentData = Ble05sSendDataConfig.shared.bind(userId: userId, gender: gender, age: age, height:height, weight: weight, wearstyle: wearstyle)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdBindDevice", 10, nil).subscribe(onNext: { (response) in
//                guard let mBindOperate = response.pbDatas?.first?.rBindDevice.mBindOperate else {
//
//                }
                
                guard let bindStatus = response.backData?.data["status"] as? LsBleBindState else {
                    observer.onNext(.error)
                    return
                }
                
//                let bindState =  LsBleBindState.init(rawValue: Int(mBindOperate)) ?? .error
                
//                if mBindOperate == 3 || mBindOperate == 5 {
//                    return
//                }
                observer.onNext(bindStatus)
//                observer.onCompleted()
            }, onError: { (err) in
                print("")
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    //通用的设置 app->fw
    public func configDevice(phoneInfo: (model: PhoneTypeEnum,
                                         systemversion: UInt32,
                                         appversion: UInt32,
                                         language: UInt32),
                             switchs: Data,
                             longsit: (duration: UInt32,
                                       startTime: UInt32,
                                       endTime: UInt32,
                                       nodisturbStartTime: UInt32,
                                       nodisturbEndTime: UInt32),
                             drinkSlot: (drinkSlot: UInt32,
                                         startTime: UInt32,
                                         endTime: UInt32,
                                         nodisturbStartTime: UInt32,
                                         nodisturbEndTime: UInt32),
                             alarms: [AlarmModel],
                             countryInfo: (name: Data,
                                           timezone: UInt32),
                             uiStyle:(style: UInt32,
                                      clock: UInt32),
                             target: (cal: UInt32,
                                      dis: UInt32,
                                      step: UInt32),
                             timeFormat: Ls02TimeFormat,
                             metricInch: Ls02Units,
                             brightTime: UInt32,
                             upper: UInt32,
                             lower: UInt32,
                             code: UInt32,
                             duration: UInt32) -> Observable<Bool>  {
        
        let contentData = Ble05sSendDataConfig.shared.configDevice(phoneInfo: phoneInfo, switchs: switchs, longsit: longsit, drinkSlot: drinkSlot, alarms: alarms, countryInfo: countryInfo, uiStyle: uiStyle, target: target, timeFormat: timeFormat, metricInch: metricInch, brightTime: brightTime, upper: upper, lower: lower, code: code, duration: duration)
        
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetAllConfigParam", 3, nil).subscribe(onNext: { (response) in
                
                observer.onCompleted()
            }, onError: { (err) in
                print("")
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    //123
    //获取手环系统信息app->fw
    public func getBraceletSystemInformation() -> Observable<Int> {
        
        let contentData = Ble05sSendDataConfig.shared.getBraceletSystemInformation()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetDeviceInfo", 3, nil).subscribe(onNext: { (response) in
                guard let mMtu = response.pbDatas?.first?.rGetMtuSize.mMtu else {
                    observer.onNext(0)
                    return
                }
                
                observer.onNext(Int(mMtu))
                observer.onCompleted()
            }, onError: { (err) in
                print("")
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    
    
    public func APPSynchronizesMobilePhoneSystemInformationToBand() -> Observable<Int> {
        
        let contentData = Ble05sSendDataConfig.shared.APPSynchronizesMobilePhoneSystemInformationToBand()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSyncPhoneInfo", 3, nil).subscribe(onNext: { (response) in
                guard let mMtu = response.pbDatas?.first?.rGetMtuSize.mMtu else {
                    observer.onNext(0)
                    return
                }
                
                observer.onNext(Int(mMtu))
                observer.onCompleted()
            }, onError: { (err) in
                print("")
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureSportsGoalSettings(cal: UInt32,
                                            dis: UInt32,
                                            step: UInt32) -> Observable<Int> {
        
        let contentData = Ble05sSendDataConfig.shared.configureSportsGoalSettings(cal: cal,
                                                                                  dis: dis,
                                                                                  step: step)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetSportTarget", 3, nil).subscribe(onNext: { (response) in
                guard let mMtu = response.pbDatas?.first?.rGetMtuSize.mMtu else {
                    observer.onNext(0)
                    return
                }
                
                observer.onNext(Int(mMtu))
                observer.onCompleted()
            }, onError: { (err) in
                print("")
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func APPSynchronizationSwitchInformationToBracelet(switchs: Data) -> Observable<Int> {
        
        let contentData = Ble05sSendDataConfig.shared.APPSynchronizationSwitchInformationToBracelet(switchs: switchs)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSyncSwitch", 3, nil).subscribe(onNext: { (response) in
                guard let mMtu = response.pbDatas?.first?.rGetMtuSize.mMtu else {
                    observer.onNext(0)
                    return
                }
                
                observer.onNext(Int(mMtu))
                observer.onCompleted()
            }, onError: { (err) in
                print("")
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureRealTimeHeartRateCollectionInterval(slot: slot)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetHrSampleSlot", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureSedentaryJudgmentInterval(longsitDuration: UInt32,
                                                   startTime: UInt32,
                                                   endTime: UInt32,
                                                   nodisturbStartTime: UInt32,
                                                   nodisturbEndTime: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureSedentaryJudgmentInterval(longsitDuration: longsitDuration,
                                                                                         startTime: startTime,
                                                                                         endTime: endTime,
                                                                                         nodisturbStartTime: nodisturbStartTime,
                                                                                         nodisturbEndTime: nodisturbEndTime)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetLongsitDuration", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                                  startTime: UInt32,
                                                  endTime: UInt32,
                                                  nodisturbStartTime: UInt32,
                                                  nodisturbEndTime: UInt32) ->Observable<Bool> {
        let contentData = Ble05sSendDataConfig.shared.configureDrinkingReminderInterval(drinkSlot: drinkSlot,
                                                                                        startTime: startTime,
                                                                                        endTime: endTime,
                                                                                        nodisturbStartTime: nodisturbStartTime,
                                                                                        nodisturbEndTime: nodisturbEndTime)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetDrinkSlot", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureAlarmReminder(alarms: alarms)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetAlarms", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureDoNotDisturbMode(notdisturbTime1: Data,
                                          notdisturbTime2: Data) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureDoNotDisturbMode(notdisturbTime1: notdisturbTime1,
                                                                                notdisturbTime2: notdisturbTime2)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetNotdisturb", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureCountryInformation(name: Data,
                                            timezone: UInt32) ->Observable<Bool> {
        let contentData = Ble05sSendDataConfig.shared.configureCountryInformation(name: name,
                                                                                  timezone: timezone)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetCountryInfo", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    
    public func configureUIStyle(style: UInt32,
                                 clock: UInt32) ->Observable<Bool>  {
        let contentData = Ble05sSendDataConfig.shared.configureUIStyle(style: style,
                                                                       clock: clock)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetUiStyle", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func setDateFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool>  {
        let contentData = Ble05sSendDataConfig.shared.configureTimeSystemSetting(timeFormat: date)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetTimeFormat", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func setUnitFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool> {
        let contentData = Ble05sSendDataConfig.shared.configureMetricSettings(metricInch: unit)
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetMetricInch", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func configureTheBrightScreenDurationSetting(brightTime: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureTheBrightScreenDurationSetting(brightTime: brightTime)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetBrightTimes", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configureHeartRateWarningSettings(upper: UInt32,
                                                  lower: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureHeartRateWarningSettings(upper: upper,
                                                                                        lower: lower)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetHrWarning", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func requestHeartRateData() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.requestHeartRateData()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetHrValue", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func notificationReminder(type: UInt32,
                                     titleLen: UInt32,
                                     msgLen: UInt32,
                                     reserved: Data,
                                     title: Data,
                                     msg: Data,
                                     utc: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.notificationReminder(type: type,
                                                                           titleLen: titleLen,
                                                                           msgLen: msgLen,
                                                                           reserved: reserved,
                                                                           title: title,
                                                                           msg: msg,
                                                                           utc: utc)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetNotifyWarn", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getBattery() ->Observable<UInt32> {
        
        let contentData = Ble05sSendDataConfig.shared.getBattery()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetPowerValue", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(0)
                    return
                }
                
                guard let mPower = response.pbDatas?.first?.rGetPowerValue.mPower else {
                    observer.onNext(0)
                    return
                }
                
                observer.onNext(mPower)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func upgradeCommand(version: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.upgradeCommand(version: version)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetUpdataFw", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    public func setWeatherData(_ weathData: [LSWeather]) -> Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.appWeatherDataSyncedToDevice(weathers: weathData)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetWeatherInfo", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func setANCCItemSwitch(_ item: Ls02ANCCItem, _ itemSwitch: Ls02ANCCSwitch) -> Observable<Bool> {
     
        let contentData = Ble05sSendDataConfig.shared.configurationSwitch(item: item, config: 0xFFFFF, itemSwitch: itemSwitch)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSyncSwitch", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func restoreFactorySettings(mode: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.restoreFactorySettings(mode: mode)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetResetMachine", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
        
    public func updateSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval, speed: Int, flag: Int, senond: Int,duration: Int, cal: Int, distance: Float, step: Int) -> Observable<Bool>  {
        
        let contentData = Ble05sSendDataConfig.shared.APPMultiMotionControl(mode: UInt32(model.rawValue),
                                                                            status: UInt32(state.rawValue),
                                                                            speed: UInt32(speed),
                                                                            distance: distance,
                                                                            calorie: UInt32(cal),
                                                                            flag: UInt32(flag),
                                                                            duration: UInt32(duration),
                                                                            second: UInt32(senond),
                                                                            step: UInt32(step))
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetSportStatus", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: SportModel)> {

        let contentData = Ble05sSendDataConfig.shared.checkSportStatus()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdCheckSportStatus", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext((.start,.none))
                    observer.onCompleted()
                    return
                }
                
                observer.onNext((.stop,.none))
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func deviceEntersTestMode(mode: FactoryTestMode) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.deviceEntersTestMode()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdFactoryTestMode", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getRealTimeHeartRateInstructionsAndSetIntervals() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getRealTimeHeartRateInstructionsAndSetIntervals()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetRealtimeHr", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
//    public func appQueryData() ->Observable<Bool> {
//
//        let contentData = Ble05sSendDataConfig.shared.appQueryData()
//
//        return Observable.create { (observer) -> Disposable in
//
//            self.bleFacade?.write(contentData, "cmdDisturbSwitch", 3, nil).subscribe(onNext: { (response) in
//                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
//                    observer.onNext(false)
//                    return
//                }
//                
//                observer.onNext(true)
//                observer.onCompleted()
//            }, onError: { (err) in
//                observer.onError(err)
//            }).disposed(by: self.bag)
//
//            return Disposables.create()
//        }
//
//    }
    
    public func getStepAfterHistoryData() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getStepAfterHistoryData()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSyncStepCount", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func checkGpsInfo(type: UInt32,
                             num: UInt32,
                             second: UInt32,
                             version: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.checkGpsInfo(type: type,
                                                                   num: num,
                                                                   second: second,
                                                                   version: version)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetCheckGpsInfo", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func checkFuncPageSettings(type: UInt32,
                                      page: UInt32) ->Observable<LSFunctionTag> {
        
        let contentData = Ble05sSendDataConfig.shared.checkFuncPageSettings(type: type,
                                                                            page: page)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetPageSwitch", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err == 0, let pageSwitch = response.pbDatas?.first?.setPageSwitch.mPageSwitch else {
                    observer.onError(BleError.dataError)
                    return
                }
                
//                let lsFunctionTag = LSFunctionTag(gps: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.gps),
//                                                       nfc: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.nfc),
//                                                       gpsAndApgs: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.gpsAndApgs),
//                                                       spo2: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.spo2),
//                                                       hrAlert: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.hrAlert),
//                                                       spo2Alert: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.spo2Alert),
//                                                       menuOrder: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.menuOrder),
//                                                       languagePackSwitch: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.languagePackSwitch),
//                                                       alarmSyn: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.pressureDetection),
//                                                       pressureDetection: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.temperatureDetection),
//                                                       temperatureDetection: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.temperatureDetection),
//                                                       womenHealth: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.womenHealth),
//                                                       onceAlarmClock: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.onceAlarmClock),
//                                                       languagePacksFullUpgrade: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.languagePacksFullUpgrade))
                
                let lsFunctionTag = LSFunctionTag.init(gps: false, nfc: false, gpsAndApgs: false, spo2: false, hrAlert: false, spo2Alert: false, menuOrder: false, languagePackSwitch: false, alarmSyn: false, pressureDetection: false, temperatureDetection: false, womenHealth: false, onceAlarmClock: false, languagePacksFullUpgrade: false)
                observer.onNext(lsFunctionTag)
                
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getDialConfigurationInformation() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getDialConfigurationInformation()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetDialConfigData", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func configSpo2AndHRWarning(type: UInt32,
                                       min: UInt32,
                                       max: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configSpo2AndHRWarning(type: type,
                                                                             min: min,
                                                                             max: max)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetWarmingData", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func setSpo2Detect(enable: SwitchStatusEnum,
                              intersec: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.setSpo2Detect(enable: enable,
                                                                    intersec: intersec)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetSpo2Detect", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getSpo2Detect(enable: SwitchStatusEnum,
                              intersec: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getSpo2Detect(enable: enable,
                                                                    intersec: intersec)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetSpo2Detect", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getMenuConfig(type: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getMenuConfig(type: type)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetMenuSequenceData", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func configMenu(type: UInt32,
                           count: UInt32,
                           data: Data) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configMenu(type: type,
                                                                 count: count,
                                                                 data: data)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetMenuSequenceData", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func getWatchLog() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getWatchLog()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetLogInfoData", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func setAppStatus(status: AppStatusEnum) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.setAppStatus(status: status)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdPhoneAppSetStatus", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getWatchAlarm() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getWatchAlarm()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdGetAlarms", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func findTheBraceletCommand() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.findTheBraceletCommand()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetFindDev", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    
    public func thisDoesItExist(data: Data, type: BinFileTypeEnum) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.thisDoesItExist(data: data, type: type)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSendBigData", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func dialPB(sn:UInt32, data: Data) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.dialPB(sn:sn, data: data)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSetBinDataUpdate", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err != 0 else {
                    observer.onNext(false)
                    return
                }
                
                observer.onNext(true)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func checkWatchFaceStatus(data: Data, type: BinFileTypeEnum) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.thisDoesItExist(data: data, type: type)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, "cmdSendBigData", 3, nil).subscribe(onNext: { (response) in
                guard let cmds = response.pbDatas?.first else {
                    observer.onNext(false)
                    observer.onCompleted()
                    return
                }
                
                if cmds.rErrorCode.err == 0 {
                    observer.onNext(true)
                }else {
                    observer.onNext(false)
                }
                
                observer.onCompleted()
            }, onError: { (err) in
                print("")
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
        
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<[SportModelItem]> {
                
        let endTime = UInt32(datebyFar.timeIntervalSince1970)
        let startTime = endTime - 7 * 24 * 60 * 60
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.multiSportQuery(startTime: startTime, endTime: endTime), "cmdSetActiveRecordData", 5 * 60, nil)
                .subscribe(onNext: { (response) in
         
                    
                    guard let item = response.sprotItems else {
                        observer.onNext([SportModelItem()])
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(item)
                    observer.onCompleted()
                    
                    observer.onCompleted()
                }, onError: { (err) in
                    print("")
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func makeTestData() ->Observable<Bool> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.makeTestData(), "cmdSetMakeTestData", 3, nil)
                .subscribe(onNext: { (response) in
                    guard let cmds = response.pbDatas?.first else {
                        observer.onNext(false)
                        observer.onCompleted()
                        return
                    }
                    
                    if cmds.rErrorCode.err == 0 {
                        observer.onNext(true)
                    }else {
                        observer.onNext(false)
                    }
                    
                    observer.onCompleted()
                }, onError: { (err) in
                    print("")
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func getHealthData(syncType: HealthDataSyncType,
                              secondStart: UInt32,
                              secondEnd: UInt32) ->Observable<[BigDataProtocol]> {
        

        return Observable.create { (observer) -> Disposable in
            
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.syncHealthData(syncType: syncType,
                                                                             secondStart:secondStart,
                                                                             secondEnd: secondEnd), "cmdSetSyncHealthData",  5 * 60, nil)
                .subscribe(onNext: { (response) in
                    guard let item = response.item else {
                        observer.onNext([DayStepModel.init()])
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(item)
                    observer.onCompleted()
                    
                }, onError: { (err) in
                    print("")
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    public func unBindDevice(mode: UInt32) ->Observable<Bool> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.restoreFactorySettings(mode: mode), "cmdSetResetMachine", 3, nil)
                .subscribe(onNext: { (response) in
                    guard let cmds = response.pbDatas?.first else {
                        observer.onNext(false)
                        observer.onCompleted()
                        return
                    }
                    
                    if cmds.rErrorCode.err == 0 {
                        observer.onNext(true)
                    }else {
                        observer.onNext(false)
                    }
                    
                    observer.onCompleted()
                }, onError: { (err) in
                    print("")
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
}


extension Ble05sOperator {
    
    public func readValue(type: Int) {
        self.bleFacade?.readValue(type: type)
    }
    
    public func directWrite(_ data: Data, _ type: Int) {
        
        self.bleFacade?.directWrite(data, type)
    }
}
