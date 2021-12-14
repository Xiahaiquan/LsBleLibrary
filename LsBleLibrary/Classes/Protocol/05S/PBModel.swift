//
//  PBModel.swift
//  ble_debugging
//
//  Created by Antonio on 2021/6/2.
//

import Foundation

struct PBModel {
    
    static func getBind_app_info_t(userId: UInt32,
                                   gender: Ls02Gender,
                                   age: UInt32,
                                   height: UInt32,
                                   weight: UInt32,
                                   wearstyle: WearstyleEnum) ->bind_app_info_t {
        
        var info = bind_app_info_t()
        info.mUsrid = userId
        info.mGender = UInt32(gender.rawValue)
        info.mAge = age
        info.mHeight = height
        info.mWeight = weight
        info.mWearstyle = UInt32(wearstyle.rawValue)
        return info
    }
    
    static func getSync_phone_info_t(phonemodel: PhoneTypeEnum,
                                     systemversion: UInt32,
                                     appversion: UInt32,
                                     language: UInt32) ->sync_phone_info_t {
        var info = sync_phone_info_t()
        info.mPhonemodel = UInt32(phonemodel.rawValue)
        info.mSystemversion = systemversion
        info.mAppversion = appversion
        info.mLanguage = language
        return info
    }
    
    static func getSync_switch_t(switchs: Data) ->sync_switch_t {
        var info = sync_switch_t()
        info.mSwitchs = switchs
        
        return info
    }
    
    static func getSet_longsit_duration_t(longsitDuration: UInt32,
                                          startTime: UInt32,
                                          endTime: UInt32,
                                          nodisturbStartTime: UInt32,
                                          nodisturbEndTime: UInt32) -> set_longsit_duration_t {
        var info = set_longsit_duration_t()
        info.mLongsitDuration = longsitDuration
        info.mStartTime = startTime
        info.mEndTime = endTime
        info.mNodisturbStartTime = nodisturbStartTime
        info.mNodisturbEndTime = nodisturbEndTime
        
        return info
    }
    static func getSet_drink_slot_t(drinkSlot: UInt32,
                                    startTime: UInt32,
                                    endTime: UInt32,
                                    nodisturbStartTime: UInt32,
                                    nodisturbEndTime: UInt32) ->set_drink_slot_t {
        var info = set_drink_slot_t()
        info.mDrinkSlot = drinkSlot
        info.mStartTime = startTime
        info.mEndTime = endTime
        
        info.mNodisturbStartTime = nodisturbStartTime
        info.mNodisturbEndTime = nodisturbEndTime
        
        return info
    }
    
    static func getSet_alarms_t(alarms: [AlarmModel]) ->set_alarms_t {
        
        var info = set_alarms_t()
        
        for item in alarms {
            
            var alarm = alarm_t()
            
            alarm.mAlarm1Min = item.min
            alarm.mAlarm1Hour = item.hour
            alarm.mAlarm1Cfg = item.cfg
            alarm.mAlarm1Once = item.once
            alarm.mAlarm1Remarks = item.reMark
            
            info.alarms.append(alarm)
            
        }
        return info
    }
    
    static func getSet_country_info_t(name: Data,
                                      timezone: UInt32) ->set_country_info_t {
        var info = set_country_info_t()
        info.mCountryName = name
        info.mCountryTimezone = timezone
        
        return info
    }
    
    static func getSet_ui_style_t(style: UInt32,
                                  clock: UInt32) ->set_ui_style_t {
        var info = set_ui_style_t()
        info.mUiStyle = style
        info.mDialClock = clock
        return info
    }
    
    static func getSet_sport_target_t(cal: UInt32,
                                      dis: UInt32,
                                      step: UInt32) ->set_sport_target_t {
        
        var info = set_sport_target_t()
        
        info.mTargetCal = cal
        info.mTargetDis = dis
        info.mTargetStep = step
        
        return info
        
    }
    
    static func getSet_time_format_t(timeFormat: Ls02TimeFormat) ->set_time_format_t {
        var info = set_time_format_t()
        info.mTimeFormat = UInt32(timeFormat.rawValue)
        return info
    }
    
    static func getSet_metric_inch_t(metricInch: Ls02Units) ->set_metric_inch_t {
        
        var info = set_metric_inch_t()
        info.mMetricInch = UInt32(metricInch.rawValue)
        return info
        
    }
    
    static func getSet_bright_times_t(brightTime: UInt32) ->set_bright_times_t {
        
        var timesInfo = set_bright_times_t()
        timesInfo.mBrightTime = brightTime
        
        return timesInfo
    }
    static func getSet_hr_warning_t(upper: UInt32,
                                    lower: UInt32) ->set_hr_warning_t {
        var info = set_hr_warning_t()
        info.mHrUpper = upper
        info.mHrLower = lower
        return info
    }
    static func getSet_music_info_t(code: UInt32) ->set_music_info_t {
        
        var info = set_music_info_t()
        info.mMusicCtrCode = code
        return info
        
    }
    
    static func getSet_rtimehr_dur_t(duration: UInt32) ->set_rtimehr_dur_t {
        var info = set_rtimehr_dur_t()
        info.mHrDuration = duration
        return info
        
    }
    
    static func geteSet_big_data_t(data: Data, type: BinFileTypeEnum) ->set_big_data_t {
        
        var info = set_big_data_t()
        info.mType = type.rawValue
        info.mDataLenth = UInt32(data.count)
        
        info.mCrcCode = UInt32(crc16ccitt(data: [UInt8](data)))
        info.mPicID = 1
        
        return info
        
    }
    
    static func geteSet_bin_data_t(sn: UInt32, data: Data) ->set_bin_data_t {
        var info = set_bin_data_t()
        info.mSn = sn
        info.mData = data
        return info
    }
    
    static func getSet_hr_sample_slot_t(slot: UInt32) ->set_hr_sample_slot_t {
        var info = set_hr_sample_slot_t()
        info.mHrSlot = slot
        return info
    }
    
    static func getSet_notdisturb_t(notdisturbTime1: Data,
                                    notdisturbTime2: Data) ->set_notdisturb_t {
        
        var info = set_notdisturb_t()
        
        info.mNotdisturbTime1 = notdisturbTime1
        info.mNotdisturbTime2 = notdisturbTime2
        
        return info
    }
    
    static func getSet_notify_warning_t(type: UInt32,
                                        titleLen: UInt32,
                                        msgLen: UInt32,
                                        reserved: Data,
                                        title: Data,
                                        msg: Data,
                                        utc: UInt32) ->set_notify_warning_t {
        var info = set_notify_warning_t()
        
        info.mNotifyType = type
        info.mTitleLen = titleLen
        info.mMsgLen = msgLen
        info.mReserved = reserved
        info.mTitle = title
        info.mMsg = msg
        info.mUtc = utc
        
        return info
        
    }
    
    static func get_sync_health_data_t(syncType: HealthDataSyncType,
                                       secondStart: UInt32,
                                       secondEnd: UInt32) ->r_sync_health_data_t {
        
        var info = r_sync_health_data_t ()
        
        info.mSyncType = syncType.rawValue
        info.mSecondStart = secondStart
        info.mSecondEnd = secondEnd
        
        return info
    }
    
    static func getSet_updata_fw_t(version: UInt32) ->set_updata_fw_t {
        
        var info = set_updata_fw_t()
        
        info.mNewVersion = version
        
        return info
    }
    
    static func getSet_weather_info_t(weathers: [LSWeather]) ->set_weather_info_t {
        
        var info = set_weather_info_t()
        
        for (index, item) in weathers.enumerated() {
            
            var weather = weather_t()
            
            weather.mWeatherNum = UInt32(index)
            weather.mClimate = UInt32(item.weatherState.rawValue)
            weather.mTemperature = UInt32(item.temperature)
            weather.mPm25 = UInt32(item.pm25)
            weather.mAqi = UInt32(item.aqi)
            weather.mCity = 0
            weather.mMaxTemp = UInt32(item.maxTemp)
            weather.mMinTemp = UInt32(item.minTemp)
            weather.mSeconds = UInt32(item.timestamp)
            
            info.weathers.append(weather)
        }
        
        return info
        
    }
    
    static func getSet_reset_machine_t(mode: UInt32) ->set_reset_machine_t {
        
        var info = set_reset_machine_t()
        
        info.mFactoryMode = mode
        
        return info
    }
    
    static func getSync_switch_t(data: Data) ->sync_switch_t {
        
        var info = sync_switch_t()
        
        info.mSwitchs = data
        
        return info
    }
    
    
    
    static func getSet_sport_status_t(mode: UInt32,
                                      status: UInt32,
                                      speed: UInt32,
                                      distance: Float,
                                      calorie: UInt32,
                                      flag: UInt32,
                                      duration: UInt32,
                                      second: UInt32,
                                      step: UInt32) ->set_sport_status_t {
        
        var info = set_sport_status_t()
        
        info.mSportMode = mode
        info.mSportStatus = status
        info.mSportSpeed = speed
        info.mSportDistance = distance
        info.mSportCalorie = calorie
        info.mSportFlag = flag
        info.mSportDuration = duration
        info.mSportSecond = second
        info.mSportStep = step
        
        return info
        
    }
    
    static func getSet_active_info_t(startTime: UInt32,
                                     endTime: UInt32) ->r_set_active_info_t {
        
        var info = r_set_active_info_t()
        
        info.mActStartTime = startTime
        info.mActEndTime = endTime
        
        return info
    }
    
    static func getSet_check_gps_info_t(type: UInt32,
                                        num: UInt32,
                                        second: UInt32,
                                        version: UInt32) ->set_check_gps_info_t {
        
        var info = set_check_gps_info_t()
        
        info.mCheckType = type
        info.mFileNum = num
        info.mSecond = second
        info.mNewVersion = version
        
        return info
    }
    
    static func getSet_page_switch_t(type: UInt32,
                                     page: UInt32) ->set_page_switch_t {
        
        var info = set_page_switch_t()
        
        info.mOperateType = type
        info.mPageSwitch = page
        
        return info
    }
    
    static func getSet_warming_data_t(type: UInt32,
                                      min: UInt32,
                                      max: UInt32) ->set_warming_data_t {
        
        var info = set_warming_data_t()
        
        info.mType = type
        info.mMin = min
        info.mMax = max
        
        return info
    }
    
    static func getSet_spo2_detect_t(enable: SwitchStatusEnum,
                                     intersec: UInt32) ->set_spo2_detect_t {
        
        var info = set_spo2_detect_t()
        
        info.mNightEnable = enable.rawValue
        info.mNightIntersec = intersec
        
        return info
        
    }
    
    static func getSpo2_detect_t(enable: SwitchStatusEnum,
                                 intersec: UInt32) ->r_get_spo2_detect_t {
        
        var info = r_get_spo2_detect_t()
        
        info.mNightEnable = enable.rawValue
        info.mNightIntersec = intersec
        
        return info
        
    }
    
    
    static func getMenu_sequence_t(type: UInt32) ->get_menu_sequence_t {
        
        var info = get_menu_sequence_t()
        
        info.mType = type
        
        return info
    }
    
    
    static func getSet_menu_sequence_t(type: UInt32,
                                       count: UInt32,
                                       data: Data) ->set_menu_sequence_t {
        
        var info = set_menu_sequence_t()
        
        info.mType = type
        info.mCount = count
        info.mData = data
        
        return info
        
    }
    
    static func getSet_phone_app_status_t(status: AppStatusEnum) ->set_phone_app_status_t {
        
        var info = set_phone_app_status_t()
        
        info.mStatus = status.rawValue
        
        return info
    }
        
}
