//
//  BleCommandProtocol.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

protocol BleCommandProtocol {
    
    func setUserInfo(userId: UInt32,
                     gender: Ls02Gender,
                     age: UInt32,
                     height: UInt32,
                     weight: UInt32,
                     wearstyle: WearstyleEnum) ->Observable<LsBleBindState>
    
    func getmtu() ->Observable<Int>
    
    func configDevice(phoneInfo: (model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: UInt32),
                      switchs: Data,
                      longsit: (duration: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32),
                      drinkSlot: (drinkSlot: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32),
                      alarms: [AlarmModel],
                      countryInfo: (name: Data, timezone: UInt32),
                      uiStyle: (style: UInt32, clock: UInt32),
                      target: (cal: UInt32, dis: UInt32, step: UInt32),
                      timeFormat: Ls02TimeFormat,
                      metricInch: Ls02Units,
                      brightTime: UInt32,
                      upper: UInt32,
                      lower: UInt32,
                      code: UInt32,
                      duration: UInt32) -> Observable<Bool>
    
    
    func getBraceletSystemInformation() -> Observable<Int>
    
    func APPSynchronizesMobilePhoneSystemInformationToBand() -> Observable<Int>
    
    func configureSportsGoalSettings(cal: UInt32,
                                     dis: UInt32,
                                     step: UInt32) -> Observable<Int>
    
    func APPSynchronizationSwitchInformationToBracelet(switchs: Data) -> Observable<Int>
    
    func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool>
    
    func configureSedentaryJudgmentInterval(longsitDuration: UInt32,
                                            startTime: UInt32,
                                            endTime: UInt32,
                                            nodisturbStartTime: UInt32,
                                            nodisturbEndTime: UInt32) ->Observable<Bool>
    
    func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                           startTime: UInt32,
                                           endTime: UInt32,
                                           nodisturbStartTime: UInt32,
                                           nodisturbEndTime: UInt32) ->Observable<Bool>
    
    func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool>
    
    func configureDoNotDisturbMode(notdisturbTime1: Data,
                                   notdisturbTime2: Data) ->Observable<Bool>
    
    func configureCountryInformation(name: Data,
                                     timezone: UInt32) ->Observable<Bool>
    
    func configureUIStyle(style: UInt32,
                          clock: UInt32) ->Observable<Bool>
    
    
    func configureTheBrightScreenDurationSetting(brightTime: UInt32)->Observable<Bool>
    
    func configureHeartRateWarningSettings(upper: UInt32,
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
    
    func getRealTimeHeartRateInstructionsAndSetIntervals() ->Observable<Bool>
    
    //    func appQueryData() ->Observable<Bool>
    
    func getStepAfterHistoryData() ->Observable<Bool>
    
    
    func checkGpsInfo(type: UInt32,
                      num: UInt32,
                      second: UInt32,
                      version: UInt32) ->Observable<Bool>
    
    func checkFuncPageSettings(type: UInt32,
                               page: UInt32) ->Observable<LSFunctionTag>
    
    func getDialConfigurationInformation() ->Observable<Bool>
    
    func configSpo2AndHRWarning(type: UInt32,
                                min: UInt32,
                                max: UInt32) ->Observable<Bool>
    
    func setSpo2Detect(enable: SwitchStatusEnum,
                       intersec: UInt32) ->Observable<Bool>
    
    func getSpo2Detect(enable: SwitchStatusEnum,
                       intersec: UInt32) ->Observable<Bool>
    
    func getMenuConfig(type: UInt32) ->Observable<Bool>
    
    func configMenu(type: UInt32,
                    count: UInt32,
                    data: Data) ->Observable<Bool>
    
    func getWatchLog() ->Observable<Bool>
    
    func setAppStatus(status: AppStatusEnum) ->Observable<Bool>
    
    func getWatchAlarm() ->Observable<Bool>
    
    func findTheBraceletCommand() ->Observable<Bool>
    
    func thisDoesItExist(data: Data, type: BinFileTypeEnum) ->Observable<Bool>
    
    func dialPB(sn:UInt32, data: Data) ->Observable<Bool>
    
    func checkWatchFaceStatus(data: Data, type: BinFileTypeEnum) ->Observable<Bool>
    
    func dailUpgradeWatch(data: Data) ->Observable<DialUpgradeProcess>
    
    func makeTestData() ->Observable<Bool>
    
    
    func getHealthData(syncType: HealthDataSyncType,
                       secondStart: UInt32,
                       secondEnd: UInt32) -> Observable<[BigDataProtocol]>
    
    
    func unBindDevice(mode: UInt32) -> Observable<Bool>
    
    //MARK: 以上是05S的协议，以下是04的协议
    func sentBindcmd(_ userId: Int) -> Observable<LsBleBindState>
    func bindDevice(_ userId: Int) ->Observable<LsBleBindState>
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
    func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatue>
    func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Bool>
    func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool>
    func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool>
    func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatue>
    func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool>
    func checkBeidouDataInvalte() -> Observable<Bool>
    
    //运动记录相关
    func getSportModelState() -> Observable<(state: SportModelState, sportModel: SportModel)>
    func startSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>
    func updateSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval, speed: Int, flag: Int, senond: Int,duration: Int, cal: Int, distance: Float, step: Int) -> Observable<Bool>
    func getSportModelHistoryData(datebyFar: Date) -> Observable<[SportModelItem]>
    
    //手表设置相关
    func setUnitFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool>
    func setDateFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool>
    
    func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool>
    func getMacAddress() -> Observable<String>
    func getDeviceVersion() -> Observable<String>
    func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsProtocol>
    func requesFunctionStatus() -> Observable<String>
    func getDeviceBattery() -> Observable<UInt8>
    func requestRealtimeSteps() -> Observable<UInt8>
    func requestRealtimeHeartRate() -> Observable<UInt8>
    func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool>
    func requestCurrentSportMode() -> Observable<UInt8>
    func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8>
    func getAlarmsSupportNum() -> Observable<UInt8>
    func setLongSitNotification(enable:Ls02Switch, targetTime:UInt8, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, donotDistrubAtNoon: Ls02Switch) -> Observable<Bool>
    func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool>
    func phoneControlPowerOff() -> Observable<UInt8>
    func configFoundTelephone(enable: Ls02Switch) -> Observable<UInt8>
    func supportMultiLanguageDisplay(code: UInt8) -> Observable<UInt8>
    func setDeviceParameter(_ height: Int, _ weight: Int, _ brightScreen: UInt8, _ stepGoal: Int, _ raiseSwitch: Ls02Switch, _ maxHrAlert: UInt8, _ minHrAlert: UInt8, _ age: UInt8, _ gender: Ls02Gender, _ lostAlert: Ls02Switch, _ language: Ls02Language, _ temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool>
    func setReminder(_ reminder: (index: Int, hour: Int, min: Int, period: UInt8, state: Bool)) -> Observable<Bool>
    func setANCCItemSwitch(_ item: Ls02ANCCItem, _ itemSwitch: Ls02ANCCSwitch) -> Observable<Bool>
    func setSedentary(_ sswitch: Ls02Switch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool>
    func setNotDisturb(_ sswitch: Ls02Switch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool>
    
    //表盘相关
    func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)>
    func writeComplete() -> Observable<Bool>
    func requestCloudWatchFaceTransfer() -> Observable<Bool>
    func parseCloudWatchFaceSetting(bleResponse: BleResponse) -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)>
    
    //可以直接调用蓝牙库的方法
    func readValue(type: Int)
    func directWrite(_ data: Data, _ type: Int)
    
}

//MARK: 05S的协议默认实现
extension BleCommandProtocol {
    func getmtu() ->Observable<Int> {
        return Observable.just(180)
    }
    
    func setUserInfo(userId: UInt32,  gender: Ls02Gender, age: UInt32, height: UInt32, weight: UInt32,wearstyle: WearstyleEnum) ->Observable<LsBleBindState> {
        return Observable<LsBleBindState>.empty()
    }
    
    func configDevice(phoneInfo: (model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: UInt32), switchs: Data, longsit: (duration: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), drinkSlot: (drinkSlot: UInt32, startTime: UInt32, endTime: UInt32, nodisturbStartTime: UInt32, nodisturbEndTime: UInt32), alarms: [AlarmModel], countryInfo: (name: Data, timezone: UInt32), uiStyle: (style: UInt32, clock: UInt32), target: (cal: UInt32, dis: UInt32, step: UInt32), timeFormat: Ls02TimeFormat, metricInch: Ls02Units, brightTime: UInt32, upper: UInt32, lower: UInt32, code: UInt32, duration: UInt32) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    public func getBraceletSystemInformation() -> Observable<Int> {
        return Observable.just(1)
    }
    
    public func APPSynchronizesMobilePhoneSystemInformationToBand() -> Observable<Int> {
        return Observable.just(2)
    }
    
    public func configureSportsGoalSettings(cal: UInt32,
                                            dis: UInt32,
                                            step: UInt32) -> Observable<Int> {
        return Observable.just(3)
    }
    
    public func APPSynchronizationSwitchInformationToBracelet(switchs: Data) -> Observable<Int> {
        return Observable.just(4)
    }
    
    public func configureRealTimeHeartRateCollectionInterval(slot: UInt32) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureSedentaryJudgmentInterval(longsitDuration: UInt32,
                                                   startTime: UInt32,
                                                   endTime: UInt32,
                                                   nodisturbStartTime: UInt32,
                                                   nodisturbEndTime: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                                  startTime: UInt32,
                                                  endTime: UInt32,
                                                  nodisturbStartTime: UInt32,
                                                  nodisturbEndTime: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureAlarmReminder(alarms: [AlarmModel]) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureDoNotDisturbMode(notdisturbTime1: Data,
                                          notdisturbTime2: Data) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureCountryInformation(name: Data,
                                            timezone: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureUIStyle(style: UInt32,
                                 clock: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureTheBrightScreenDurationSetting(brightTime: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configureHeartRateWarningSettings(upper: UInt32,
                                                  lower: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func requestHeartRateData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func notificationReminder(type: UInt32,
                                     titleLen: UInt32,
                                     msgLen: UInt32,
                                     reserved: Data,
                                     title: Data,
                                     msg: Data,
                                     utc: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func getBattery() ->Observable<UInt32> {
        return Observable.just(0)
    }
    
    public func upgradeCommand(version: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func restoreFactorySettings(mode: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
    public func deviceEntersTestMode(mode: FactoryTestMode) ->Observable<Bool> {
        return Observable<Bool>.empty()
    }
    
    public func getRealTimeHeartRateInstructionsAndSetIntervals() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    //    public func appQueryData() ->Observable<Bool> {
    //        return Observable.just(true)
    //    }
    
    public func getStepAfterHistoryData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
    public func checkGpsInfo(type: UInt32,
                             num: UInt32,
                             second: UInt32,
                             version: UInt32) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func checkFuncPageSettings(type: UInt32,
                                      page: UInt32) ->Observable<LSFunctionTag> {
        return Observable<LSFunctionTag>.empty()
    }
    
    public func getDialConfigurationInformation() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func configSpo2AndHRWarning(type: UInt32,
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
    
    public func getMenuConfig(type: UInt32) ->Observable<Bool> {
        return Observable.just(true)
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
    
    public  func thisDoesItExist(data: Data, type: BinFileTypeEnum) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    public func dialPB(sn:UInt32, data: Data) ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
        public func dailUpgradeWatch(data: Data) ->Observable<DialUpgradeProcess> {
            return Observable<DialUpgradeProcess>.empty()
        }
    
    public func checkWatchFaceStatus(data: Data, type: BinFileTypeEnum) ->Observable<Bool> {
        return Observable<Bool>.empty()
    }
    
    public func makeTestData() ->Observable<Bool> {
        return Observable.just(true)
    }
    
    
    public func getHealthData(syncType: HealthDataSyncType,
                              secondStart: UInt32,
                              secondEnd: UInt32) -> Observable<[BigDataProtocol]> {
        return Observable.just([DayStepModel.init()])
    }
    
    
    public func unBindDevice(mode: UInt32) -> Observable<Bool> {
        return Observable.just(true)
    }
    
}
//MARK: 04协议的默认实现
extension BleCommandProtocol {
    func sentBindcmd(_ userId: Int) -> Observable<LsBleBindState>{
        return Observable<LsBleBindState>.empty()
    }
    func bindDevice(_ userId: Int) ->Observable<LsBleBindState>{
        return Observable<LsBleBindState>.empty()
    }
    public func getHistoryHeartrateData(dateByFar: Date) -> Observable<(datetime: String, heartRateDatas: [UInt8])> {
        return Observable.just((datetime: "", heartRateDatas: [0]))
    }
    public func getHistorySp02Data(dateByFar: Date) -> Observable<(datetime: String, spo2s: [UInt8])> {
        return Observable.just((datetime: "", spo2s: [0]))
    }
    public func getHistoryDayData(dateByFar: Date) -> Observable<Ls02SportInfo> {
        return Observable.just(Ls02SportInfo.init(year: 0, month: 0, day: 0, hour: 0, totalStep: 0, runStart: 0, runEnd: 0, runDuration: 0, runStep: 0, walkStart: 0, walkEnd: 0, walkDuration: 0, walkStep: 0))
    }
    public func getHistorySleepData(dateByFar: Date) -> Observable<[Ls02SleepInfo]> {
        return Observable.just([Ls02SleepInfo.init(year: 0, month: 0, day: 0, dataCount: 0, sleepItems: [Ls02SleepItem.init(startHour: 0, startMin: 0, sleepDuration: 0, state: .awake, flag: .daytime)])])
    }
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
    public func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatue>{
        return Observable<Ls02ReadyUpdateAGPSStatue>.empty()
    }
    public func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool> {
        return Observable<Bool>.empty()
    }
    public func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatue>{
        return Observable<Ls02ReadyUpdateAGPSStatue>.empty()
    }
    public func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func checkBeidouDataInvalte() -> Observable<Bool>{
        return Observable.just(true)
    }
    public func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Bool> {
        return Observable<Bool>.empty()
    }
    
    //运动记录相关
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: SportModel)>{
        return Observable.just((state: .start, sportModel: .badminton))
    }
    public func startSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func updateSportModel(model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval = .m1, speed: Int = 0, flag: Int = 0, senond: Int = 0,duration: Int = 0, cal: Int = 0, distance: Float = 0.0, step: Int = 0) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<[SportModelItem]>{
        return Observable.just([SportModelItem.init(sportModel: .badminton, heartRateNum: 0, startTime: "", endTime: "", step: 0, count: 0, cal: 0, distance: "", hrAvg: 0, hrMax: 0, hrMin: 0, pace: 0, hrInterval: 0, heartRateData: Data())])
    }
    
    //手表设置相关
    public func setUnitFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool> {
        Observable.just(true)
    }
    public func setDateFormat(unit: Ls02Units, date: Ls02TimeFormat) -> Observable<Bool> {
        Observable.just(true)
    }
    
    public func syncDateTime(_ year: Int, _ month: UInt8, _ day: UInt8, _ hour: UInt8, _ min: UInt8, _ second: UInt8, _ timeZone: UInt8) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func getMacAddress() -> Observable<String>{
        return Observable.just("")
    }
    public func getDeviceVersion() -> Observable<String>{
        return Observable.just("")
    }
    public func requestQuickFunctionSetting() -> Observable<Ls02sShortcutSwitchsProtocol>{
        return Observable<Ls02sShortcutSwitchsProtocol>.empty()
    }
    public func requesFunctionStatus() -> Observable<String>{
        return Observable.just("")
    }
    public func getDeviceBattery() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func requestRealtimeSteps() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func requestRealtimeHeartRate() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func setHeartRateMeasureMode(settings: Ls02HRdetectionSettings) -> Observable<Bool>{
        return Observable<Bool>.empty()
    }
    public func requestCurrentSportMode() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func setCameraMode(mode: Ls02CameraMode) -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func getAlarmsSupportNum() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func setLongSitNotification(enable:Ls02Switch, targetTime:UInt8, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, donotDistrubAtNoon: Ls02Switch) -> Observable<Bool>{
        return Observable.just(true)
    }
    public func setNoDisturbanceMode(call: Bool, message: Bool, motor: Bool,screen: Bool, startHour: UInt8, startMin: UInt8, endHour: UInt8, endMin: UInt8, enable: Bool) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func phoneControlPowerOff() -> Observable<UInt8>{
        return Observable.just(0)
    }
    public func configFoundTelephone(enable: Ls02Switch) -> Observable<UInt8> {
        return Observable.just(0)
    }
    public func supportMultiLanguageDisplay(code: UInt8) -> Observable<UInt8> {
        return Observable.just(0)
    }
    public func setDeviceParameter(_ height: Int, _ weight: Int, _ brightScreen: UInt8, _ stepGoal: Int, _ raiseSwitch: Ls02Switch, _ maxHrAlert: UInt8, _ minHrAlert: UInt8, _ age: UInt8, _ gender: Ls02Gender, _ lostAlert: Ls02Switch, _ language: Ls02Language, _ temperatureUnit: Ls02TemperatureUnit) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setReminder(_ reminder: (index: Int, hour: Int, min: Int, period: UInt8, state: Bool)) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setANCCItemSwitch(_ item: Ls02ANCCItem, _ itemSwitch: Ls02ANCCSwitch) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setSedentary(_ sswitch: Ls02Switch, _ interval: UInt8, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ noNap: Ls02SwitchReverse) -> Observable<Bool> {
        return Observable.just(true)
    }
    public func setNotDisturb(_ sswitch: Ls02Switch, _ startHour: UInt8, _ startMin: UInt8, _ endHour: UInt8, _ endMin: UInt8, _ subSwitch: (screen: Bool, shock: Bool, message: Bool, call: Bool)) -> Observable<Bool> {
        return Observable.just(true)
    }
    
    //表盘相关
    public func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return Observable.just((watchFaceNo: 0, watchFaceWidth: 0, watchFaceHeight: 0, watchFaceType: 0, maxSpace: 0))
    }
    public func writeComplete() -> Observable<Bool> {
        return Observable.just(true)
    }
    public func requestCloudWatchFaceTransfer() -> Observable<Bool> {
        return Observable.just(true)
    }
    public func parseCloudWatchFaceSetting(bleResponse: BleResponse) -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return Observable.just((watchFaceNo: 0, watchFaceWidth: 0, watchFaceHeight: 0, watchFaceType: 0, maxSpace: 0))
    }
    
}
//MARK: 直接调用蓝牙库方法的默认实现
extension BleCommandProtocol {
    public func readValue(type: Int) {
        
    }
    public func directWrite(_ data: Data, _ type: Int) {
        
    }
}
 

