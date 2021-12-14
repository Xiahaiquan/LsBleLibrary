//
//  Ble05SModel.swift
//  SDK_Test
//
//  Created by antonio on 2021/11/5.
//

import Foundation
import RxSwift
import RxCocoa

public enum PhoneTypeEnum: Int {
    case iOS = 0
    case android = 1
}

public struct AlarmModel {
    var cfg = Data()
    var hour: UInt32 = 0
    var min: UInt32 = 0
    var once: UInt32 = 0
    var reMark = Data()
    
    public init() {
        
    }
}

struct BleDataStatus {
    //是否是10分钟一个的历史数据
   static var isLessHistoryData = true
}

enum BleDataSymbol: UInt32 {
    case SNEndSymbol = 0xFFFF //大数据的结束包标示
    case HRInvalid = 0xFF
    case parameterError = 3
    case noBigData = 10
    case unZipFailure = 12
}

enum BleReceiveErrorCode: UInt8 {
    case ERROR_ACK_SUCC = 0x00
    case ERROR_ACK_NON = 0x01
    case ERROR_ACK_CHECK_ERROR = 0x02
    case ERROR_NO_MEN = 0x03
    case ERROR_INVALID = 0xFF
}

public struct HealthDataSyncType  {
    let rawValue : UInt32
    
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static let stepsBack = 0
    public static let sleepBack = 1
    public static let heartRateBack = 2
    public static let multiSportRecordingBack = 3
    public static let bloodOxygenBack = 4
    public static let activityStatisticsBack = 5
    
    public static var stepsSend: HealthDataSyncType { return self.init(rawValue: (1 << 31) | 0) }
    public static var sleepSend: HealthDataSyncType { return self.init(rawValue: (1 << 31) | 1) }
    public static var heartRateSend: HealthDataSyncType { return self.init(rawValue: (1 << 31) | 2) }
    public static var multiSportRecordingSend: HealthDataSyncType { return self.init(rawValue: (1 << 31) | 3) }
    public static var bloodOxygenSend: HealthDataSyncType { return self.init(rawValue: 4) }
    public static var activityStatisticsSend: HealthDataSyncType { return self.init(rawValue: 5) }
    
}

public enum YSNotificationTypeEnum: RawRepresentable {
    case All_notify, instagram, linkedin, twitter, facebook, facetime, feixin, line
    case sound, gmail, webook, wechat, qq, sms, call, skype
    case dingtalk, aliwangwang, alipay, kakaotalk, qianniu, whatsapp, pinterest, other_app, fb_message
    
    case no_disturb_en
    
    case long_sit, Noon_disturb
    
    case drinking
    
    case Wearing_detect,  Hand_up_bright
    
    case hr_series_detect,hr_warn_en
    
    public var rawValue: (Int, Int) {
        switch self {
        case .All_notify: return (0, 0 + 8)
        case .instagram: return (0, 1 + 8)
        case .linkedin: return (0, 2 + 8)
        case .twitter: return (0, 3 + 8)
        case .facebook: return (0, 4 + 8)
        case .facetime: return (0, 5 + 8)
        case .feixin: return (0, 6 + 8)
        case .line: return (0, 7 + 8)
        case .sound: return (0, 8 + 8)
        case .gmail: return (0, 9 + 8)
        case .webook: return (0, 10 + 8)
        case .wechat: return (0, 11 + 8)
        case .qq: return (0, 12 + 8)
        case .sms:return (0, 13 + 8)
        case .call: return (0, 14 + 8)
        case .skype: return (0, 15 + 8)
        case .dingtalk: return (0, 16 + 8)
        case .aliwangwang: return (0, 17 + 8)
        case .alipay: return (0, 18 + 8)
        case .kakaotalk: return (0, 19 + 8)
        case .qianniu: return (0, 20 + 8)
        case .whatsapp: return (0,21 + 8)
        case .pinterest: return (0, 22 + 8)
        case .other_app: return (0, 23 + 8)
        case .fb_message: return (0, 24 + 8)
            
        case .no_disturb_en: return (1, 0)
            
        case .long_sit: return (2, 1)
        case .Noon_disturb: return (2, 2)
            
        case .drinking: return (3, 0)
            
        case .Wearing_detect: return (4, 0)
        case .Hand_up_bright: return (4, 1)
            
        case .hr_series_detect: return (5, 1)
        case .hr_warn_en: return (5, 2)
            
        }
    }
    
    public init?(rawValue: (Int, Int)) {
        switch rawValue {
        case (6, 0): self = .All_notify
        case (6, 1): self = .instagram
        default: return nil
        }
    }
    public init(ls02ANCCItem: Ls02ANCCItem) {
        switch ls02ANCCItem {
        case .message:
            self = .facebook
        case .qq:
            self = .qq
        case .wechat:
            self = .wechat
        case .telephone:
            self = .call
        case .otherReminders:
            self = .other_app
        case .facebook:
            self = .facebook
        case .twitter:
            self = .twitter
        case .whatsApp:
            self = .whatsapp
        case .facebookMessenger:
            self = .fb_message
        case .line:
            self = .line
        case .skype:
            self = .skype
        case .hangouts:
            self = .Hand_up_bright //这个不知道04的是啥类型
        case .linkedIn:
            self = .line
        case .instagram:
            self = .instagram
        case .viber:
            self = .feixin //这个不知道04的是啥类型
        case .kakaoTalk:
            self = .kakaotalk
        case .vkontakte:
            self = .kakaotalk //这个不知道04的是啥类型
        case .snapchat:
            self = .skype //这个不知道04的是啥类型
        case .googlePlus:
            self = .gmail //这个不知道04的是啥类型
        case .gmail:
            self = .gmail
        case .flickr:
            self = .feixin //这个不知道04的是啥类型
        case .tumblr:
            self = .twitter //这个不知道04的是啥类型
        case .pintrrest:
            self = .pinterest
        case .youtube:
            self = .sound //这个不知道04的是啥类型
        case .unowned:
            self = .Hand_up_bright //这个不知道04的是啥类型
        }
        
    }
}


public enum SwitchStatusEnum: UInt32 {
    case off = 0
    case on = 1
}

public enum AppStatusEnum: UInt32 {
    case back = 0
    case front = 1
}


public enum BinFileTypeEnum: UInt32 {
    case dial = 1
    case pictrue = 2
    case font = 3
}


public typealias LsBackData = (type: LsBackDataTypeEnum, data: [String: Any])

public typealias BleBackData = (ute: UTEBackData?, ls: LsBackData?)

public enum LsBackDataTypeEnum: Int {
    case findPhone = 24
    case disturbSwitch = 38
    
    case getHealthData = 29
    case getActiveRecordData = 45
    case getLogInfoData = 48
    case getUiHrValue = 49
    
    case invalid = 0
    
    public init?(rawValue: Int) {
        if rawValue == 24 {
            self = LsBackDataTypeEnum.findPhone
        }else if rawValue == 38 {
            self = LsBackDataTypeEnum.disturbSwitch
        }else if rawValue == 29 {
            self = LsBackDataTypeEnum.getHealthData
        }else if rawValue == 45 {
            self = LsBackDataTypeEnum.getActiveRecordData
        }else if rawValue == 48 {
            self = LsBackDataTypeEnum.getLogInfoData
        }else if rawValue == 49 {
            self = LsBackDataTypeEnum.getUiHrValue
        }else {
            self = LsBackDataTypeEnum.invalid
        }
    }
}


public enum RingStatus: UInt32 {
    case start = 0
    case end = 1
    
    public init?(rawValue: UInt32) {
        if rawValue == 0 {
            self = RingStatus.start
        }else {
            self = RingStatus.end
        }
    }
}

public enum DisturbSwitchStatus: UInt32 {
    case close = 0
    case open = 1
    
    public init?(rawValue: UInt32) {
        if rawValue == 0 {
            self = DisturbSwitchStatus.close
        }else {
            self = DisturbSwitchStatus.open
        }
    }
}

public struct CurrentUIHR {
    var act: UInt32 = 0
    var max: UInt32 = 0
    var min: UInt32 = 0
}


class WriteValueRequest {
    
    var isReceivedACK = false
    
    let callback: PublishRelay<LsBackData>
    var reTryCount = 0
    
    var cmds = hl_cmds()
    
    var snTotal: UInt32 = 0
    var snSended: UInt32 = 0
    var name = ""
    
    init(callback: PublishRelay<LsBackData>) {
        self.callback = callback
    }
}


public protocol BigDataProtocol {
    var timeStamp: UInt32 { get set }
}

public class DayStepModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var steps = ""
    public var calories = ""
    public var distance = ""
    
    init(timeStamp: UInt32,
         steps: String,
         calories: String,
         distance: String) {
        self.timeStamp = timeStamp
        self.steps = steps
        self.calories = calories
        self.distance = distance
    }
    
    init() {
        self.timeStamp = 0
    }
}

public class DayHRModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var heartRates = ""
    
    init(timeStamp: UInt32,
         heartRates: String) {
        self.timeStamp = timeStamp
        self.heartRates = heartRates
    }
    
    init() {
        self.timeStamp = 0
    }
}

public class DaySleepModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var startTimestamp: UInt32 = 0
    public var endTimestamp: UInt32 = 0
    
    public var totalMinutes = 0
    public var lightSleepMinutes = 0
    public var deepSleepMinutes = 0
    public var awakeSleepMinutes = 0
    public var awakeTimes = 0
    
    public var deviceId = ""
    //json二维数组，[[1，2]]  1:持续时间，2:3清醒，1深睡，2浅睡 0无效数据
    public var sleepDetails = ""
    
    init(timeStamp: UInt32,
         startTimestamp: UInt32,
         endTimestamp: UInt32,
         lightSleepMinutes: Int,
         deepSleepMinutes: Int,
         awakeSleepMinutes: Int,
         awakeTimes: Int,
         deviceId: String,
         sleepDetails: String) {
        self.timeStamp = timeStamp
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.lightSleepMinutes = lightSleepMinutes
        self.deepSleepMinutes = deepSleepMinutes
        self.awakeSleepMinutes = awakeSleepMinutes
        self.awakeTimes = awakeTimes
        self.deviceId = deviceId
        self.sleepDetails = sleepDetails
    }
    
    init() {
        self.timeStamp = 0
    }
    
}
public class DayBloodOxygenModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var bloodOxygens = ""
    
    init(timeStamp: UInt32,
         bloodOxygens: String) {
        self.timeStamp = timeStamp
        self.bloodOxygens = bloodOxygens
    }
    
    init() {
        self.timeStamp = 0
    }
}

public class DayActivityStatisticsModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var activityStatistics = ""
    
    init(timeStamp: UInt32,
         activityStatistics: String) {
        self.timeStamp = timeStamp
        self.activityStatistics = activityStatistics
    }
    
    init() {
        self.timeStamp = 0
    }
}

public struct LSFunctionTag {
    public let gps, nfc, gpsAndApgs, spo2, hrAlert, spo2Alert, menuOrder, languagePackSwitch, alarmSyn, pressureDetection, temperatureDetection, womenHealth, onceAlarmClock, languagePacksFullUpgrade: Bool
}
enum LSSupportFunctionEnum: Int {
    case gps = 0
    case nfc = 1
    case gpsAndApgs = 2
    case spo2 = 8
    case hrAlert = 11
    case spo2Alert = 12
    case menuOrder = 13
    case languagePackSwitch = 14
    case alarmSyn = 15
    case pressureDetection = 16
    case temperatureDetection = 17
    case womenHealth = 18
    case onceAlarmClock = 19
    case languagePacksFullUpgrade = 20
}
