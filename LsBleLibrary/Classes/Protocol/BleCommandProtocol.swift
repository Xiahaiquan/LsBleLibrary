//
//  BleCommandProtocol.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

protocol BleCommandProtocol {
    
    /// 绑定设备
    /// - Returns: 绑定的状态
    func bindDevice(userId: UInt32,
                     gender: LsGender,
                     age: UInt32,
                     height: UInt32,
                     weight: UInt32,
                     wearstyle: WearstyleEnum) ->Observable<LSDeviceModel>
    
    /// 获取Mtu
    /// - Returns: 设备的Mut。该值遵守Monitored协议
    func getmtu() ->Observable<Monitored>
    

    func configDevice(phoneInfo: (model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum),
                      switchs: Data,
                      longsit: (duration: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32),
                      drinkSlot: (drinkSlot: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32),
                      alarms: [AlarmModel],
                      countryInfo: (name: Data, timezone: UInt32),
                      uiStyle: (style: UInt32, clock: UInt32),
                      target: (cal: UInt32, dis: UInt32, step: UInt32),
                      timeFormat: DeviceTimeFormat,
                      metricInch: DeviceUnitsFormat,
                      brightTime: UInt32,
                      upper: UInt32,
                      lower: UInt32,
                      code: UInt32,
                      duration: UInt32) -> Observable<LSDeviceModel?>
    
    
    
    func syncPhoneInfoToLS(model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum) -> Observable<Bool>
    
    func configureSportsGoalSettings(cal: UInt32,
                                     dis: UInt32,
                                     step: UInt32) -> Observable<Bool>

    func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool>
    
    
    func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                           startTime: UInt32,
                                           endTime: UInt32,
                                           nodisturbStartTime: UInt32,
                                           nodisturbEndTime: UInt32) ->Observable<Bool>
    
    func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool>
    
    func getWatchAlarm() ->Observable<Bool>
    
    func configureDoNotDisturbTime(notdisturbTime1: Data,
                                   notdisturbTime2: Data) ->Observable<Bool>
    
    func configureCountryInformation(name: Data,
                                     timezone: UInt32) ->Observable<Bool>
    
    func configureUIStyle(style: UInt32,
                          clock: UInt32) ->Observable<Bool>
    
    
    func configureTheBrightScreenDuration(brightTime: UInt32)->Observable<Bool>
    
    func configureHeartRateWarning(upper: UInt32,
                                           lower: UInt32) ->Observable<Bool>
    
    func requestHeartRateData() ->Observable<Bool>
    
    func notificationReminder(type: UInt32,
                              titleLen: UInt32,
                              msgLen: UInt32,
                              reserved: Data,
                              title: Data,
                              msg: Data,
                              utc: UInt32) ->Observable<Bool>
    
    
    func getBattery() ->Observable<UInt32>
    
    func upgradeCommand(version: UInt32) ->Observable<Bool>
    
    func restoreFactorySettings(mode: UInt32) ->Observable<Bool>
    
    
    
    func deviceEntersTestMode(mode: FactoryTestMode) ->Observable<Bool>
    
    func getRealTimeHeartRate() ->Observable<Bool>
    
    func appQueryData() ->Observable<Bool>
    
    func getStepAfterHistoryData() ->Observable<Bool>
    
    
    func checkGpsInfo(type: UInt32,
                      num: UInt32,
                      second: UInt32,
                      version: UInt32) ->Observable<Bool>
    
    func checkFuncPageSettings(type: UInt32,
                               page: UInt32) ->Observable<LSFunctionTag?>
    
    func getDialConfigurationInformation() ->Observable<Bool>
    
    func configSpo2AndHRWarning(type: HealthMonitorEnum,
                                min: UInt32,
                                max: UInt32) ->Observable<Bool>
    
    func setSpo2Detect(enable: SwitchStatusEnum,
                       intersec: UInt32) ->Observable<Bool>
    
    func getSpo2Detect(enable: SwitchStatusEnum,
                       intersec: UInt32) ->Observable<Bool>
    
    func getMenuConfig(type: UInt32) ->Observable<LSMenuModel>
    
    func configMenu(type: UInt32,
                    count: UInt32,
                    data: Data) ->Observable<Bool>
    
    func getWatchLog() ->Observable<Bool>
    
    func setAppStatus(status: AppStatusEnum) ->Observable<Bool>
    
    func findTheBraceletCommand() ->Observable<Bool>
    
    func checkWatchFaceStatus(data: Data, type: BinFileTypeEnum) ->Observable<Bool>
    
    func makeTestData() ->Observable<Bool>
    
    
    func getHealthData(syncType: HealthDataSyncType,
                       secondStart: UInt32,
                       secondEnd: UInt32) -> Observable<[BigDataProtocol]>
    
    
    func unBindDevice(mode: UInt32) -> Observable<Bool>
    
    //MARK: 以上是05S的协议，以下是04的协议
    func getHistoryHeartrateData(dateByFar: Date) -> Observable<(datetime: String, heartRateDatas: [UInt8])>
    func getHistoryDayData(dateByFar: Date) -> Observable<Ls02SportInfo>
    func getHistorySleepData(dateByFar: Date) -> Observable<[Ls02SleepInfo]>
    func setWeatherData(_ weathData: [LSWeather]) -> Observable<Bool>
    
    
    
    //血氧相关
    func changeSpo2switch(status: LsSpo2Status) -> Observable<Bool>
    func inquireSpo2TestStatus() -> Observable<LsSpo2Status.InquireStatus>
    func setSpo2CollectTime(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionTime) -> Observable<LsSpo2Status.CollectionTime>
    func setSpo2CollectPeriod(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionPeriod) -> Observable<Ls02SwitchReverse>
    
    
    //生产测试信息
    func createTestStepsData(year: Int, month: Int, day: Int) -> Observable<Bool>
    func createTestSleepingData(year: Int, month: Int, day: Int) -> Observable<Bool>
    func createTestHeartRateData(year: Int, month: Int, day: Int) -> Observable<Bool>
    func createTestHeartRateData(sportType: Int, year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Bool>
    
    //NFC相关
    func sendNFCData(writeData: Data, characteristic: Int, duration: Int, endRecognition: ((Any) -> Bool)?) -> Observable<BleResponse>
    
    //GPS相关
    func requestWatchGPSState() -> Observable<Bool>
    func deleteWatchGPSData() -> Observable<Bool>
    func openWatchGPS(sportType: Int) -> Observable<Bool>
    func getGPSFirmwareVersion() -> Observable<String>
    func sentLocationInformation(latitude: Float, longitude: Float, altitude: Float) -> Observable<Bool>
    func closeWatchGPS() -> Observable<Bool>
    func requestGPSSportData(year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Ls02GPSDataBackMode>
    func startAGPSDataCommand(agpsType: Int) -> Observable<Bool>
    func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatus>
    func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Ls02ReadyUpdateAGPSStatus>
    func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool>
    func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool>
    func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatus>
    func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool>
    func checkBeidouDataInvalte() -> Observable<Bool>
    
    //运动记录相关
    
    /// <#Description#>
    /// - Returns: <#description#>
    func getSportModelState() -> Observable<(state: SportModelState, sportModel: Int)>
    func startSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>
    func updateSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval, speed: Int, flag: Int,duration: Int, cal: Int, distance: Float, step: Int) -> Observable<BleBackData?>
    func getSportModelHistoryData(datebyFar: Date) -> Observable<LSWorkoutItem?>
    
    //手表设置相关
    func setUnitFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool>
    func setDateFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool>
    
    func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool>
    func getMacAddress() -> Observable<String>
    func getDeviceVersion() -> Observable<String>
    func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsOpenStatus>
    func requesFunctionStatus() -> Observable<String>
    func requestRealtimeSteps() -> Observable<UInt8>
    func requestRealtimeHeartRate() -> Observable<UInt8>
    func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool>
    func requestCurrentSportMode() -> Observable<UInt8>
    func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8>
    func getAlarmsMaxSupportNum() -> Observable<UInt8>
    func setLongSitNotification(enable:DeviceSwitch, startTime: String, endTime: String, nodStartTime: String, nodEndTime: String, donotDistrubAtNoon: DeviceSwitch, longsitDuration: UInt8) -> Observable<Bool>
    func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool>
    func setNotificationSwitch(switchsData: Data) ->Observable<Bool>
    func raiseWristBrightenScreen(height: Int, weight: Int, brightScreen: UInt8, raiseSwitch: DeviceSwitch, stepGoal: Int,  maxHrAlert: UInt8, minHrAlert: UInt8, age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum, temperatureUnit: Ls02TemperatureUnit,switchConfigValue: UInt64) -> Observable<Bool>
    func phoneControlPowerOff() -> Observable<UInt8>
    func configFoundTelephone(enable: DeviceSwitch) -> Observable<UInt8>
    func setLanguageToUTE(code: UTEDeviceLanguageEnum) -> Observable<UInt8>
    func syncUserInfoToUTE( height: Int,  weight: Int,  brightScreen: UInt8,  stepGoal: Int,  raiseSwitch: DeviceSwitch, maxHrAlert: UInt8,  minHrAlert: UInt8,  age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum,  temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool>
    
    func setANCCItemSwitch(_ item: LsANCSItem, _ itemSwitch: LsANCSSwitch,switchConfigValue: UInt64) -> Observable<Bool>
    func setSedentary(_ sswitch: DeviceSwitch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool>
    func setNotDisturb(_ sswitch: DeviceSwitch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool>
    
    //表盘相关
    /// 获取当前手表表盘的信息
    /// - Returns: 表盘信息
    func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)>
    
    ///  表盘数据发送完成
    /// - Returns: 命令是否写入成功
    func writeComplete() -> Observable<Bool>
    
    /// 开始发送表盘数据
    /// - Returns: 是否可以发送表盘数据
    func requestCloudWatchFaceTransfer() -> Observable<Bool>
    
    //可以直接调用蓝牙库的方法
    func readValue(channel: Channel)
    func directWrite(_ data: Data, _ type: WitheType)
    
}

//MARK: 05S的协议默认实现
extension BleCommandProtocol {
    /// 获取设备的Mtu
    /// - Returns: 设备的Mtu，改值遵守了Monitoredie协议
    func getmtu() ->Observable<Monitored> {
        return Observable<Monitored>.empty()
    }
    
    /// 绑定设备
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - gender: 性别
    ///   - age: 年龄
    ///   - height: 身高
    ///   - weight: 体重
    ///   - wearstyle: 佩戴方式。左手还是右手
    /// - Returns: 绑定结果
    func bindDevice(userId: UInt32,  gender: LsGender, age: UInt32, height: UInt32, weight: UInt32,wearstyle: WearstyleEnum) ->Observable<LSDeviceModel> {
        return Observable<LSDeviceModel>.empty()
    }
    
    /// 配置设备
    /// - Parameters:
    ///   - phoneInfo: 手机信息
    ///   - switchs: 各个的开关状态
    ///   - longsit: 久坐信息
    ///   - drinkSlot: 喝水信息
    ///   - alarms: 闹钟信息
    ///   - countryInfo: 国家信息
    ///   - uiStyle: 手表的UI风格
    ///   - target: 运动目标信息
    ///   - timeFormat: 时间格式（12、24小时制）
    ///   - metricInch: 距离格式（公、英制）
    ///   - brightTime: 亮屏时长
    ///   - upper: 心率预警的最大值
    ///   - lower: 心率预警的最小值
    ///   - code: 音乐控制码（安卓用）
    ///   - duration: 心率采样间隔
    /// - Returns: 设备的Model
    func configDevice(phoneInfo: (model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum), switchs: Data, longsit: (duration: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), drinkSlot: (drinkSlot: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), alarms: [AlarmModel], countryInfo: (name: Data, timezone: UInt32), uiStyle: (style: UInt32, clock: UInt32), target: (cal: UInt32, dis: UInt32, step: UInt32), timeFormat: DeviceTimeFormat, metricInch: DeviceUnitsFormat, brightTime: UInt32, upper: UInt32, lower: UInt32, code: UInt32, duration: UInt32) -> Observable<LSDeviceModel?> {
        return Observable.just(nil)
    }
    
    
    
    /// 同步手机信息到猎声的手表
    /// - Parameters:
    ///   - model: 手机类型
    ///   - systemversion: 手机系统版本号
    ///   - appversion: App 版本号
    ///   - language: 手机语言
    /// - Returns: 是否同步成功
    public func syncPhoneInfoToLS(model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置运动目标
    /// - Parameters:
    ///   - cal: 卡路里
    ///   - dis: 距离
    ///   - step: 步数
    /// - Returns: 是否配置成功
    public func configureSportsGoalSettings(cal: UInt32,
                                            dis: UInt32,
                                            step: UInt32) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置实时心率采集间隔
    /// - Parameter slot: 采集间隔时间
    /// - Returns: 是否配置成功
    public func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    
    /// 配置喝水提醒间隔
    /// - Parameters:
    ///   - drinkSlot: 喝水间隔
    ///   - startTime: 开始的时间
    ///   - endTime: 结束的时间
    ///   - nodisturbStartTime: 设置午休免打扰的开始时间
    ///   - nodisturbEndTime: 设置午休免打扰的结束时间
    /// - Returns: 是否配置成功
    public func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                                  startTime: UInt32,
                                                  endTime: UInt32,
                                                  nodisturbStartTime: UInt32,
                                                  nodisturbEndTime: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置闹钟
    /// - Parameter alarms: 包含闹钟的数据
    /// - Returns: 配置是否成功
    public func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置免打扰的时间
    /// - Parameters:
    ///   - notdisturbTime1: 免打扰的开始时间
    ///   - notdisturbTime2: 免打扰的结束时间
    /// - Returns: 配置是否成功
    public func configureDoNotDisturbTime(notdisturbTime1: Data,
                                          notdisturbTime2: Data) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置国家信息
    /// - Parameters:
    ///   - name: 国家的名字
    ///   - timezone: 国家的时区
    /// - Returns: 是否配置成功
    public func configureCountryInformation(name: Data,
                                            timezone: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置手表的UI风格
    /// - Parameters:
    ///   - style: 手表UI样式
    ///   - clock: 手表时间指针样式
    /// - Returns: 是否配置成功
    public func configureUIStyle(style: UInt32,
                                 clock: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置亮屏时长
    /// - Parameter brightTime: 亮屏时长
    /// - Returns: 是否配置成功
    public func configureTheBrightScreenDuration(brightTime: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 配置心率预警
    /// - Parameters:
    ///   - upper: 预警的最大值
    ///   - lower: 预警的最小值
    /// - Returns: 是否配置成功
    public func configureHeartRateWarning(upper: UInt32,
                                                  lower: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 获取心率数据
    /// - Returns: 是否获取成功
    public func requestHeartRateData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 消息提醒相关的设置（安卓用）
    /// - Parameters:
    ///   - type: <#type description#>
    ///   - titleLen: <#titleLen description#>
    ///   - msgLen: <#msgLen description#>
    ///   - reserved: <#reserved description#>
    ///   - title: <#title description#>
    ///   - msg: <#msg description#>
    ///   - utc: <#utc description#>
    /// - Returns: <#description#>
    public func notificationReminder(type: UInt32,
                                     titleLen: UInt32,
                                     msgLen: UInt32,
                                     reserved: Data,
                                     title: Data,
                                     msg: Data,
                                     utc: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 获取手表电量
    /// - Returns: 电量值
    public func getBattery() ->Observable<UInt32> {
        return Observable.just(0)
    }
    
    /// 设置升级命令
    /// - Parameter version: 要升级的版本
    /// - Returns: 是否设置成功
    public func upgradeCommand(version: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 恢复出厂设置
    /// - Parameter mode: 恢复模式
    /// - Returns: 是否恢复成功
    public func restoreFactorySettings(mode: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
    /// 设备进入测试模式
    /// - Parameter mode: 工厂测试类型
    /// - Returns: 是否进入成功
    public func deviceEntersTestMode(mode: FactoryTestMode) ->Observable<Bool> {
        return Observable<Bool>.empty()
    }
    
    
    /// 获取实时心率
    /// - Returns: 是否获取成功
    public func getRealTimeHeartRate() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 查询APP数据
    /// - Returns: 是否查询成功
    public func appQueryData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 获取步数的数据（在获取完历史数据的时候，要调用一次）
    /// - Returns: 是否获取成功
    public func getStepAfterHistoryData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
    /// 校验gps
    /// - Parameters:
    ///   - type: gps的类型
    ///   - num: 数量
    ///   - second: 时长
    ///   - version: 版本
    /// - Returns: 是否校验成功
    public func checkGpsInfo(type: UInt32,
                             num: UInt32,
                             second: UInt32,
                             version: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func checkFuncPageSettings(type: UInt32,
                                      page: UInt32) ->Observable<LSFunctionTag?> {
        return Observable.just(nil)
    }
    
    public func getDialConfigurationInformation() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configSpo2AndHRWarning(type: HealthMonitorEnum,
                                       min: UInt32,
                                       max: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func setSpo2Detect(enable: SwitchStatusEnum,
                              intersec: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func getSpo2Detect(enable: SwitchStatusEnum,
                              intersec: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func getMenuConfig(type: UInt32) ->Observable<LSMenuModel> {
        return Observable<LSMenuModel>.empty()
    }
    
    public func configMenu(type: UInt32,
                           count: UInt32,
                           data: Data) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func getWatchLog() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func setAppStatus(status: AppStatusEnum) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func getWatchAlarm() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func findTheBraceletCommand() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func checkWatchFaceStatus(data: Data, type: BinFileTypeEnum) ->Observable<Bool> {
        return Observable.just(true)
    }
    public func makeTestData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
    public func getHealthData(syncType: HealthDataSyncType,
                              secondStart: UInt32,
                              secondEnd: UInt32) -> Observable<[BigDataProtocol]> {
        return Observable<[BigDataProtocol]>.empty()
    }
    
    
    public func unBindDevice(mode: UInt32) -> Observable<Bool> {
        return Observable.just(true)
    }
    
}
//MARK: 04协议的默认实现
extension BleCommandProtocol {
    
    /// 获取历史心率数据
    /// - Parameter dateByFar: 开始时间
    /// - Returns: 心率数据
    public func getHistoryHeartrateData(dateByFar: Date) -> Observable<(datetime: String, heartRateDatas: [UInt8])> {
        return Observable.just((datetime: "", heartRateDatas: [0]))
    }
    
    /// 获取历史血氧数据
    /// - Parameter dateByFar: 开始时间
    /// - Returns: 血氧数据
    public func getHistorySp02Data(dateByFar: Date) -> Observable<(datetime: String, spo2s: [UInt8])> {
        return Observable.just((datetime: "", spo2s: [0]))
    }
    /// 获取历史血氧数据
    /// - Parameter dateByFar: 开始时间
    /// - Returns: 血氧数据
    public func getHistoryDayData(dateByFar: Date) -> Observable<Ls02SportInfo> {
        return Observable<Ls02SportInfo>.empty()
    }
    /// 获取历史血氧数据
    /// - Parameter dateByFar: 开始时间
    /// - Returns: 血氧数据
    public func getHistorySleepData(dateByFar: Date) -> Observable<[Ls02SleepInfo]> {
        return Observable.just([Ls02SleepInfo.init(year: 0, month: 0, day: 0, dataCount: 0, sleepItems: [Ls02SleepItem.init(startHour: 0, startMin: 0, sleepDuration: 0, state: .awake, flag: .daytime)])])
    }
    
    /// 切换血氧检查状态
    /// - Parameter status: 状态
    /// - Returns: 是否切换成功
    public func changeSpo2switch(status: LsSpo2Status) -> Observable<Bool> {
        return Observable<Bool>.empty()
    }
    public func inquireSpo2TestStatus() -> Observable<LsSpo2Status.InquireStatus> {
        return Observable<LsSpo2Status.InquireStatus>.empty()
    }
    
    public func setSpo2CollectTime(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionTime) -> Observable<LsSpo2Status.CollectionTime> {
        return Observable<LsSpo2Status.CollectionTime>.empty()
    }
    public func setSpo2CollectPeriod(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionPeriod) -> Observable<Ls02SwitchReverse> {
        return Observable<Ls02SwitchReverse>.empty()
    }
    public func setWeatherData(_ weathData: [LSWeather]) -> Observable<Bool>{
        return Observable.just(true)
    }
    
    //生产测试信息
    public func createTestStepsData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func createTestSleepingData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func createTestHeartRateData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func createTestHeartRateData(sportType: Int, year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    
    //NFC相关
    public func sendNFCData(writeData: Data, characteristic: Int, duration: Int, endRecognition: ((Any) -> Bool)? = nil) -> Observable<BleResponse> {
        return Observable<BleResponse>.empty()
    }
    
    //GPS相关
    public func requestWatchGPSState() -> Observable<Bool>{
        return Observable.just(true)
    }
    public func deleteWatchGPSData() -> Observable<Bool>{
        return Observable.just(true)
    }
    public func openWatchGPS(sportType: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    
    /// 获取GPS固件的版本号
    /// - Returns: 固件的版本号
    public func getGPSFirmwareVersion() -> Observable<String> {
        return Observable<String>.empty()
    }
    public func sentLocationInformation(latitude: Float, longitude: Float, altitude: Float) -> Observable<Bool> {
        return Observable<Bool>.empty()
    }
    public func closeWatchGPS() -> Observable<Bool>{
        return Observable.just(true)
    }
    public func requestGPSSportData(year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Ls02GPSDataBackMode>{
        return Observable<Ls02GPSDataBackMode>.empty()
    }
    public func startAGPSDataCommand(agpsType: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatus>{
        return Observable<Ls02ReadyUpdateAGPSStatus>.empty()
    }
    public func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool> {
        return Observable<Bool>.empty()
    }
    public func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatus>{
        return Observable<Ls02ReadyUpdateAGPSStatus>.empty()
    }
    
    /// 发送GSP升级数据命令
    /// - Parameters:
    ///   - gpsData: gps数据
    ///   - number: 数据编码
    /// - Returns: 是否发送成功
    public func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    
    /// 检验北斗数据是否有小
    /// - Returns: 是否有效
    public func checkBeidouDataInvalte() -> Observable<Bool>{
        return Observable.just(true)
    }
    
    /// 更新GPS数据完成
    /// - Parameter type: GPS的完成类型
    /// - Returns: GPS的完成状态
    public func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Ls02ReadyUpdateAGPSStatus> {
        return Observable<Ls02ReadyUpdateAGPSStatus>.empty()
    }
    
    //运动记录相关
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: Int)>{
        return Observable.just((state: .start, sportModel: 0))
    }
    public func startSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func updateSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval = .m1, speed: Int = 0, flag: Int = 0,duration: Int = 0, cal: Int = 0, distance: Float = 0.0, step: Int = 0) -> Observable<BleBackData?>{
        return Observable.just(nil)
    }
    
    /// 获取运动的历史数据
    /// - Parameter datebyFar: 开始时间
    /// - Returns: 运动历史数据
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<LSWorkoutItem?>{
        return Observable.just(nil)
    }
    
    //手表设置相关
    public func setUnitFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        Observable.just(true)
    }
    public func setDateFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        Observable.just(true)
    }
    
    public func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool>{
        return Observable.just(true)
    }
    
    /// 获取手表的Mac addrss
    /// - Returns: 手表的Mac addrss
    public func getMacAddress() -> Observable<String>{
        return Observable.just("")
    }
    public func getDeviceVersion() -> Observable<String>{
        return Observable.just("")
    }
    public func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsOpenStatus>{
        return Observable<Ls02sShortcutSwitchsOpenStatus>.empty()
    }
    public func requesFunctionStatus() -> Observable<String>{
        return Observable.just("")
    }
    public func requestRealtimeSteps() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func requestRealtimeHeartRate() -> Observable<UInt8>{
        return Observable.just(0)
    }
    
    /// 设置心率数据采集模式
    /// - Parameter settings: 心率采集模式
    /// - Returns: 是否设置成功
    public func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool>{
        return Observable<Bool>.empty()
    }
    
    /// 获取当前运动状态
    /// - Returns: 当前运动状态
    public func requestCurrentSportMode() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8>{
        return Observable.just(0)
    }
    
    /// 获取手表最多闹钟支持个数。05手表获取不到就默认3个
    /// - Returns: 最多闹钟支持个数
    public func getAlarmsMaxSupportNum() -> Observable<UInt8>{
        return Observable.just(0)
    }
    //久坐提醒
    public func setLongSitNotification(enable:DeviceSwitch, startTime: String, endTime: String, nodStartTime: String, nodEndTime: String, donotDistrubAtNoon: DeviceSwitch, longsitDuration: UInt8) -> Observable<Bool>{
        return Observable.just(true)
    }
    //免打扰
    public func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setNotificationSwitch(switchsData: Data) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 抬腕亮屏
    /// - Parameters:
    ///   - height: 身高
    ///   - weight: 体重
    ///   - brightScreen: 亮屏时长
    ///   - raiseSwitch: 抬腕开关
    ///   - stepGoal: 目标步数
    ///   - maxHrAlert: 最大心率预警值
    ///   - minHrAlert: 最小心里预警值
    ///   - age: 年龄
    ///   - gender: 性别
    ///   - lostAlert: 防丢提醒
    ///   - language: App当前的语言设置
    ///   - temperatureUnit: 语言单位
    ///   - switchConfigValue: 开关值
    /// - Returns: 是否设置成功
    public func raiseWristBrightenScreen(height: Int, weight: Int, brightScreen: UInt8, raiseSwitch: DeviceSwitch, stepGoal: Int,  maxHrAlert: UInt8, minHrAlert: UInt8, age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum, temperatureUnit: Ls02TemperatureUnit,switchConfigValue: UInt64) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func phoneControlPowerOff() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func configFoundTelephone(enable: DeviceSwitch) -> Observable<UInt8> {
        return Observable.just(0)
    }
    public func setLanguageToUTE(code: UTEDeviceLanguageEnum) -> Observable<UInt8> {
        return Observable.just(0)
    }
    public func syncUserInfoToUTE( height: Int,  weight: Int,  brightScreen: UInt8,  stepGoal: Int,  raiseSwitch: DeviceSwitch,  maxHrAlert: UInt8,  minHrAlert: UInt8,  age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum,  temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    public func setANCCItemSwitch(_ item: LsANCSItem, _ itemSwitch: LsANCSSwitch,switchConfigValue: UInt64) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setSedentary(_ sswitch: DeviceSwitch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setNotDisturb(_ sswitch: DeviceSwitch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    
    /// 获取表盘设置
    /// - Returns: 表盘的设置信息
    public func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return Observable.just((watchFaceNo: 0, watchFaceWidth: 0, watchFaceHeight: 0, watchFaceType: 0, maxSpace: 0))
    }
    
    /// 表盘数据发送完成
    /// - Returns: 数据是否发送完成
    public func writeComplete() -> Observable<Bool> {
        return Observable.just(true)
    }
    
    /// 开始发送表盘数据
    /// - Returns: 是否可以开始发送
    public func requestCloudWatchFaceTransfer() -> Observable<Bool> {
        return Observable.just(true)
    }
   
    
}
//MARK: 直接调用蓝牙库方法的默认实现
extension BleCommandProtocol {
    
    /// 从设备读值
    /// - Parameter channel: 指定的通道
    public func readValue(channel: Channel)  {
        
    }
    
    /// 直接写数据到设备
    /// - Parameters:
    ///   - data: 发送的数据
    ///   - type: 写数据的类型
    public func directWrite(_ data: Data, _ type: WitheType) {
        
    }
    
}


