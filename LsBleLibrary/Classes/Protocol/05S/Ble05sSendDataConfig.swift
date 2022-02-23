//
//  SendDataConfig.swift
//  ble_debugging
//
//  Created by Antonio on 2021/5/31.
//

import Foundation
import RxSwift

public struct Ble05sSendDataConfig {
    
    public static var shared = Ble05sSendDataConfig()
//    private var switchValue: UInt64 = 0x00
    private init() {}
    
    func getMUT() ->Data  {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetSyncMtu)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func bind(userId: UInt32,
              gender: LsGender,
              age: UInt32,
              height: UInt32,
              weight: UInt32,
              wearstyle: WearstyleEnum) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdBindDevice)
        
        cmds.setAppInfo = PBModel.getBind_app_info_t(userId: userId, gender: gender, age: age, height:height, weight: weight, wearstyle: wearstyle)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configDevice(phoneInfo: (model: PhoneTypeEnum,
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
                      duration: UInt32) ->Data {
        
        var hlCmd = Ble05sCmdsConfig.shared.configCmds(.cmdSetAllConfigParam)
        
        hlCmd.syncPhoneInfo = PBModel.getSync_phone_info_t(phonemodel: phoneInfo.model,
                                                           systemversion: phoneInfo.systemversion,
                                                           appversion: phoneInfo.appversion,
                                                           language: phoneInfo.language)
        hlCmd.syncSwitch = PBModel.getSync_switch_t(switchs: switchs)
        hlCmd.setLongsitDuration = PBModel.getSet_longsit_duration_t(longsitDuration: longsit.duration,
                                                                     startTime: longsit.startTime,
                                                                     endTime: longsit.endTime,
                                                                     nodisturbStartTime: longsit.nodisturbStartTime,
                                                                     nodisturbEndTime: longsit.nodisturbEndTime)
        hlCmd.setDrinkSlot = PBModel.getSet_drink_slot_t(drinkSlot: drinkSlot.drinkSlot,
                                                         startTime: drinkSlot.startTime,
                                                         endTime: drinkSlot.endTime,
                                                         nodisturbStartTime: drinkSlot.nodisturbStartTime,
                                                         nodisturbEndTime: drinkSlot.nodisturbEndTime)
        hlCmd.setAlarms = PBModel.getSet_alarms_t(alarms: alarms)
        hlCmd.setCountryInfo = PBModel.getSet_country_info_t(name: countryInfo.name,
                                                             timezone: countryInfo.timezone)
        
        hlCmd.setUiStyle = PBModel.getSet_ui_style_t(style: uiStyle.style,
                                                     clock: uiStyle.clock)
        
        hlCmd.setSportTarget = PBModel.getSet_sport_target_t(cal: target.cal,
                                                             dis: target.dis,
                                                             step: target.step)
        
        hlCmd.setTimeFormat = PBModel.getSet_time_format_t(timeFormat: timeFormat)
        hlCmd.setMetricInch = PBModel.getSet_metric_inch_t(metricInch: metricInch)
        hlCmd.setBrightTimes = PBModel.getSet_bright_times_t(brightTime: brightTime)
        hlCmd.setSetHrWarning = PBModel.getSet_hr_warning_t(upper: upper,
                                                            lower: lower)
        hlCmd.setMusicInfo = PBModel.getSet_music_info_t(code: code)
        hlCmd.setHrDur = PBModel.getSet_rtimehr_dur_t(duration: duration)
        
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: hlCmd)
        
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
    }
    
    
    func getBraceletSystemInformation() ->Data {
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetDeviceInfo)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        return contentData
    }
    
    func syncPhoneInfoToLS(model: PhoneTypeEnum, systemversion: UInt32, appversion: UInt32, language: LSDeviceLanguageEnum) ->Data {
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSyncPhoneInfo)
        cmds.syncPhoneInfo = PBModel.getSync_phone_info_t(phonemodel: model, systemversion: systemversion, appversion: appversion, language: language)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        return contentData
    }
    
    func configureSportsGoalSettings(cal: UInt32,
                                     dis: UInt32,
                                     step: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetSportTarget)
        cmds.setSportTarget = PBModel.getSet_sport_target_t(cal: cal, dis: dis, step: step)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func APPSynchronizationSwitchInformationToBracelet(switchs: Data) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSyncSwitch)
        cmds.syncSwitch = PBModel.getSync_switch_t(switchs: switchs)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureRealTimeHeartRateCollectionInterval(slot: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetHrSampleSlot)
        cmds.setHrSampleSlot = PBModel.getSet_hr_sample_slot_t(slot: slot)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureSedentaryJudgmentInterval(longsitDuration: UInt32,
                                            startTime: UInt32,
                                            endTime: UInt32,
                                            nodisturbStartTime: UInt32,
                                            nodisturbEndTime: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetLongsitDuration)
        cmds.setLongsitDuration = PBModel.getSet_longsit_duration_t(longsitDuration: longsitDuration, startTime: startTime, endTime: endTime, nodisturbStartTime: nodisturbStartTime, nodisturbEndTime: nodisturbEndTime)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureDrinkingReminderInterval(drinkSlot: UInt32,
                                           startTime: UInt32,
                                           endTime: UInt32,
                                           nodisturbStartTime: UInt32,
                                           nodisturbEndTime: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetDrinkSlot)
        cmds.setDrinkSlot = PBModel.getSet_drink_slot_t(drinkSlot: drinkSlot, startTime: startTime, endTime: endTime, nodisturbStartTime: nodisturbStartTime, nodisturbEndTime: nodisturbEndTime)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureAlarmReminder(alarms: [AlarmModel]) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetAlarms)
        cmds.setAlarms = PBModel.getSet_alarms_t(alarms: alarms)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureDoNotDisturbTime(notdisturbTime1: Data,
                                   notdisturbTime2: Data) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetNotdisturb)
        cmds.setNotdisturb = PBModel.getSet_notdisturb_t(notdisturbTime1: notdisturbTime1, notdisturbTime2: notdisturbTime2)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureCountryInformation(name: Data,
                                     timezone: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetCountryInfo)
        cmds.setCountryInfo = PBModel.getSet_country_info_t(name: name, timezone: timezone)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureUIStyle(style: UInt32,
                          clock: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetUiStyle)
        cmds.setUiStyle = PBModel.getSet_ui_style_t(style: style, clock: clock)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureTimeSystemSetting(timeFormat: DeviceTimeFormat) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetTimeFormat)
        cmds.setTimeFormat = PBModel.getSet_time_format_t(timeFormat: timeFormat)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureMetricSettings(metricInch: DeviceUnitsFormat) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetMetricInch)
        cmds.setMetricInch = PBModel.getSet_metric_inch_t(metricInch: metricInch)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureTheBrightScreenDuration(brightTime: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetBrightTimes)
        cmds.setBrightTimes = PBModel.getSet_bright_times_t(brightTime: brightTime)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureHeartRateWarning(upper: UInt32,
                                           lower: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetHrWarning)
        cmds.setSetHrWarning = PBModel.getSet_hr_warning_t(upper: upper,
                                                           lower: lower)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func requestHeartRateData() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetHrValue)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func notificationReminder(type: UInt32,
                              titleLen: UInt32,
                              msgLen: UInt32,
                              reserved: Data,
                              title: Data,
                              msg: Data,
                              utc: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetNotifyWarn)
        cmds.setNotifyWarnInfo = PBModel.getSet_notify_warning_t(type: type,
                                                                 titleLen: titleLen,
                                                                 msgLen: msgLen,
                                                                 reserved: reserved,
                                                                 title: reserved,
                                                                 msg: msg,
                                                                 utc: utc)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func syncHealthData(syncType: HealthDataSyncType,
                        secondStart: UInt32,
                        secondEnd: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetSyncHealthData)
        cmds.setHealthDataInfo = PBModel.get_sync_health_data_t(syncType: syncType,
                                                                secondStart: secondStart,
                                                                secondEnd: secondEnd)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getBattery() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetPowerValue)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func upgradeCommand(version: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetUpdataFw)
        cmds.setUpdataFw = PBModel.getSet_updata_fw_t(version: version)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func appWeatherDataSyncedToDevice(weathers: [LSWeather]) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetWeatherInfo)
        cmds.setWeatherInfo = PBModel.getSet_weather_info_t(weathers: weathers)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func restoreFactorySettings(mode: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetResetMachine)
        cmds.setResetMachine = PBModel.getSet_reset_machine_t(mode: mode)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
    }
    
    func configurationSwitch(item: LsANCSItem, itemSwitch: LsANCSSwitch, switchConfigValue: UInt64) -> Data {
        
        var switchValue = switchConfigValue
        switch item {
        case .message:
            switchValue = bitManipulation(itemSwitch, .sms, switchValue)
        case .qq:
            switchValue = bitManipulation(itemSwitch, .qq, switchValue)
        case .wechat:
            switchValue = bitManipulation(itemSwitch, .wechat, switchValue)
        case .telephone:
            switchValue = bitManipulation(itemSwitch, .call, switchValue)
        case .facebook:
            switchValue = bitManipulation(itemSwitch, .facebook, switchValue)
        case .twitter:
            switchValue = bitManipulation(itemSwitch, .twitter, switchValue)
        case .whatsApp:
            switchValue = bitManipulation(itemSwitch, .whatsapp, switchValue)
        case .facebookMessenger:
            switchValue = bitManipulation(itemSwitch, .facebook, switchValue)
        case .line:
            switchValue = bitManipulation(itemSwitch, .line, switchValue)
        case .skype:
            switchValue = bitManipulation(itemSwitch, .skype, switchValue)
        case .handUpBright:
            switchValue = bitManipulation(itemSwitch, .Hand_up_bright, switchValue)
        case .linkedIn:
            switchValue = bitManipulation(itemSwitch, .linkedin, switchValue)
        case .instagram:
            switchValue = bitManipulation(itemSwitch, .instagram, switchValue)
        case .viber:
            switchValue = bitManipulation(itemSwitch, .instagram, switchValue) //05s没这个类型
        case .kakaoTalk:
            switchValue = bitManipulation(itemSwitch, .kakaotalk, switchValue)
        case .vkontakte:
            switchValue = bitManipulation(itemSwitch, .kakaotalk, switchValue)//05s没这个类型
        case .snapchat:
            switchValue = bitManipulation(itemSwitch, .skype, switchValue)//05s没这个类型
        case .googlePlus:
            switchValue = bitManipulation(itemSwitch, .gmail, switchValue)//05s没这个类型
        case .gmail:
            switchValue = bitManipulation(itemSwitch, .gmail, switchValue)
        case .flickr:
            switchValue = bitManipulation(itemSwitch, .feixin, switchValue)//05s没这个类型
        case .tumblr:
            switchValue = bitManipulation(itemSwitch, .twitter, switchValue)//05s没这个类型
        case .pintrrest:
            switchValue = bitManipulation(itemSwitch, .pinterest, switchValue)
        case .youtube:
            switchValue = bitManipulation(itemSwitch, .skype, switchValue)
        default:
            switchValue = bitManipulation(itemSwitch, .facetime, switchValue) //以下这些是05s有的04没有
            switchValue = bitManipulation(itemSwitch, .feixin, switchValue)
            switchValue = bitManipulation(itemSwitch, .sound, switchValue)
            switchValue = bitManipulation(itemSwitch, .webook, switchValue)
            switchValue = bitManipulation(itemSwitch, .dingtalk, switchValue)
            switchValue = bitManipulation(itemSwitch, .aliwangwang, switchValue)
            switchValue = bitManipulation(itemSwitch, .alipay, switchValue)
            switchValue = bitManipulation(itemSwitch, .qianniu, switchValue)
            switchValue = bitManipulation(itemSwitch, .other_app, switchValue)
        }
        
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSyncSwitch)
        
        cmds.syncSwitch = PBModel.getSync_switch_t(switchs: withUnsafeBytes(of: switchValue) { Data($0) })
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    public func bitManipulation(_ state: LsANCSSwitch, _ index: YSNotificationTypeEnum, _ value: UInt64) -> UInt64{
        
        var valueNew = value
        if state == .open {
            valueNew = valueNew | ((1 << index.rawValue.1))
        }else {
            valueNew = valueNew & (~(1 << index.rawValue.1))
        }
        
        return valueNew
    }
    
    func APPMultiMotionControl(mode: UInt32,
                               status: UInt32,
                               speed: UInt32,
                               distance: Float,
                               calorie: UInt32,
                               flag: UInt32,
                               duration: UInt32,
                               second: UInt32,
                               step: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetSportStatus)
        cmds.setSportStatus = PBModel.getSet_sport_status_t(mode: mode,
                                                            status: status,
                                                            speed: speed,
                                                            distance: distance,
                                                            calorie: calorie,
                                                            flag: calorie,
                                                            duration: duration,
                                                            second: second,
                                                            step: step)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func checkSportStatus() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdCheckSportStatus)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func deviceEntersTestMode() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdFactoryTestMode)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getRealTimeHeartRate() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetRealtimeHr)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func appQueryData() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdDisturbSwitch)
        
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func makeTestData() ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetMakeTestData)
        cmds.cmd = .cmdSetMakeTestData
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func multiSportQuery(startTime: UInt32,
                         endTime: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetActiveRecordData)
        cmds.rSetActiveInfo = PBModel.getSet_active_info_t(startTime: startTime,
                                                           endTime: endTime)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getStepAfterHistoryData() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSyncStepCount)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    
    func checkGpsInfo(type: UInt32,
                      num: UInt32,
                      second: UInt32,
                      version: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetCheckGpsInfo)
        cmds.setCheckGpsInfo = PBModel.getSet_check_gps_info_t(type: type,
                                                               num: num,
                                                               second: second,
                                                               version: version)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    
    func checkFuncPageSettings(type: UInt32,
                               page: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetPageSwitch)
        cmds.setPageSwitch = PBModel.getSet_page_switch_t(type: type,
                                                          page: page)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getDialConfigurationInformation() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetDialConfigData)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configSpo2AndHRWarning(type: HealthMonitorEnum,
                                min: UInt32,
                                max: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetWarmingData)
        cmds.setWarmingData = PBModel.getSet_warming_data_t(type: type,
                                                            min: min,
                                                            max: max)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func setSpo2Detect(enable: SwitchStatusEnum,
                       intersec: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetSpo2Detect)
        cmds.setSpo2Detect = PBModel.getSet_spo2_detect_t(enable: enable,
                                                          intersec: intersec)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getSpo2Detect(enable: SwitchStatusEnum,
                       intersec: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetSpo2Detect)
        cmds.rGetSpo2Detect = PBModel.getSpo2_detect_t(enable: enable,
                                                       intersec: intersec)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getMenuConfig(type: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetMenuSequenceData)
        cmds.getMenuSeqData = PBModel.getMenu_sequence_t(type: type)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    
    func configMenu(type: UInt32,
                    count: UInt32,
                    data: Data) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetMenuSequenceData)
        cmds.setMenuSeqData = PBModel.getSet_menu_sequence_t(type: type,
                                                             count: count,
                                                             data: data)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    
    func getWatchLog() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetLogInfoData)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func setAppStatus(status: AppStatusEnum) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdPhoneAppSetStatus)
        cmds.setPhoneAppStatus = PBModel.getSet_phone_app_status_t(status: status)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func getWatchAlarm() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetAlarms)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    
    func findTheBraceletCommand() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetFindDev)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    
    func thisDoesItExist(data: Data, type: BinFileTypeEnum) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSendBigData)
        
        cmds.setBigData = PBModel.geteSet_big_data_t(data: data, type: type)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func dialPB(sn:UInt32, data: Data) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetBinDataUpdate)
        
        cmds.setBinData = PBModel.geteSet_bin_data_t(sn: sn, data: data)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    public func change(notificationType: YSNotificationTypeEnum, statusFirst: DeviceSwitch, statusSecond: DeviceSwitch) ->Data {
        
        var dataSend = Data()
        //head
        
        dataSend.append(Data([UInt8(notificationType.rawValue.0)]))
        
        var allOpen: UInt8 = 3
        if statusFirst == .open {
            allOpen = allOpen | ((1 << 0))
        }else {
            allOpen = allOpen & (~(1 << 0))
        }
        
        if statusSecond == .open {
            allOpen = allOpen | ((1 << 1))
        }else {
            allOpen = allOpen & (~(1 << 1))
        }
        
        dataSend.append(Data([allOpen]))
        
        return dataSend
        
    }
    
    func handle(value: String) ->(hour: UInt8, min: UInt8) {
        var s_hour = 0
        var s_min = 0
        let startTimeArray = value.components(separatedBy: ":")
        if let hour = startTimeArray.first, let min = startTimeArray.last {
            s_hour = (hour as NSString).integerValue
            s_min = (min as NSString).integerValue
        }
        return (hour: UInt8(s_hour), min: UInt8(s_min))
    }
    
}
