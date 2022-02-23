//
//  BleHandler.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/2.
//

import Foundation
import RxSwift
import SwiftUI
//import Haylou_Fun

public class BleHandler {
    public static let shared = BleHandler()
    
    private var strategy: BleCommandProtocol?
    
    public var dataObserver: Observable<BleBackData>?
    
    public func setStrategy(series: LSSportWatchSeries) {
        
        switch series {
        case .UTE:
            self.strategy = Ble02Operator.shared
            self.dataObserver = Ble02Operator.shared.dataObserver
        case .LS:
            self.strategy = Ble05sOperator.shared
            self.dataObserver = Ble05sOperator.shared.dataObserver
        }
    }
    
}

extension BleHandler {
    private func checkStatus() ->Observable<BleCommandProtocol> {
        return Observable.create { observer in
            
            guard let srt = self.strategy else {
                observer.onError(LsBleLibraryError.error(messae: "蓝牙可能没连接"))
                return Disposables.create()
            }
            
            observer.onNext(srt)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

//MARK: 05S的
extension BleHandler {
    
    public func getmtu() ->Observable<Monitored> {
        return checkStatus().flatMap { $0.getmtu() }
    }
    public func bindDevice(userId: UInt32 = 65214009,
                                 gender: LsGender = .female,
                                 age: UInt32 = 30,
                                 height: UInt32 = 170,
                                 weight: UInt32 = 70,
                                 wearstyle: WearstyleEnum = .left) ->Observable<LSDeviceModel> {
        return checkStatus().flatMap { $0.bindDevice(userId: userId, gender: gender, age: age, height: height, weight: weight, wearstyle: wearstyle) }
    }
    
    
    public func configDevice(phoneInfo: (model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum), switchs: Data, longsit: (duration: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), drinkSlot: (drinkSlot: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), alarms: [AlarmModel], countryInfo: (name: Data, timezone: UInt32), uiStyle: (style: UInt32, clock: UInt32), target: (cal: UInt32, dis: UInt32, step: UInt32), timeFormat: DeviceTimeFormat, metricInch: DeviceUnitsFormat, brightTime: UInt32, upper: UInt32, lower: UInt32, code: UInt32, duration: UInt32) -> Observable<LSDeviceModel?> {
        return checkStatus().flatMap { $0.configDevice(phoneInfo: phoneInfo, switchs: switchs, longsit: longsit, drinkSlot: drinkSlot, alarms: alarms, countryInfo: countryInfo, uiStyle: uiStyle, target: target, timeFormat: timeFormat, metricInch: metricInch, brightTime: brightTime, upper: upper, lower: lower, code: code, duration: duration) }
        
    }
    
 
    
    public func syncPhoneInfoToLS(model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum) -> Observable<Bool> {
        return checkStatus().flatMap { $0.syncPhoneInfoToLS(model: model, systemversion: systemversion, appversion: appversion, language: language) }
    }
    
    public func configureSportsGoalSettings(cal: UInt32,
                                            dis: UInt32,
                                            step: UInt32) -> Observable<Bool> {
        return checkStatus().flatMap { $0.configureSportsGoalSettings(cal: cal, dis: dis, step: step) }
    }
    
    public func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool> {
        return checkStatus().flatMap { $0.configureRealTimeHeartRateCollectionInterval(slot: slot) }
    }
    
    
    public func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                                  startTime: UInt32,
                                                  endTime: UInt32,
                                                  nodisturbStartTime: UInt32,
                                                  nodisturbEndTime: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureDrinkingReminderInterval(drinkSlot: drinkSlot,
                                                                            startTime: startTime,
                                                                            endTime: endTime,
                                                                            nodisturbStartTime: nodisturbStartTime,
                                                                            nodisturbEndTime: endTime) }
    }
    
    public func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureAlarmReminder(alarms: alarms) }
    }
    
    public func configureDoNotDisturbTime(notdisturbTime1: Data,
                                          notdisturbTime2: Data) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureDoNotDisturbTime(notdisturbTime1: notdisturbTime1, notdisturbTime2: notdisturbTime2) }
    }
    
    public func configureCountryInformation(name: Data,
                                            timezone: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureCountryInformation(name: name, timezone: timezone) }
    }
    
    public func configureUIStyle(style: UInt32,
                                 clock: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureUIStyle(style: style, clock: clock) }
    }
    
    public func configureTheBrightScreenDuration(brightTime: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureTheBrightScreenDuration(brightTime: brightTime) }
    }
    
    public func configureHeartRateWarning(upper: UInt32,
                                                  lower: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configureHeartRateWarning(upper: upper, lower: lower) }
    }
    
    public func requestHeartRateData() ->Observable<Bool> {
        return checkStatus().flatMap { $0.requestHeartRateData() }
    }
    
    public func notificationReminder(type: UInt32,
                                     titleLen: UInt32,
                                     msgLen: UInt32,
                                     reserved: Data,
                                     title: Data,
                                     msg: Data,
                                     utc: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.notificationReminder(type: type, titleLen: titleLen, msgLen: msgLen, reserved: reserved, title: title, msg: msg, utc: utc) }
    }
    
    public func getBattery() ->Observable<UInt32> {
        return checkStatus().flatMap { $0.getBattery() }
    }
    
    public func upgradeCommand(version: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.upgradeCommand(version: version) }
    }
    
    public func restoreFactorySettings(mode: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.restoreFactorySettings(mode: mode) }
    }
    
    
    public func deviceEntersTestMode(mode: FactoryTestMode) ->Observable<Bool> {
        return checkStatus().flatMap { $0.deviceEntersTestMode(mode: mode) }
    }
    
    public func getRealTimeHeartRate() ->Observable<Bool> {
        return checkStatus().flatMap { $0.getRealTimeHeartRate() }
    }
    
    public func appQueryData() ->Observable<Bool> {
        return checkStatus().flatMap { $0.appQueryData() }
    }
    
    public func getStepAfterHistoryData() ->Observable<Bool> {
        return checkStatus().flatMap { $0.getStepAfterHistoryData() }
    }
    
    
    public func checkGpsInfo(type: UInt32,
                             num: UInt32,
                             second: UInt32,
                             version: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.checkGpsInfo(type: type, num: num, second: second, version: version) }
    }
    
    public func checkFuncPageSettings(type: UInt32,
                                      page: UInt32) ->Observable<LSFunctionTag?> {
        return checkStatus().flatMap { $0.checkFuncPageSettings(type: type, page: page) }
    }
    
    public func getDialConfigurationInformation() ->Observable<Bool> {
        return checkStatus().flatMap { $0.getDialConfigurationInformation() }
    }
    
    public func configSpo2AndHRWarning(type: HealthMonitorEnum,
                                       min: UInt32,
                                       max: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configSpo2AndHRWarning(type: type, min: min, max: max) }
    }
    
    public func setSpo2Detect(enable: SwitchStatusEnum,
                              intersec: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.setSpo2Detect(enable: enable, intersec: intersec) }
    }
    
    public func getSpo2Detect(enable: SwitchStatusEnum,
                              intersec: UInt32) ->Observable<Bool> {
        return checkStatus().flatMap { $0.getSpo2Detect(enable: enable, intersec: intersec) }
    }
    
    /// 获取手表存储的一级排序数据
    /// - Parameter type: 传1，代表的是1级排序
    /// - Returns: 排序的Model
    public func getMenuConfig(type: UInt32) ->Observable<LSMenuModel> {
        return checkStatus().flatMap { $0.getMenuConfig(type: type) }
    }
    
    public func configMenu(type: UInt32,
                           count: UInt32,
                           data: Data) ->Observable<Bool> {
        return checkStatus().flatMap { $0.configMenu(type: type, count: count, data: data) }
    }
    
    public func getWatchLog() ->Observable<Bool> {
        return checkStatus().flatMap { $0.getWatchLog() }
    }
    
    public func setAppStatus(status: AppStatusEnum) ->Observable<Bool> {
        return checkStatus().flatMap { $0.setAppStatus(status: status) }
    }
    
    public func getWatchAlarm() ->Observable<Bool> {
        return checkStatus().flatMap { $0.getWatchAlarm() }
    }
    
    public func findTheBraceletCommand() ->Observable<Bool> {
        return checkStatus().flatMap { $0.findTheBraceletCommand() }
    }
    public func checkWatchFaceStatus(data: Data, type: BinFileTypeEnum) ->Observable<Bool> {
        return checkStatus().flatMap { $0.checkWatchFaceStatus(data: data, type: type) }
    }
    public func makeTestData() ->Observable<Bool> {
        return checkStatus().flatMap { $0.makeTestData() }
    }
    
    
    public func getHealthData(syncType: HealthDataSyncType = .stepsSend,
                              secondStart: UInt32 = UInt32(Date().timeIntervalSince1970 - 7 * 21 * 24),
                              secondEnd: UInt32 = UInt32(Date().timeIntervalSince1970)) -> Observable<[BigDataProtocol]> {
        return checkStatus().flatMap { $0.getHealthData(syncType: syncType, secondStart: secondStart, secondEnd: secondEnd) }
    }
    
    
    public func unBindDevice(mode: UInt32 = 1) -> Observable<Bool> {
        return checkStatus().flatMap { $0.unBindDevice(mode: mode) }
        
    }
    
}
//MARK: 04的
extension BleHandler {
    
    public func getHistoryHeartrateData(dateByFar: Date) -> Observable<(datetime: String, heartRateDatas: [UInt8])> {
        return checkStatus().flatMap { $0.getHistoryHeartrateData(dateByFar:dateByFar)  }
    }
    public func getHistorySp02Data(dateByFar: Date) -> Observable<(datetime: String, spo2s: [UInt8])> {
        return checkStatus().flatMap { $0.getHistorySp02Data(dateByFar:dateByFar) }
    }
    public func getHistoryDayData(dateByFar: Date) -> Observable<Ls02SportInfo> {
        return checkStatus().flatMap { $0.getHistoryDayData(dateByFar: dateByFar) }
    }
    public func getHistorySleepData(dateByFar: Date) -> Observable<[Ls02SleepInfo]> {
        return checkStatus().flatMap { $0.getHistorySleepData(dateByFar: dateByFar) }
    }
    public func changeSpo2switch(status: LsSpo2Status) -> Observable<Bool> {
        return checkStatus().flatMap { $0.changeSpo2switch(status: status) }
    }
    public func inquireSpo2TestStatus() -> Observable<LsSpo2Status.InquireStatus> {
        return checkStatus().flatMap { $0.inquireSpo2TestStatus() }
    }
    public func setSpo2CollectTime(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionTime) -> Observable<LsSpo2Status.CollectionTime> {
        return checkStatus().flatMap { $0.setSpo2CollectTime(status: status, type: type) }
    }
    public func setSpo2CollectPeriod(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionPeriod) -> Observable<Ls02SwitchReverse> {
        return checkStatus().flatMap { $0.setSpo2CollectPeriod(status: status, type: type) }
    }
    public func setWeatherData(_ weathData: [LSWeather]) -> Observable<Bool>{
        return checkStatus().flatMap { $0.setWeatherData(weathData) }
    }
    
    //生产测试信息
    public func createTestStepsData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.createTestStepsData(year: year, month: month, day: day) }
    }
    public func createTestSleepingData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.createTestSleepingData(year: year, month: month, day: day) }
    }
    public func createTestHeartRateData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.createTestHeartRateData(year: year, month: month, day: day) }
    }
    public func createTestHeartRateData(sportType: Int, year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.createTestHeartRateData(sportType: sportType, year: year, month: month, day: day, hour: hour, min: min) }
    }
    //NFC相关
    public func sendNFCData(writeData: Data, characteristic: Int, duration: Int, endRecognition: ((Any) -> Bool)? = nil) -> Observable<BleResponse> {
        return checkStatus().flatMap { $0.sendNFCData(writeData: writeData, characteristic: characteristic, duration: duration, endRecognition: endRecognition) }
    }
    
    //GPS相关
    public func requestWatchGPSState() -> Observable<Bool>{
        return checkStatus().flatMap { $0.requestWatchGPSState() }
    }
    public func deleteWatchGPSData() -> Observable<Bool>{
        return checkStatus().flatMap { $0.deleteWatchGPSData() }
    }
    public func openWatchGPS(sportType: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.openWatchGPS(sportType: sportType) }
    }
    public func getGPSFirmwareVersion() -> Observable<String> {
        return checkStatus().flatMap { $0.getGPSFirmwareVersion() }
    }
    public func sentLocationInformation(latitude: Float, longitude: Float, altitude: Float) -> Observable<Bool> {
        return checkStatus().flatMap { $0.sentLocationInformation(latitude: latitude, longitude: longitude, altitude: altitude) }
    }
    public func closeWatchGPS() -> Observable<Bool>{
        return checkStatus().flatMap { $0.closeWatchGPS() }
    }
    public func requestGPSSportData(year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Ls02GPSDataBackMode>{
        return checkStatus().flatMap { $0.requestGPSSportData(year: year, month: month, day: day, hour: hour, min: min) }
    }
    public func startAGPSDataCommand(agpsType: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.startAGPSDataCommand(agpsType: agpsType) }
    }
    public func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatus>{
        return checkStatus().flatMap { $0.readyUpdateAGPSCommand(type: type) }
    }
    public func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool> {
        return checkStatus().flatMap { $0.readyUpdateGPSCommand(type: type) }
    }
    public func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool>{
        return checkStatus().flatMap { $0.startGPSOTADataCommand(gpsType: gpsType) }
    }
    public func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatus>{
        return checkStatus().flatMap { $0.sendAGPSDataCommand(gpsData: gpsData, number: number) }
    }
    public func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool>{
        return checkStatus().flatMap { $0.sendGPSOTADataCommand(gpsData: gpsData, number: number) }
    }
    public func checkBeidouDataInvalte() -> Observable<Bool>{
        return checkStatus().flatMap { $0.checkBeidouDataInvalte() }
    }
    public func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Ls02ReadyUpdateAGPSStatus> {
        return checkStatus().flatMap { $0.updateAGPComplete(type: type) }
    }
    
    //运动记录相关
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: Int)>{
        return checkStatus().flatMap { $0.getSportModelState() }
    }
    public func startSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>{
        return checkStatus().flatMap { $0.startSportModel(model: model, state: state, interval: interval) }
    }
    public func updateSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval = .m1, speed: Int = 0, flag: Int = 0,  duration: Int = 0, cal: Int = 0, distance: Float = 0.0, step: Int = 0) -> Observable<BleBackData?>{
        return checkStatus().flatMap { $0.updateSportModel(model:model, state: state, interval: interval, speed:speed, flag: flag, duration: duration, cal: cal, distance: distance, step: step) }
    }
    
    /// 获取历史的运动数据
    /// - Parameter datebyFar: 开始的时间（结束的时间是当前时间）
    /// - Returns: 运动的数据的Model数组，距离的单位是Km
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<LSWorkoutItem?>{
        return checkStatus().flatMap { $0.getSportModelHistoryData(datebyFar: datebyFar)  }
    }
    
    //手表设置相关
    public func setUnitFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        return checkStatus().flatMap { $0.setUnitFormat(unit: unit, date: date) }
    }
    public func setDateFormat(unit: DeviceUnitsFormat, date: DeviceTimeFormat) -> Observable<Bool> {
        return checkStatus().flatMap { $0.setDateFormat(unit: unit, date: date) }
    }
    public func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool> {
        return checkStatus().flatMap { $0.syncDateTime(year, month, day, hour, min, second, timeZone) }
    }
    public func getMacAddress() -> Observable<String>{
        return checkStatus().flatMap { $0.getMacAddress() }
    }
    public func getDeviceVersion() -> Observable<String>{
        return checkStatus().flatMap { $0.getDeviceVersion() }
    }
    public func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsOpenStatus>{
        return checkStatus().flatMap { $0.requestQuickFunctionSetting() }
    }
    public func requesFunctionStatus() -> Observable<String>{
        return checkStatus().flatMap { $0.requesFunctionStatus() }
    }
    public func requestRealtimeSteps() -> Observable<UInt8>{
        return checkStatus().flatMap { $0.requestRealtimeSteps() }
    }
    public func requestRealtimeHeartRate() -> Observable<UInt8>{
        return checkStatus().flatMap { $0.requestRealtimeHeartRate() }
    }
    public func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool>{
        return checkStatus().flatMap { $0.setHeartRateMeasureMode(settings: settings) }
    }
    public func requestCurrentSportMode() -> Observable<UInt8>{
        return checkStatus().flatMap { $0.requestCurrentSportMode() }
    }
    public func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8>{
        return checkStatus().flatMap { $0.setCameraMode(mode: mode) }
    }
    public func getAlarmsMaxSupportNum() -> Observable<UInt8>{
        return checkStatus().flatMap { $0.getAlarmsMaxSupportNum() }
    }
    public func setLongSitNotification(enable:DeviceSwitch, startTime: String, endTime: String, nodStartTime: String, nodEndTime: String, donotDistrubAtNoon: DeviceSwitch, longsitDuration: UInt8) -> Observable<Bool>{
        return checkStatus().flatMap { $0.setLongSitNotification(enable: enable, startTime: startTime, endTime: endTime, nodStartTime: nodStartTime, nodEndTime: nodEndTime, donotDistrubAtNoon: donotDistrubAtNoon, longsitDuration: longsitDuration) }
    }
    public func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool> {
        return checkStatus().flatMap { $0.setNoDisturbanceMode(call: call, message: message, motor: motor, screen: screen, startHour: startHour, startMin: startMin, endHour: endHour, endMin: endMin, enable: enable) }
    }
    public func raiseWristBrightenScreen(height: Int, weight: Int, brightScreen: UInt8, raiseSwitch: DeviceSwitch, stepGoal: Int,  maxHrAlert: UInt8, minHrAlert: UInt8, age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum, temperatureUnit: Ls02TemperatureUnit,switchConfigValue: UInt64) -> Observable<Bool> {
        return checkStatus().flatMap { $0.raiseWristBrightenScreen(height: height, weight: weight, brightScreen: brightScreen, raiseSwitch: raiseSwitch, stepGoal: stepGoal, maxHrAlert: maxHrAlert, minHrAlert: minHrAlert, age: age, gender: gender, lostAlert: lostAlert, language: language, temperatureUnit: temperatureUnit,switchConfigValue: switchConfigValue) }
    }
    public func setNotificationSwitch(switchsData: Data) ->Observable<Bool> {
        return checkStatus().flatMap { $0.setNotificationSwitch(switchsData: switchsData) }
    }

    public func phoneControlPowerOff() -> Observable<UInt8>{
        return checkStatus().flatMap { $0.phoneControlPowerOff() }
    }
    public func configFoundTelephone(enable: DeviceSwitch) -> Observable<UInt8> {
        return checkStatus().flatMap { $0.configFoundTelephone(enable: enable) }
    }
    public func setLanguageToUTE(code: UTEDeviceLanguageEnum) -> Observable<UInt8> {
        return checkStatus().flatMap { $0.setLanguageToUTE(code: code) }
    }
    @discardableResult public func syncUserInfoToUTE( height: Int,  weight: Int,  brightScreen: UInt8,  stepGoal: Int,  raiseSwitch: DeviceSwitch,  maxHrAlert: UInt8,  minHrAlert: UInt8,  age: UInt8,  gender: LsGender,  lostAlert: DeviceSwitch,  language: UTEDeviceLanguageEnum,  temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool> {
        
        return checkStatus().flatMap { $0.syncUserInfoToUTE(height:height, weight:weight, brightScreen:brightScreen, stepGoal:stepGoal, raiseSwitch:raiseSwitch, maxHrAlert:maxHrAlert, minHrAlert:minHrAlert, age:age, gender:gender, lostAlert:lostAlert, language:language, temperatureUnit:temperatureUnit) }
    }
    
    public func setANCCItemSwitch(_ item: LsANCSItem, _ itemSwitch: LsANCSSwitch,switchConfigValue: UInt64) -> Observable<Bool> {
        return checkStatus().flatMap { $0.setANCCItemSwitch(item, itemSwitch,switchConfigValue:switchConfigValue) }
    }
    public func setSedentary(_ sswitch: DeviceSwitch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool> {
        return checkStatus().flatMap { $0.setSedentary(sswitch, interval, startHour, startMin, endHour, endMin, noNap) }
    }
    public func setNotDisturb(_ sswitch: DeviceSwitch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool> {
        return checkStatus().flatMap { $0.setNotDisturb(sswitch, startHour, startMin, endHour, endMin, (screen: subSwitch.screen, shock: subSwitch.shock, message: subSwitch.message, call: subSwitch.call)) }
    }
    
    //表盘相关
    public func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return checkStatus().flatMap { $0.getCloudWatchFaceSetting() }
    }
    public func writeComplete() -> Observable<Bool> {
        return checkStatus().flatMap { $0.writeComplete() }
    }
    public func requestCloudWatchFaceTransfer() -> Observable<Bool> {
        return checkStatus().flatMap { $0.requestCloudWatchFaceTransfer() }
    }
    
}
//MARK: 直接调用的
extension BleHandler {
    public func readValue(channel: Channel) {
        
        checkStatus().subscribe { [unowned self] arg in
            arg.readValue(channel: channel)
        } onError: { error in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }
    }
    public func directWrite(_ data: Data, _ type: WitheType) {
        
        assert(strategy != nil, "device not connect maybe")
        
        strategy!.directWrite(data, type)
    }
}
