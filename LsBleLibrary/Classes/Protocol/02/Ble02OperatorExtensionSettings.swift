//
//  Ble02OperatorExtensionSettings.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

//MARK: 设备信息部分
extension Ble02Operator {
    
    /**
     单位设置 和 12 & 24 显示
     */
    public func setUnitFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.setClockAndDistanceFormat.rawValue, UInt8(unit.rawValue), UInt8(date.rawValue)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setClockAndDistanceFormat.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                    subscriber.onCompleted()
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func setDateFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.setClockAndDistanceFormat.rawValue, UInt8(unit.rawValue), UInt8(date.rawValue)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setClockAndDistanceFormat.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     同步时间
     */
    public func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool> {
        let yearByte1 = UInt8(((year>>8)&0xFF))
        let yearByte2 = UInt8(year&0xFF)
        let syncCmd: [UInt8] = [LS02CommandType.setDateAndTime.rawValue,
                                yearByte1,
                                yearByte2,
                                month,
                                day,
                                hour,
                                min,
                                second,
                                timeZone]
        let setData = Data.init(bytes: syncCmd, count: syncCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setDateAndTime.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     获取mac 地址
     */
    public func getMacAddress() -> Observable<String> {
        let getCmd: [UInt8] = [LS02CommandType.requestBluetoothAddress.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.requestBluetoothAddress.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        return
                    }
                    var macAddressData = [UInt8](data)
                    macAddressData.removeFirst()
                    let macAddressHex = macAddressData.hexString.uppercased()
                    subscriber.onNext(macAddressHex)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     获取版本号
     */
    public func getDeviceVersion() -> Observable<String> {
        let getCmd: [UInt8] = [LS02CommandType.getVersionNum.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.getVersionNum.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let startIndex = data.index(data.startIndex, offsetBy: 1)
                    let contentRange: Range = startIndex..<data.endIndex
                    let version = String.init(data: data.subdata(in: contentRange), encoding: .utf8)!
                    subscriber.onNext(version)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    /**
     查询手环端快捷开关设置支持类型
     */
    public func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsOpenStatus> {
        let getCmd: [UInt8] = [LS02CommandType.requestFunctionSetAndStatus.rawValue,LS02Placeholder.one.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.requestFunctionSetAndStatus.name , 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    
                    guard let switchs = self.analysisWatchFunctionAndStateValue(data: data) else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    
                    subscriber.onNext(switchs)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     查询手环端开关状态
     */
    public func requesFunctionStatus() -> Observable<String> {
        let getCmd: [UInt8] = [LS02CommandType.requestFunctionSetAndStatus.rawValue,LS02Placeholder.two.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.requestFunctionSetAndStatus.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let startIndex = data.index(data.startIndex, offsetBy: 1)
                    let contentRange: Range = startIndex..<data.endIndex
                    let version = String.init(data: data.subdata(in: contentRange), encoding: .utf8)!
                    subscriber.onNext(version)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     获取设备电量
     */
    public func getBattery() -> Observable<UInt32> {
        let getCmd: [UInt8] = [LS02CommandType.getBatteryLevel.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.getBatteryLevel.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(UInt32(data.last ?? 0))
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     读取当前小时或实时的步数
     */
    public func requestRealtimeSteps() -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.requestRealtimeSteps.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.requestRealtimeSteps.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     心率实时数据
     */
    public func requestRealtimeHeartRate() -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.requestRealtimeHeartRate.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.requestRealtimeHeartRate.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool> {
        let getCmd: [UInt8] = [LS02CommandType.historyHeartRateData.rawValue, settings.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.historyHeartRateData.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1, [UInt8](data).count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    
                    subscriber.onNext([UInt8](data)[1] == settings.rawValue)
                    
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func requestCurrentSportMode() -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.multiSport.rawValue, LS02Placeholder.aa.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.multiSport.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.setCameraMode.rawValue, mode.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.setCameraMode.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func getAlarmsMaxSupportNum() -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.supportAlarmsNum.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.supportAlarmsNum.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                    subscriber.onCompleted()
                } onError: { (error) in
//                    subscriber.onError(error)
                    subscriber.onNext(3)
                    subscriber.onCompleted()
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     久坐提醒
     */
    public func setLongSitNotification(enable:DeviceSwitch, startTime: String, endTime: String, nodStartTime: String, nodEndTime: String, donotDistrubAtNoon: DeviceSwitch, longsitDuration: UInt8) -> Observable<Bool> {
        
        let startTimeValue = Ble05sSendDataConfig.shared.handle(value: startTime)
        let endTimeValue = Ble05sSendDataConfig.shared.handle(value: endTime)
        
        let syncCmd: [UInt8] = [LS02CommandType.setLongSitNotification.rawValue,
                                enable.rawValue,
                                longsitDuration,
                                LS02Placeholder.two.rawValue,
                                LS02Placeholder.five.rawValue,
                                LS02Placeholder.zero.rawValue,
                                LS02Placeholder.zero.rawValue,
                                startTimeValue.hour,
                                startTimeValue.min,
                                endTimeValue.hour,
                                endTimeValue.min,
                                donotDistrubAtNoon.rawValue]
        let setData = Data.init(bytes: syncCmd, count: syncCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setLongSitNotification.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /**
     勿打扰模式
     */
    public func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool> {
        let syncCmd: [UInt8] = [LS02CommandType.setNoDisturbanceMode.rawValue,
                                enable == true ? 0 : ((call == true ? 8:0)+(message == true ? 4:0)+(motor == true ? 2:0)+(screen == true ? 1:0)),
                                startHour,
                                startMin,
                                endHour,
                                endMin,
                                enable == true ? 0x01 : 0x00]
        let setData = Data.init(bytes: syncCmd, count: syncCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setNoDisturbanceMode.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func raiseWristBrightenScreen(height: Int, weight: Int, brightScreen: UInt8, raiseSwitch: DeviceSwitch, stepGoal: Int,  maxHrAlert: UInt8, minHrAlert: UInt8, age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum, temperatureUnit: Ls02TemperatureUnit,switchConfigValue: UInt64) -> Observable<Bool> {
        let syncCmd: [UInt8] = [LS02CommandType.setWatch.rawValue,
                                UInt8(((height>>8)&0xFF)),
                                UInt8(height&0xFF),
                                UInt8(((weight>>8)&0xFF)),
                                UInt8(weight&0xFF),
                                brightScreen,
                                UInt8((stepGoal >> 24) & 0xFF),
                                UInt8((stepGoal >> 16) & 0xFF),
                                UInt8((stepGoal >> 8) & 0xFF),
                                UInt8(stepGoal & 0xFF),
                                UInt8(raiseSwitch.rawValue),
                                maxHrAlert,
                                0x00, //这个是保留位
                                age,
                                UInt8(gender.rawValue),
                                UInt8(lostAlert.rawValue),
                                UInt8(language.rawValue),
                                UInt8(temperatureUnit.rawValue),
                                minHrAlert]
        
        let setData = Data.init(bytes: syncCmd, count: syncCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setWatch.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    //手机控制手环关机
    public func phoneControlPowerOff() -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.phoneControlPowerOff.rawValue, LS02Placeholder.eleven.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.phoneControlPowerOff.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func configFoundTelephone(enable: DeviceSwitch) -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.watchBtnFunction.rawValue, LS02Placeholder.a.rawValue, enable.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.watchBtnFunction.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func setLanguageToUTE(code: UTEDeviceLanguageEnum) -> Observable<UInt8> {
        let getCmd: [UInt8] = [LS02CommandType.supportMultiLanguageDisplay.rawValue, LS02Placeholder.ab.rawValue, code.rawValue]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(getData, 0,LS02CommandType.supportMultiLanguageDisplay.name, 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first, data.count > 1 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    subscriber.onNext(data.last!)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    /**
     设置设备参数
     height:      身高，单位为 cm
     weight:     体重，单位为 kg
     brightScreen： 灭屏时间，单位为秒，最小是 5 秒，最大为 255 秒，小于 5 秒为 5 秒
     stepGoal:  步数目标
     raiseSwitch： 抬手亮屏 开关
     maxHrAlert:  为最大警报心率   范围 100~200，设置为 0xff 代表关闭提醒
     minHrAlert:  为最小警报心率    范围 40~100，设置为 0x00 代表关闭提醒
     age：年龄   范围 1~100
     gender：性别
     lostAlert： 防丢失提醒
     language： 语言
     temperatureUnit： 温度单位设置
     */
    
    public func syncUserInfoToUTE( height: Int,  weight: Int,  brightScreen: UInt8,  stepGoal: Int,  raiseSwitch: DeviceSwitch,  maxHrAlert: UInt8,  minHrAlert: UInt8,  age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum,  temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool> {
        
        
        let syncCmd: [UInt8] = [LS02CommandType.setWatch.rawValue,
                                UInt8(((height>>8)&0xFF)),
                                UInt8(height&0xFF),
                                UInt8(((weight>>8)&0xFF)),
                                UInt8(weight&0xFF),
                                brightScreen,
                                UInt8((stepGoal >> 24) & 0xFF),
                                UInt8((stepGoal >> 16) & 0xFF),
                                UInt8((stepGoal >> 8) & 0xFF),
                                UInt8(stepGoal & 0xFF),
                                UInt8(raiseSwitch.rawValue),
                                maxHrAlert,
                                0x00,
                                age,
                                UInt8(gender.rawValue),
                                UInt8(lostAlert.rawValue),
                                UInt8(language.rawValue),
                                UInt8(temperatureUnit.rawValue),
                                minHrAlert]
        
        let setData = Data.init(bytes: syncCmd, count: syncCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setWatch.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                    subscriber.onCompleted()
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }

    /**
     部分参数。02设备不支持
     */
    
    public func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool> {
        
        // 第五字节: 0x02 震动频率。2 秒震动 2 秒停止
        // 第六字节: 0x08 震动周期数， 8个 震动频率
        // 第七字节：有多盏灯的设备， 可以指定灯亮的设备， 0x01 : 第一盏灯， 0x02: 第二盏灯， 0x04: 第三盏灯， 0x06 表示： 第二盏和第三盏
        // 第八字节：灯状态，0x00 表示跟震动屏幕一样闪烁，  0x01 表示震动周期 长亮。
        
        let datas = alarms.map { model -> Data in
            let repeatDays: UInt8 = model.enable ? UInt8(model.cfg) : 0x60
            let frequencyRate: UInt8 = model.enable ? 0x02 : 0x00
            let period: UInt8 = model.enable ? 0x08 : 0x00
            let lightIndex: UInt8 = model.enable ? 0x06 : 0x00
            
            let syncCmd: [UInt8] = [LS02CommandType.setTimerAndMotorParams.rawValue,
                                    repeatDays,
                                    UInt8(model.hour),
                                    UInt8(model.min),
                                    frequencyRate,
                                    period,
                                    lightIndex,
                                    0x00,
                                    UInt8(model.index + 1)] ////第几个闹钟，从1开始
            return Data.init(bytes: syncCmd, count: syncCmd.count)
        }
        //06600A170000000000
        // 063E0A2E0208060000
        //06 3E 0A 2E 02 08 06 00 00
        print("alarms data:", datas)
        return Observable.from(datas).flatMap { data in
            return self.bleFacade!.write(data, 0,LS02CommandType.setTimerAndMotorParams.name, 3, nil)
        }
        .flatMap({ (bleResponse) in
            return Observable.create { observer in
                observer.onNext(true)
                observer.onCompleted()
                return Disposables.create()
            }
        })
        
    }
    
    /**
     设置 ANCC 推送开关
     */
    public func setANCCItemSwitch(_ item: LsANCSItem, _ itemSwitch: LsANCSSwitch,switchConfigValue: UInt64) -> Observable<Bool> {
        let item1 = UInt8((item.rawValue&0xFF))
        let item2 = UInt8(((item.rawValue>>8)&0xFF))
        let item3 = UInt8(((item.rawValue>>16)&0xFF))
        let item4 = UInt8(((item.rawValue>>24)&0xFF))
        let setCmd: [UInt8] = [LS02CommandType.configPushNotification.rawValue, UInt8(itemSwitch.rawValue),item1, item2, item3, item4]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.configPushNotification.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    /**
     久坐提醒设置开关
     */
    public func setSedentary(_ sswitch: DeviceSwitch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.setLongSitNotification.rawValue,
                               UInt8(sswitch.rawValue), interval,
                               0x02, 0x05, 0x00, 0x00, //这4个字节表示马达震动的指令
                               startHour, startMin, endHour, endMin, UInt8(noNap.rawValue)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setLongSitNotification.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    /**
     设置勿扰模式
     */
    public func setNotDisturb(_ sswitch: DeviceSwitch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool> {
        
        var value: UInt8 = 0
        
        if subSwitch.screen {
            value = value | (0x01 << 0)
        }
        if subSwitch.shock {
            value = value | (0x01 << 1)
        }
        if subSwitch.message {
            value = value | (0x01 << 2)
        }
        if subSwitch.call {
            value = value | (0x01 << 3)
        }
        
        let setCmd: [UInt8] = [LS02CommandType.setNoDisturbanceMode.rawValue, value, startHour, startMin, endHour, endMin, UInt8(sswitch.rawValue)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.setNoDisturbanceMode.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    func deviceEntersTestMode(mode: FactoryTestMode) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.enterFactoryTest.rawValue,
                               UInt8(mode.rawValue >> 8),
                               UInt8(mode.rawValue & 0x00ff)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,LS02CommandType.enterFactoryTest.name, 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
}
