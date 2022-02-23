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

public class Ble05sOperator: NSObject {
    public static let shared: Ble05sOperator = Ble05sOperator()
    
    private var bleFacade: BleFacadeable?
    
    let bag: DisposeBag = DisposeBag()
    var dataObserver: Observable<BleBackData>?
    private var dataObserverPublishRelay: PublishRelay<BleBackData> = PublishRelay()
    
    public override init() {
        super.init()
        self.dataObserver = self.dataObserverPublishRelay.asObservable()
    }
    
    public func configFacade(_ facade: BleFacadeable) {
        self.bleFacade = facade
        self.startObserver()
    }
}

extension Ble05sOperator {
    
    func startObserver() {
        guard let obser = self.bleFacade?.dataObserver else {
            return
        }
        
        obser.subscribe { (data) in
            if let cmds = data as? hl_cmds {
                self.routerData(cmd: cmds)
            }
            
        } onError: { (error) in
            print("observer: \(error)")
        }
        .disposed(by: self.bag)
    }
    
    func routerData(cmd: hl_cmds) {
        
        switch cmd.cmd {
        case .cmdSyncStepCount:
            let stepCount = cmd.rGetStepCount
            
            let date = Date.init(timeIntervalSince1970:
                                    TimeInterval(Ble05sParser().handleBackTimestamp(stepCount.mTimeSecond)))
            let sportInfo =  Ls02SportInfo.init(year: date.year(), month: date.month(), day: date.day(), hour: date.hour(), totalStep: Int(stepCount.mStepCount), runStart: 0, runEnd: 0, runDuration: 0, runStep: 0, walkStart: 0, walkEnd: 0, walkDuration: 0, walkStep: 0, calorieTotal: Int(stepCount.mStepCalorie), distanceTotal: Int(stepCount.mStepDistance), durationTotal: Int(stepCount.mActiveduration), activityTotal: Int(stepCount.mActiveduration))
            
            self.dataObserverPublishRelay.accept(BleBackData(type:.stepUpdate, data: sportInfo))
        case .cmdSetFindPhone:
            self.dataObserverPublishRelay.accept(BleBackData(type: .findPhone, data: RingStatus.init(rawValue: cmd.rFindPhone.mRingStatus) ?? .end))
        case .cmdDisturbSwitch:
            self.dataObserverPublishRelay.accept(BleBackData (type: .disturbSwitch, data: DisturbSwitchStatus.init(rawValue:cmd.rGetDisturbEn.mDisturbEn) ?? .close))
        case .cmdGetUiHrsValue:
            let uiHR = CurrentUIHR.init(act:cmd.rGetUiHrs.mUiActHr,
                                        max:cmd.rGetUiHrs.mUiMaxHr,
                                        min:cmd.rGetUiHrs.mUiMinHr)
            self.dataObserverPublishRelay.accept(BleBackData(type: .realtimehr, data: uiHR))
            
        case .cmdGetActiveRecordData:
            
            let activeRecord = cmd.rGetActiveRecord
            
            let item = SportModelItem.init(sportModel: Int(activeRecord.mActiveType),
                                           heartRateNum: Int(activeRecord.mActiveHrCount),
                                           startTimestamp: Int(Ble05sParser().handleBackTimestamp(activeRecord.mActiveStartSecond)),
                                           step: Int(activeRecord.mActiveStep),
                                           cal: Int(activeRecord.mActiveCalories),
                                           distance: activeRecord.mActiveDistance.description,
                                           hrAvg: Int(activeRecord.mActiveAvgHr),
                                           hrMax: Int(activeRecord.mActiveMaxHr),
                                           hrMin: Int(activeRecord.mActiveMinHr),
                                           pace: Int(activeRecord.mActiveSpeed),
                                           hrInterval: Int(activeRecord.mActiveHrCount),
                                           heartRateData: activeRecord.mHrData,
                                           durations: Int(activeRecord.mActiveDurations))
            
            self.dataObserverPublishRelay.accept(BleBackData(type:.sportHistoryData, data: item))
            
        case .cmdGetCurrentSportHr:
            
            let item = LSSportRealtimeItem.init(hr: cmd.rGetCurrentHr.mCurrentHr,
                                                status: SportModelState.init(rawValue: UInt8(cmd.rGetCurrentHr.mCurSportStatus)) ?? .unknown,
                                                step:  cmd.rGetCurrentHr.mStep,
                                                calories: cmd.rGetCurrentHr.mCaloriesKcal,
                                                distance: cmd.rGetCurrentHr.mDistanceM,
                                                timeSeond: cmd.rGetCurrentHr.mTimeSecond,
                                                spacesKm: cmd.rGetCurrentHr.mSpaceSkm)
            
            self.dataObserverPublishRelay.accept(BleBackData(type:.realtimeSporthr, data: item))
            
            
        case .cmdSetBinDataUpdate:
            self.dataObserverPublishRelay.accept(BleBackData.init(type: .binDataUpdate, data: cmd.rErrorCode.err))
        case .cmdGetAlarms:
            var dataSouce = [AlarmModel]()
            for (index, item) in cmd.setAlarms.alarms.enumerated() {
                
                let weeks = item.mAlarm1Cfg.uint8
                
                var enable = false
                if (weeks & 0x01) == 1 {
                    enable = true
                }
                
                let cfg = Int32(weeks >> 1)
                let alarmModel = AlarmModel.init(cfg: cfg,
                                                 hour: item.mAlarm1Hour,
                                                 min: item.mAlarm1Min,
                                                 once: cfg == 0 ? item.mAlarm1Once : 0,
                                                 reMark: item.mAlarm1Remarks.stringUTF8 ?? "",
                                                 enable: enable,
                                                 index: UInt8(index))
                
                print("alarmModel", alarmModel, alarmModel.cfg)
                if alarmModel.cfg == 0 && alarmModel.hour == 0 && alarmModel.min == 0 { continue }
                
                dataSouce.append(alarmModel)
            }
            
            self.dataObserverPublishRelay.accept(BleBackData(type:.alarmUpdate, data: dataSouce))
            
        case .cmdGetPowerValue:
            
            self.dataObserverPublishRelay.accept(BleBackData(type:.electricityUpdate, data: cmd.rGetPowerValue.mPower))
        case .cmdGetUpdateSpo2Data:
            self.dataObserverPublishRelay.accept(BleBackData.init(type: .spo2Update, data: cmd.setUpdateSpo2Data.mSpo2Value))
            
        default:
            break
        }
        
        
    }
    
}

extension Ble05sOperator: BleCommandProtocol {
    
    public func getmtu() -> Observable<Monitored> {
        
        let contentData = Ble05sSendDataConfig.shared.getMUT()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdGetSyncMtu", 3, nil).subscribe(onNext: { (response) in
                guard let mMtu = response.pbDatas?.first?.rGetMtuSize.mMtu else {
                    observer.onError(LsBleLibraryError.error(messae: "返回格式不正确"))
                    return
                }
                
                mtu = Int(mMtu)
                observer.onNext(mMtu)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    //设置用户信息。 也可当成app绑定手环的功能用 app->fw
    public func bindDevice(userId: UInt32,
                           gender: LsGender,
                           age: UInt32,
                           height: UInt32,
                           weight: UInt32,
                           wearstyle: WearstyleEnum) ->Observable<LSDeviceModel> {
        
        let contentData = Ble05sSendDataConfig.shared.bind(userId: userId, gender: gender, age: age, height:height, weight: weight, wearstyle: wearstyle)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0, "cmdBindDevice", 10, nil).subscribe(onNext: { (response) in
                
                guard let cmd = response.pbDatas?.first,
                      cmd.rErrorCode.err == 0 else {
                          observer.onError(LsBleLibraryError.error(messae: "bindDevice error"))
                          return
                      }
                
                let deviceModel = LSDeviceModel(projno: String(decoding: cmd.rBindDevice.mProjno, as: UTF8.self),
                                                hwversion: cmd.rBindDevice.mHwversion,
                                                fwversion: String(decoding:  cmd.rBindDevice.mFwversion, as: UTF8.self),
                                                fontversion: cmd.rBindDevice.mFontversion,
                                                sdversion: cmd.rBindDevice.mSdversion,
                                                uiversion: cmd.rBindDevice.mUiversion,
                                                devicesn: cmd.rBindDevice.mDevicesn,
                                                devicename: cmd.rBindDevice.mDevicename,
                                                battvalue: cmd.rBindDevice.mBattvalue,
                                                devicemac: cmd.rBindDevice.mDevicemac,
                                                bindStatus: LsBleBindState.init(rawValue:
                                                                                    Int(cmd.rBindDevice.mBindOperate)) ?? .error,
                                                power: cmd.rBindDevice.mPower,
                                                disturbEnable: false)
                
                observer.onNext(deviceModel)
                
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    //通用的设置 app->fw
    public func configDevice(phoneInfo: (model: PhoneTypeEnum,
                                         systemversion: UInt32,
                                         appversion: UInt32,
                                         language: LSDeviceLanguageEnum),
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
                             timeFormat: DeviceTimeFormat,
                             metricInch: DeviceUnitsFormat,
                             brightTime: UInt32,
                             upper: UInt32,
                             lower: UInt32,
                             code: UInt32,
                             duration: UInt32) -> Observable<LSDeviceModel?>  {
        
        let contentData = Ble05sSendDataConfig.shared.configDevice(phoneInfo: phoneInfo, switchs: switchs, longsit: longsit, drinkSlot: drinkSlot, alarms: alarms, countryInfo: countryInfo, uiStyle: uiStyle, target: target, timeFormat: timeFormat, metricInch: metricInch, brightTime: brightTime, upper: upper, lower: lower, code: code, duration: duration)
        
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0, "cmdSetAllConfigParam", 3, nil).subscribe(onNext: { (response) in
                guard let cmd = response.pbDatas?.first,
                      cmd.rErrorCode.err == 0 else {
                          observer.onError(LsBleLibraryError.error(messae: "cmdSetAllConfigParam error"))
                          return
                      }
                
                let deviceModel = LSDeviceModel(projno: String(decoding: cmd.rGetDeviceInfo.mProjno, as: UTF8.self),
                                                hwversion: cmd.rGetDeviceInfo.mHwversion,
                                                fwversion: String(decoding:  cmd.rGetDeviceInfo.mFwversion, as: UTF8.self),
                                                fontversion: cmd.rGetDeviceInfo.mFontversion,
                                                sdversion: cmd.rGetDeviceInfo.mSdversion,
                                                uiversion: cmd.rGetDeviceInfo.mUiversion,
                                                devicesn: cmd.rGetDeviceInfo.mDevicesn,
                                                devicename: cmd.rGetDeviceInfo.mDevicename,
                                                battvalue: cmd.rGetDeviceInfo.mBattvalue,
                                                devicemac: cmd.rGetDeviceInfo.mDevicemac,
                                                bindStatus: .unkowned,
                                                power: cmd.rBindDevice.mPower,
                                                disturbEnable: cmd.rGetDisturbEn.mDisturbEn == 1)
                
                observer.onNext(deviceModel)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    

    public func syncPhoneInfoToLS(model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum) -> Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.syncPhoneInfoToLS(model: model, systemversion: systemversion, appversion: appversion, language: language)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSyncPhoneInfo", 3, nil).subscribe(onNext: { (response) in
                guard let cmd = response.pbDatas?.first,
                      cmd.rErrorCode.err == 0 else {
                          observer.onError(LsBleLibraryError.error(messae: "cmdSyncPhoneInfo error"))
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
    
    public func configureSportsGoalSettings(cal: UInt32,
                                            dis: UInt32,
                                            step: UInt32) -> Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureSportsGoalSettings(cal: cal,
                                                                                  dis: dis,
                                                                                  step: step)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetSportTarget", 3, nil).subscribe(onNext: { (response) in
                guard let cmd = response.pbDatas?.first,
                      cmd.rErrorCode.err == 0 else {
                          observer.onError(LsBleLibraryError.error(messae: "cmdSyncPhoneInfo error"))
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
    
    public func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureRealTimeHeartRateCollectionInterval(slot: slot)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetHrSampleSlot", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetHrSampleSlot error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetDrinkSlot", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetDrinkSlot error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetAlarms", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetAlarms error"))
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
    
    public func configureDoNotDisturbTime(notdisturbTime1: Data,
                                          notdisturbTime2: Data) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureDoNotDisturbTime(notdisturbTime1: notdisturbTime1,
                                                                                notdisturbTime2: notdisturbTime2)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetNotdisturb", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetNotdisturb error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetCountryInfo", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetCountryInfo error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetUiStyle", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetUiStyle error"))
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
    
    public func setDateFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool>  {
        let contentData = Ble05sSendDataConfig.shared.configureTimeSystemSetting(timeFormat: date)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetTimeFormat", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetTimeFormat error"))
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
    
    public func setUnitFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        let contentData = Ble05sSendDataConfig.shared.configureMetricSettings(metricInch: unit)
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetMetricInch", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetMetricInch error"))
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
    
    public func configureTheBrightScreenDuration(brightTime: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureTheBrightScreenDuration(brightTime: brightTime)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetBrightTimes", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetBrightTimes error"))
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
    
    public func configureHeartRateWarning(upper: UInt32,
                                                  lower: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configureHeartRateWarning(upper: upper,
                                                                                        lower: lower)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetHrWarning", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetHrWarning error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdGetHrValue", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetHrValue error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetNotifyWarn", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetNotifyWarn error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdGetPowerValue", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetPowerValue error"))
                    return
                }
                
                guard let mPower = response.pbDatas?.first?.rGetPowerValue.mPower else {
                    observer.onError(LsBleLibraryError.error(messae: "get cmdGetPowerValue error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetUpdataFw", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetUpdataFw error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetWeatherInfo", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetWeatherInfo error"))
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
    
    public func setANCCItemSwitch(_ item: LsANCSItem, _ itemSwitch: LsANCSSwitch,switchConfigValue: UInt64) -> Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configurationSwitch(item: item, itemSwitch: itemSwitch, switchConfigValue: switchConfigValue)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSyncSwitch", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSyncSwitch error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetResetMachine", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetResetMachine error"))
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
    
    
    public func updateSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval, speed: Int, flag: Int, duration: Int, cal: Int, distance: Float, step: Int) -> Observable<BleBackData?>  {
        
        QueueManager.shared.syncDataQueue.cancelAllOperations()
        
        let contentData = Ble05sSendDataConfig.shared.APPMultiMotionControl(mode: UInt32(model),
                                                                            status: UInt32(state.rawValue),
                                                                            speed: UInt32(speed),
                                                                            distance: distance,
                                                                            calorie: UInt32(cal),
                                                                            flag: UInt32(flag),
                                                                            duration: UInt32(duration),
                                                                            second: UInt32(duration),
                                                                            step: UInt32(step))
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetSportStatus", 1, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetSportStatus error"))
                    return
                }
                
                observer.onNext(nil)
                observer.onCompleted()
            }, onError: { (err) in
                observer.onError(err)
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: Int)> {
        
        let contentData = Ble05sSendDataConfig.shared.checkSportStatus()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdCheckSportStatus", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onNext((.unknown, 0))
                    return
                }
                
                observer.onNext((.stop, 0))
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
            
            self.bleFacade?.write(contentData, 0,"cmdFactoryTestMode", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdFactoryTestMode error"))
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
    
    public func getRealTimeHeartRate() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getRealTimeHeartRate()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdGetRealtimeHr", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetRealtimeHr error"))
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
    
    public func appQueryData() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.appQueryData()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdDisturbSwitch", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdDisturbSwitch error"))
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
    
    public func getStepAfterHistoryData() ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.getStepAfterHistoryData()
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSyncStepCount", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSyncStepCount error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetCheckGpsInfo", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetCheckGpsInfo error"))
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
                                      page: UInt32) ->Observable<LSFunctionTag?> {
        
        let contentData = Ble05sSendDataConfig.shared.checkFuncPageSettings(type: type,
                                                                            page: page)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetPageSwitch", 3, nil).subscribe(onNext: { (response) in
                guard let err = response.pbDatas?.first?.rErrorCode.err, err == 0, let pageSwitch = response.pbDatas?.first?.setPageSwitch.mPageSwitch else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetPageSwitch error"))
                    return
                }
                
                let lsFunctionTag = LSFunctionTag(gps: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.gps),
                                                  nfc: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.nfc),
                                                  gpsAndApgs: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.gpsAndApgs),
                                                  spo2: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.spo2),
                                                  hrAlert: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.hrAlert),
                                                  spo2Alert: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.spo2Alert),
                                                  menuOrder: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.menuOrder),
                                                  languagePackSwitch: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.languagePackSwitch),
                                                  alarmSyn: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.pressureDetection),
                                                  pressureDetection: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.temperatureDetection),
                                                  temperatureDetection: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.temperatureDetection),
                                                  womenHealth: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.womenHealth),
                                                  onceAlarmClock: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.onceAlarmClock),
                                                  languagePacksFullUpgrade: BleHelper.getOperateSwitch(value: pageSwitch, type: LSSupportFunctionEnum.languagePacksFullUpgrade))
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
            
            self.bleFacade?.write(contentData, 0,"cmdGetDialConfigData", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetDialConfigData error"))
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
    
    public func configSpo2AndHRWarning(type: HealthMonitorEnum,
                                       min: UInt32,
                                       max: UInt32) ->Observable<Bool> {
        
        let contentData = Ble05sSendDataConfig.shared.configSpo2AndHRWarning(type: type,
                                                                             min: min,
                                                                             max: max)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdSetWarmingData", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetWarmingData error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetSpo2Detect", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetSpo2Detect error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdGetSpo2Detect", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetSpo2Detect error"))
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
    
    public func getMenuConfig(type: UInt32) ->Observable<LSMenuModel> {
        
        let contentData = Ble05sSendDataConfig.shared.getMenuConfig(type: type)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentData, 0,"cmdGetMenuSequenceData", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0, let menu = response.pbDatas?.first?.rGetMenuSeqData else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetMenuSequenceData error"))
                    return
                }
                observer.onNext(LSMenuModel.init(type: menu.mType, supportCount: menu.mSupportCount, support: menu.mSupport, count: menu.mCount, data: menu.mData))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetMenuSequenceData", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetMenuSequenceData error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetLogInfoData", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetLogInfoData error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdPhoneAppSetStatus", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdPhoneAppSetStatus error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdGetAlarms", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdGetAlarms error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSetFindDev", 3, nil).subscribe(onNext: { (response) in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetFindDev error"))
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
            
            self.bleFacade?.write(contentData, 0,"cmdSendBigData", 3, nil).subscribe(onNext: { (response) in
                guard let cmds = response.pbDatas?.first else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSendBigData error"))
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
    
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<LSWorkoutItem?> {
        
        let startTime = UInt32(datebyFar.timeIntervalSince1970)
        let endTime = UInt32(Date().timeIntervalSince1970)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.multiSportQuery(startTime: startTime, endTime: endTime), 0,"cmdSetActiveRecordData", 5 * 60, nil)
                .subscribe(onNext: { (response) in
                    
                    guard let item = response.sprotItems else {
                        observer.onNext(nil)
                        return
                    }
                    observer.onNext(item)
                    observer.onCompleted()
                    
                }, onError: { (err) in
                    print("getSportModelHistoryData",err)
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
        
    }
    
    public func makeTestData() ->Observable<Bool> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.makeTestData(), 0,"cmdSetMakeTestData", 3, nil)
                .subscribe(onNext: { (response) in
                    guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                        observer.onError(LsBleLibraryError.error(messae: "cmdSetMakeTestData error"))
                        return
                    }
                    observer.onNext(true)
                    
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
                                                                             secondStart:Ble05sParser().handleSendTimestamp(secondStart),
                                                                             secondEnd: Ble05sParser().handleSendTimestamp(secondEnd)),
                                  0,
                                  "cmdSetSyncHealthData",
                                  5 * 60,
                                  nil)
                .subscribe(onNext: { (response) in
                    guard let item = response.item else {
                        observer.onNext([])
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(item)
                    observer.onCompleted()
                }, onError: { (err) in
                    print("err", err)
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    public func unBindDevice(mode: UInt32) ->Observable<Bool> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(Ble05sSendDataConfig.shared.restoreFactorySettings(mode: mode), 0,"cmdSetResetMachine", 3, nil)
                .subscribe(onNext: { (response) in
                    guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                        observer.onError(LsBleLibraryError.error(messae: "cmdSetResetMachine error"))
                        return
                    }
                    observer.onNext(true)
                    
                    observer.onCompleted()
                }, onError: { (err) in
                    print("")
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func getAlarmsMaxSupportNum() -> Observable<UInt8> {
        return Observable.just(8)
    }
    
    /// 久坐提醒
    /// - Parameters:
    ///   - enable: <#enable description#>
    ///   - targetTime: <#targetTime description#>
    ///   - startTime: <#startTime description#>
    ///   - endTime: <#endTime description#>
    ///   - nodStartTime: <#nodStartTime description#>
    ///   - nodEndTime: <#nodEndTime description#>
    ///   - donotDistrubAtNoon: <#donotDistrubAtNoon description#>
    ///   - longsitDuration: <#longsitDuration description#>
    /// - Returns: <#description#>
    public func setLongSitNotification(enable:DeviceSwitch, startTime: String, endTime: String, nodStartTime: String, nodEndTime: String, donotDistrubAtNoon: DeviceSwitch, longsitDuration: UInt8) -> Observable<Bool> {
        
        let mSwitchsData = Ble05sSendDataConfig.shared.change(notificationType: .long_sit,
                                                              statusFirst: enable,
                                                              statusSecond: donotDistrubAtNoon)
        let contentDataSwitch = Ble05sSendDataConfig.shared.APPSynchronizationSwitchInformationToBracelet(switchs: mSwitchsData)
        
        
        let startTimeValue = Ble05sSendDataConfig.shared.handle(value: startTime)
        let endTimeValue = Ble05sSendDataConfig.shared.handle(value: endTime)
        let nodStartTimeValue = Ble05sSendDataConfig.shared.handle(value: nodStartTime)
        let nodEndTimeValue = Ble05sSendDataConfig.shared.handle(value: nodEndTime)
        
        let contentDataValue = Ble05sSendDataConfig.shared.configureSedentaryJudgmentInterval(longsitDuration: UInt32(longsitDuration),
                                                                                              startTime: UInt32(startTimeValue.hour) << 16 + UInt32(startTimeValue.min),
                                                                                              endTime: UInt32(endTimeValue.hour) << 16 + UInt32(endTimeValue.min),
                                                                                              nodisturbStartTime: UInt32(nodStartTimeValue.hour) << 16 + UInt32(nodStartTimeValue.min),
                                                                                              nodisturbEndTime: UInt32(nodEndTimeValue.hour) << 16 + UInt32(nodEndTimeValue.min))
        
        
        return (self.bleFacade?.write(contentDataSwitch, 0,"cmdSyncSwitch", 3, nil).flatMap({ l in
            return self.bleFacade?.write(contentDataValue, 0,"cmdSetLongsitDuration", 3, nil) ?? Observable.error(LsBleLibraryError.error(messae: "cmdSetLongsitDuration error"))
        }).flatMap({ response ->Observable<Bool> in
            return Observable.create { observer in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "cmdSetLongsitDuration error"))
                    return Disposables.create()
                }
                
                observer.onNext(true)
                observer.onCompleted()
                return Disposables.create()
            }
        })) ?? Observable.error(LsBleLibraryError.error(messae: "setLongSitNotification error"))
        
    }
    /// 勿扰
    /// - Parameters:
    ///   - call: <#call description#>
    ///   - message: <#message description#>
    ///   - motor: <#motor description#>
    ///   - screen: <#screen description#>
    ///   - startHour: <#startHour description#>
    ///   - startMin: <#startMin description#>
    ///   - endHour: <#endHour description#>
    ///   - endMin: <#endMin description#>
    ///   - enable: <#enable description#>
    /// - Returns: <#description#>
    public func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool> {
        
        let mSwitchsData = Ble05sSendDataConfig.shared.change(notificationType: .no_disturb_en,
                                                              statusFirst: DeviceSwitch.init(bool: call),
                                                              statusSecond: DeviceSwitch.init(bool: call))
        let contentDataSwitch = Ble05sSendDataConfig.shared.APPSynchronizationSwitchInformationToBracelet(switchs: mSwitchsData)
        
        
        var times:[UInt8] = Array(repeating: 0, count: 4)
        times[0] = UInt8(startHour)
        times[1] = UInt8(startMin)
        times[2] = UInt8(endHour)
        times[3] = UInt8(endMin)
        
        let contentDataValue = Ble05sSendDataConfig.shared.configureDoNotDisturbTime(notdisturbTime1: Data(bytes: times, count: times.count),
                                                                                     notdisturbTime2: Data(bytes: times, count: times.count))
        
        
        return (self.bleFacade?.write(contentDataSwitch, 0,"cmdSyncSwitch", 3, nil).flatMap({ l in
            return self.bleFacade?.write(contentDataValue, 0,"setNoDisturbanceMode", 3, nil) ?? Observable.error(LsBleLibraryError.error(messae: "setNoDisturbanceMode error"))
        }).flatMap({ response ->Observable<Bool> in
            return Observable.create { observer in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "setNoDisturbanceMode error"))
                    return Disposables.create()
                }
                
                observer.onNext(true)
                observer.onCompleted()
                return Disposables.create()
            }
        })) ?? Observable.error(LsBleLibraryError.error(messae: "setNoDisturbanceMode error"))
        
    }
    
    /// 抬腕亮屏
    /// - Parameters:
    ///   - height: <#height description#>
    ///   - weight: <#weight description#>
    ///   - brightScreen: <#brightScreen description#>
    ///   - raiseSwitch: <#raiseSwitch description#>
    ///   - stepGoal: <#stepGoal description#>
    ///   - maxHrAlert: <#maxHrAlert description#>
    ///   - minHrAlert: <#minHrAlert description#>
    ///   - age: <#age description#>
    ///   - gender: <#gender description#>
    ///   - lostAlert: <#lostAlert description#>
    ///   - language: <#language description#>
    ///   - temperatureUnit: <#temperatureUnit description#>
    /// - Returns: <#description#>
    public func raiseWristBrightenScreen(height: Int, weight: Int, brightScreen: UInt8, raiseSwitch: DeviceSwitch, stepGoal: Int,  maxHrAlert: UInt8, minHrAlert: UInt8, age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum, temperatureUnit: Ls02TemperatureUnit,switchConfigValue: UInt64) -> Observable<Bool> {
        
        let contentDataSwitch = Ble05sSendDataConfig.shared.configurationSwitch(item: .handUpBright, itemSwitch: LsANCSSwitch.init(uteSwitch: raiseSwitch), switchConfigValue: switchConfigValue)
        
        let contentDataValue = Ble05sSendDataConfig.shared.configureTheBrightScreenDuration(brightTime: UInt32(brightScreen))
        
        return (self.bleFacade?.write(contentDataSwitch, 0,"cmdSyncSwitch", 3, nil).flatMap({ l in
            return self.bleFacade?.write(contentDataValue, 0,"setNoDisturbanceMode", 3, nil) ?? Observable.error(LsBleLibraryError.error(messae: "setNoDisturbanceMode error"))
        }).flatMap({ response ->Observable<Bool> in
            return Observable.create { observer in
                guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                    observer.onError(LsBleLibraryError.error(messae: "setNoDisturbanceMode error"))
                    return Disposables.create()
                }
                
                observer.onNext(true)
                observer.onCompleted()
                return Disposables.create()
            }
        })) ?? Observable.error(LsBleLibraryError.error(messae: "setNoDisturbanceMode error"))
        
    }
    public func setNotificationSwitch(switchsData: Data) ->Observable<Bool> {
        
        let contentDataSwitch = Ble05sSendDataConfig.shared.APPSynchronizationSwitchInformationToBracelet(switchs: switchsData)
        
        return Observable.create { (observer) -> Disposable in
            
            self.bleFacade?.write(contentDataSwitch, 0,"setNotificationSwitch", 3, nil)
                .subscribe(onNext: { (response) in
                    guard response.pbDatas?.first?.rErrorCode.err == 0 else {
                        observer.onError(LsBleLibraryError.error(messae: "cmdSetResetMachine error"))
                        return
                    }
                    observer.onNext(true)
                    
                    observer.onCompleted()
                }, onError: { (err) in
                    print("err",err)
                }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
}

extension Ble05sOperator {
    
    public func readValue(channel: Channel)  {
        self.bleFacade?.readValue(channel: channel)
    }
    
    public func directWrite(_ data: Data, _ type: WitheType) {
        
        self.bleFacade?.directWrite(data, type)
    }
}



