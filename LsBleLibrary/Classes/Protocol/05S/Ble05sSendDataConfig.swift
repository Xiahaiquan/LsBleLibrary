//
//  SendDataConfig.swift
//  ble_debugging
//
//  Created by Antonio on 2021/5/31.
//

import Foundation
import RxSwift

struct Ble05sSendDataConfig {
    
    static var shared = Ble05sSendDataConfig()
    private init() {}
    
    func getMUT() ->Data  {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetSyncMtu)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func bind(userId: UInt32,
              gender: Ls02Gender,
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
    
    func APPSynchronizesMobilePhoneSystemInformationToBand() ->Data {
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSyncPhoneInfo)
        
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
    
    func configureDoNotDisturbMode(notdisturbTime1: Data,
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
    
    func configureTimeSystemSetting(timeFormat: Ls02TimeFormat) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetTimeFormat)
        cmds.setTimeFormat = PBModel.getSet_time_format_t(timeFormat: timeFormat)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureMetricSettings(metricInch: Ls02Units) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetMetricInch)
        cmds.setMetricInch = PBModel.getSet_metric_inch_t(metricInch: metricInch)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureTheBrightScreenDurationSetting(brightTime: UInt32) ->Data {
        
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSetBrightTimes)
        cmds.setBrightTimes = PBModel.getSet_bright_times_t(brightTime: brightTime)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
    func configureHeartRateWarningSettings(upper: UInt32,
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
    
    func configurationSwitch(item: Ls02ANCCItem, config: UInt64, itemSwitch: Ls02ANCCSwitch) -> Data {

       var configValue = config
       
        switch item {
        case .message:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.sms.rawValue.1, configValue)
        case .qq:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.qq.rawValue.1, configValue)
        case .wechat:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.wechat.rawValue.1, configValue)
        case .telephone:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.call.rawValue.1, configValue)
        case .facebook:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.facebook.rawValue.1, configValue)
        case .twitter:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.twitter.rawValue.1, configValue)
        case .whatsApp:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.whatsapp.rawValue.1, configValue)
        case .facebookMessenger:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.facebook.rawValue.1, configValue)
        case .line:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.line.rawValue.1, configValue)
        case .skype:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.skype.rawValue.1, configValue)
        case .hangouts:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.Hand_up_bright.rawValue.1, configValue) //05s没这个类型
        case .linkedIn:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.linkedin.rawValue.1, configValue)
        case .instagram:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.instagram.rawValue.1, configValue)
        case .viber:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.instagram.rawValue.1, configValue) //05s没这个类型
        case .kakaoTalk:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.kakaotalk.rawValue.1, configValue)
        case .vkontakte:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.kakaotalk.rawValue.1, configValue)//05s没这个类型
        case .snapchat:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.skype.rawValue.1, configValue)//05s没这个类型
        case .googlePlus:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.gmail.rawValue.1, configValue)//05s没这个类型
        case .gmail:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.gmail.rawValue.1, configValue)
        case .flickr:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.feixin.rawValue.1, configValue)//05s没这个类型
        case .tumblr:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.twitter.rawValue.1, configValue)//05s没这个类型
        case .pintrrest:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.pinterest.rawValue.1, configValue)
        case .youtube:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.skype.rawValue.1, configValue)
        default:
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.facetime.rawValue.1, configValue) //以下这些是05s有的04没有
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.feixin.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.sound.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.webook.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.dingtalk.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.aliwangwang.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.alipay.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.qianniu.rawValue.1, configValue)
            configValue = bitManipulation(itemSwitch, YSNotificationTypeEnum.other_app.rawValue.1, configValue)
        }
         
            
        var cmds = Ble05sCmdsConfig.shared.configCmds(.cmdSyncSwitch)
        var bytes = UInt64.self
        cmds.syncSwitch = PBModel.getSync_switch_t(data: Data(bytes: &bytes, count: MemoryLayout<UInt64>.size))
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
            
   }
    func bitManipulation(_ state: Ls02ANCCSwitch, _ index: Int, _ value: UInt64) -> UInt64{
        
        var valueNew = value
        if state == .open {
            valueNew = valueNew | ((1 << index))
        }else {
            valueNew = valueNew & (~(1 << index))
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
    
    func getRealTimeHeartRateInstructionsAndSetIntervals() ->Data {
        
        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdGetRealtimeHr)
        
        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
        
        return contentData
        
    }
    
//    func appQueryData() ->Data {
//        
//        let cmds = Ble05sCmdsConfig.shared.configCmds(.cmdDisturbSwitch)
//        
//        
//        let serializedData = Ble05sCmdsConfig.shared.serializedData(cmds: cmds)
//        let contentData = Ble05sCmdsConfig.shared.buildPBContent(serializedData)
//        
//        return contentData
//        
//    }
    
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
    
    func configSpo2AndHRWarning(type: UInt32,
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
    
}
