//
//  BleOperator.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/2.
//

import Foundation
import RxSwift

public class BleOperator {
    public static let shared = BleOperator()
    
    var strategy: BleCommandProtocol!
    
    public var dataObserver: Observable<BleBackData>?
    
    public func setStrategy(series: LSSportWatchSeries){
        
        switch series {
        case .UTE:
            self.strategy = Ble02Operator.shared
            self.dataObserver = Ble02Operator.shared.dataObserver02
        case .LS:
            self.strategy = Ble05sOperator.shared
            self.dataObserver = Ble05sOperator.shared.dataObserver05S
        }
    }
    
}

//MARK: 05S的
extension BleOperator {
    
    public func setUserInfo(userId: UInt32 = 65214001,
                            gender: Ls02Gender = .female,
                            age: UInt32 = 30,
                            height: UInt32 = 170,
                            weight: UInt32 = 70,
                            wearstyle: WearstyleEnum = .left) ->Observable<LsBleBindState> {
        return self.strategy.setUserInfo(userId: userId, gender: gender, age: age, height: height, weight: weight, wearstyle: wearstyle)
    }
    
    public func getmtu() ->Observable<Int> {
        return self.strategy.getmtu()
    }
    
    public func configDevice(phoneInfo: (model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: UInt32), switchs: Data, longsit: (duration: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), drinkSlot: (drinkSlot: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), alarms: [AlarmModel], countryInfo: (name: Data, timezone: UInt32), uiStyle: (style: UInt32, clock: UInt32), target: (cal: UInt32, dis: UInt32, step: UInt32), timeFormat: Ls02TimeFormat, metricInch: Ls02Units, brightTime: UInt32, upper: UInt32, lower: UInt32, code: UInt32, duration: UInt32) -> Observable<Bool> {
        return self.strategy.configDevice(phoneInfo: phoneInfo, switchs: switchs, longsit: longsit, drinkSlot: drinkSlot, alarms: alarms, countryInfo: countryInfo, uiStyle: uiStyle, target: target, timeFormat: timeFormat, metricInch: metricInch, brightTime: brightTime, upper: upper, lower: lower, code: code, duration: duration)
        
    }
    
    public func makeTestData() ->Observable<Bool> {
        return self.strategy.makeTestData()
    }
    
    
    public func getHealthData(syncType: HealthDataSyncType = .stepsSend,
                              secondStart: UInt32 = UInt32(Date().timeIntervalSince1970 - 7 * 21 * 24),
                              secondEnd: UInt32 = UInt32(Date().timeIntervalSince1970)) -> Observable<[BigDataProtocol]> {
        return self.strategy.getHealthData(syncType: syncType, secondStart: secondStart, secondEnd: secondEnd)
    }
    
    
    public func unBindDevice(mode: UInt32 = 1) -> Observable<Bool> {
        return self.strategy.unBindDevice(mode: mode)
        
    }
    
    public func checkFuncPageSettings(type: UInt32 = 0,
                               page: UInt32 = 0) ->Observable<LSFunctionTag> {
        return strategy.checkFuncPageSettings(type: type, page: page)
    }
    
}
//MARK: 04的
extension BleOperator {

    public func sentBindcmd(_ userId: Int) -> Observable<LsBleBindState>{
        return strategy.sentBindcmd(userId)
    }
    public func bindDevice(_ userId: Int) ->Observable<LsBleBindState>{
        return strategy.bindDevice(userId)
    }
    
    public func getHistoryHeartrateData(dateByFar: Date) -> Observable<(datetime: String, heartRateDatas: [UInt8])> {
        return strategy.getHistoryHeartrateData(dateByFar:dateByFar)
    }
    public func getHistorySp02Data(dateByFar: Date) -> Observable<(datetime: String, spo2s: [UInt8])> {
        return strategy.getHistorySp02Data(dateByFar:dateByFar)
    }
    public func getHistoryDayData(dateByFar: Date) -> Observable<Ls02SportInfo> {
        return strategy.getHistoryDayData(dateByFar: dateByFar)
    }
    public func getHistorySleepData(dateByFar: Date) -> Observable<[Ls02SleepInfo]> {
        return strategy.getHistorySleepData(dateByFar: dateByFar)
    }
    public func changeSpo2switch(status: LsSpo2Status) -> Observable<Bool> {
        return strategy.changeSpo2switch(status: status)
    }
    public func inquireSpo2TestStatus() -> Observable<LsSpo2Status.InquireStatus> {
        return strategy.inquireSpo2TestStatus()
    }
    public func setSpo2CollectTime(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionTime) -> Observable<LsSpo2Status.CollectionTime> {
        return strategy.setSpo2CollectTime(status: status, type: type)
    }
    public func setSpo2CollectPeriod(status: Ls02SwitchReverse, type: LsSpo2Status.CollectionPeriod) -> Observable<Ls02SwitchReverse> {
        return strategy.setSpo2CollectPeriod(status: status, type: type)
    }
    public func setWeatherData(_ weathData: [LSWeather]) -> Observable<Bool>{
        return strategy.setWeatherData(weathData)
    }
    
    //生产测试信息
    public func createTestStepsData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return strategy.createTestStepsData(year: year, month: month, day: day)
    }
    public func createTestSleepingData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return strategy.createTestSleepingData(year: year, month: month, day: day)
    }
    public func createTestHeartRateData(year: Int, month: Int, day: Int) -> Observable<Bool>{
        return strategy.createTestHeartRateData(year: year, month: month, day: day)
    }
    public func createTestHeartRateData(sportType: Int, year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Bool>{
        return strategy.createTestHeartRateData(sportType: sportType, year: year, month: month, day: day, hour: hour, min: min)
    }
    //NFC相关
    public func sendNFCData(writeData: Data, characteristic: Int, duration: Int, endRecognition: ((Any) -> Bool)? = nil) -> Observable<BleResponse> {
        return strategy.sendNFCData(writeData: writeData, characteristic: characteristic, duration: duration, endRecognition: endRecognition)
    }

    //GPS相关
    public func requestWatchGPSState() -> Observable<Bool>{
        return strategy.requestWatchGPSState()
    }
    public func deleteWatchGPSData() -> Observable<Bool>{
        return strategy.deleteWatchGPSData()
    }
    public func openWatchGPS(sportType: Int) -> Observable<Bool>{
        return strategy.openWatchGPS(sportType: sportType)
    }
    public func getGPSFirmwareVersion() -> Observable<String> {
        return strategy.getGPSFirmwareVersion()
    }
    public func sentLocationInformation(latitude: Float, longitude: Float, altitude: Float) -> Observable<Bool> {
        return strategy.sentLocationInformation(latitude: latitude, longitude: longitude, altitude: altitude)
    }
    public func closeWatchGPS() -> Observable<Bool>{
        return strategy.closeWatchGPS()
    }
    public func requestGPSSportData(year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Ls02GPSDataBackMode>{
        return strategy.requestGPSSportData(year: year, month: month, day: day, hour: hour, min: min)
    }
    public func startAGPSDataCommand(agpsType: Int) -> Observable<Bool>{
        return strategy.startAGPSDataCommand(agpsType: agpsType)
    }
    public func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatue>{
        return strategy.readyUpdateAGPSCommand(type: type)
    }
    public func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool> {
        return strategy.readyUpdateGPSCommand(type: type)
    }
    public func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool>{
        return strategy.startGPSOTADataCommand(gpsType: gpsType)
    }
    public func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatue>{
        return strategy.sendAGPSDataCommand(gpsData: gpsData, number: number)
    }
    public func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool>{
        return strategy.sendGPSOTADataCommand(gpsData: gpsData, number: number)
    }
    public func checkBeidouDataInvalte() -> Observable<Bool>{
        return strategy.checkBeidouDataInvalte()
    }
    public func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Bool> {
        return strategy.updateAGPComplete(type: type)
    }
    
    //运动记录相关
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: SportModel)>{
        return strategy.getSportModelState()
    }
    public func startSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>{
        return strategy.startSportModel(model: model, state: state, interval: interval)
    }
    public func updateSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval = .m1, speed: Int = 0, flag: Int = 0, senond: Int = 0, duration: Int = 0, cal: Int = 0, distance: Float = 0.0, step: Int = 0) -> Observable<Bool>{
        return strategy.updateSportModel(model:model, state: state, interval: interval, speed:speed, flag: flag, senond: senond, duration: duration, cal: cal, distance: distance, step: step)
    }
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<[SportModelItem]>{
        return strategy.getSportModelHistoryData(datebyFar: datebyFar)
    }
    
    //手表设置相关
    public func setUnitFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool> {
        return strategy.setUnitFormat(unit: unit, date: date)
    }
    public func setDateFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool> {
        return strategy.setDateFormat(unit: unit, date: date)
    }
    public func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool>{
        return strategy.syncDateTime(year, month, day, hour, min, second, timeZone)
    }
    public func getMacAddress() -> Observable<String>{
        return strategy.getMacAddress()
    }
    public func getDeviceVersion() -> Observable<String>{
        return strategy.getDeviceVersion()
    }
    public func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsProtocol>{
        return strategy.requestQuickFunctionSetting()
    }
    public func requesFunctionStatus() -> Observable<String>{
        return strategy.requesFunctionStatus()
    }
    public func getDeviceBattery() -> Observable<UInt8>{
        return strategy.getDeviceBattery()
    }
    public func requestRealtimeSteps() -> Observable<UInt8>{
        return strategy.requestRealtimeSteps()
    }
    public func requestRealtimeHeartRate() -> Observable<UInt8>{
        return strategy.requestRealtimeHeartRate()
    }
    public func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool>{
        return strategy.setHeartRateMeasureMode(settings: settings)
    }
    public func requestCurrentSportMode() -> Observable<UInt8>{
        return strategy.requestCurrentSportMode()
    }
    public func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8>{
        return strategy.setCameraMode(mode: mode)
    }
    public func getAlarmsSupportNum() -> Observable<UInt8>{
        return strategy.getAlarmsSupportNum()
    }
    public func setLongSitNotification(enable:Ls02Switch, targetTime:UInt8, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, donotDistrubAtNoon: Ls02Switch) -> Observable<Bool>{
        return strategy.setLongSitNotification(enable: enable, targetTime: targetTime, startHour: startHour, startMin: startMin, endHour: endHour, endMin: endMin, donotDistrubAtNoon: donotDistrubAtNoon)
    }
    public func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool> {
        return strategy.setNoDisturbanceMode(call: call, message: message, motor: motor, screen: screen, startHour: startHour, startMin: startMin, endHour: endHour, endMin: endMin, enable: enable)
    }
    public func phoneControlPowerOff() -> Observable<UInt8>{
        return strategy.phoneControlPowerOff()
    }
    public func configFoundTelephone(enable: Ls02Switch) -> Observable<UInt8> {
        return strategy.configFoundTelephone(enable: enable)
    }
    public func supportMultiLanguageDisplay(code: UInt8) -> Observable<UInt8> {
        return strategy.supportMultiLanguageDisplay(code: code)
    }
    public func setDeviceParameter(_ height: Int, _ weight: Int, _ brightScreen: UInt8, _ stepGoal: Int, _ raiseSwitch: Ls02Switch, _ maxHrAlert: UInt8, _ minHrAlert: UInt8, _ age: UInt8, _ gender: Ls02Gender, _ lostAlert: Ls02Switch, _ language: Ls02Language, _ temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool> {
        return strategy.setDeviceParameter(height, weight, brightScreen, stepGoal, raiseSwitch, maxHrAlert, minHrAlert, age, gender, lostAlert, language, temperatureUnit)
    }
    public func setReminder(_ reminder: (index: Int, hour: Int, min: Int, period: UInt8, state: Bool)) -> Observable<Bool> {
        return strategy.setReminder((index: reminder.index, hour: reminder.hour, min: reminder.min, period: reminder.period, state: reminder.state))
    }
    public func setANCCItemSwitch(_ item: Ls02ANCCItem, _ itemSwitch: Ls02ANCCSwitch) -> Observable<Bool> {
        return strategy.setANCCItemSwitch(item, itemSwitch)
    }
    public func setSedentary(_ sswitch: Ls02Switch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool> {
        return strategy.setSedentary(sswitch, interval, startHour, startMin, endHour, endMin, noNap)
    }
    public func setNotDisturb(_ sswitch: Ls02Switch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool> {
        return strategy.setNotDisturb(sswitch, startHour, startMin, endHour, endMin, (screen: subSwitch.screen, shock: subSwitch.shock, message: subSwitch.message, call: subSwitch.call))
    }
    
    //表盘相关
    public func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return strategy.getCloudWatchFaceSetting()
    }
    public func writeComplete() -> Observable<Bool> {
        return strategy.writeComplete()
    }
    public func requestCloudWatchFaceTransfer() -> Observable<Bool> {
        return strategy.requestCloudWatchFaceTransfer()
    }
    public func parseCloudWatchFaceSetting(bleResponse: BleResponse) -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return strategy.parseCloudWatchFaceSetting(bleResponse: bleResponse)
    }
    
    public func deviceEntersTestMode(mode: FactoryTestMode) ->Observable<Bool> {
        return strategy.deviceEntersTestMode(mode: mode)
    }

    
}
//MARK: 直接调用的
extension BleOperator {
    public func readValue(type: Int) {
        return strategy.readValue(type: type)
    }
    public func directWrite(_ data: Data, _ type: Int) {
        return strategy.directWrite(data, type)
    }
}
