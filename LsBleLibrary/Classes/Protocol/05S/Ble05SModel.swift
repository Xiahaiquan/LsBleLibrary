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

public struct LSDeviceModel {
    public var projno = ""
    public var hwversion: UInt32 = 0
    public var fwversion = ""
    public var fontversion: UInt32 = 0
    public var sdversion: UInt32 = 0
    public var uiversion: UInt32 = 0
    public var devicesn: UInt32 = 0
    public var devicename: UInt32 = 0
    public var battvalue: UInt32 = 0
    public var devicemac: UInt32 = 0
    public var bindStatus: LsBleBindState = .error
    public var power: UInt32 = 0
    public var disturbEnable: Bool = false
    
    init(bindStatus: LsBleBindState) {
        self.bindStatus = bindStatus
        
    }
    init(projno: String,
         hwversion: UInt32,
         fwversion: String,
         fontversion: UInt32,
         sdversion: UInt32,
         uiversion: UInt32,
         devicesn: UInt32,
         devicename: UInt32,
         battvalue: UInt32,
         devicemac: UInt32,
         bindStatus: LsBleBindState,
         power: UInt32,
         disturbEnable: Bool = false) {
        self.projno = projno
        self.hwversion = hwversion
        self.fwversion = fwversion
        self.fontversion = fontversion
        self.sdversion = sdversion
        self.uiversion = uiversion
        self.devicesn = devicesn
        self.devicename = devicename
        self.battvalue = battvalue
        self.devicemac = devicemac
        self.bindStatus = bindStatus
        self.power = power
        self.disturbEnable = disturbEnable
        
    }
}

public struct AlarmModels: Monitored {
    public var items: [AlarmModel]
}

public struct AlarmModel {
    public var cfg: Int32 = 0
    public var hour: UInt32 = 0
    public var min: UInt32 = 0
    public var once: UInt32 = 0
    public var reMark: String = ""
    public var enable: Bool = false
    public var index: UInt8 = 0
    
    public init(cfg: Int32, hour: UInt32, min: UInt32, once: UInt32, reMark: String, enable: Bool, index: UInt8) {
        self.cfg = cfg
        self.hour = hour
        self.min = min
        self.once = once
        self.reMark = reMark
        self.enable = enable
        self.index = index
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
    //ANCS的
    case All_notify, instagram, linkedin, twitter, facebook, facetime, feixin, line
    case sound, gmail, webook, wechat, qq, sms, call, skype
    case dingtalk, aliwangwang, alipay, kakaotalk, qianniu, whatsapp, pinterest, other_app, fb_message
    //单独的方法
    case no_disturb_en
    //久坐是单独的方法，04没午休免打扰
    case long_sit, Noon_disturb
    //喝水没用到
    case drinking
    //佩戴没用。抬腕亮屏。05s的是2个指令。04的是走的用户信息指令
    case Wearing_detect,  Hand_up_bright
    //05s特有的
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
    
}


public enum SwitchStatusEnum: UInt32 {
    case off = 0
    case on = 1
}

public enum AppStatusEnum: UInt32 {
    case back = 0
    case front = 1
}

public enum HealthMonitorEnum: UInt32 {
    case hearheate = 1
    case bloodOxygen = 2
}

public enum BinFileTypeEnum: UInt32 {
    case dial = 1
    case pictrue = 2
    case font = 3
    case language = 7
}

public struct BleBackData {
    public var type: MonitoredType = .unknow
    public var data: Any = ""
}

extension hl_cmds: BleBackDataProtocol {
    
}

public struct LSWorkoutItem: BleBackDataProtocol, Monitored {
    public var value: [SportModelItem]
}

public struct LSSportRealtimeItem: BleBackDataProtocol, Monitored {
    public var hr: UInt32 = 0
    public var status: SportModelState = .unknown
    public var sportModel: Int = 0x01
    public var step: UInt32 = 0
    public var calories: UInt32 = 0
    public var distance: UInt32 = 0
    public var timeSeond: UInt32 = 0
    public var spacesKm: UInt32 = 0
    public var count: UInt32 = 0
    public var interval: SportModelSaveDataInterval = .unknown
    public var isStatueOnly = false
}

public enum RingStatus: UInt32, Monitored {
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

public enum DisturbSwitchStatus: UInt32, Monitored {
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

public struct CurrentUIHR: Monitored  {
    public var avg: UInt32 = 0
    public var act: UInt32 = 0
    public var max: UInt32 = 0
    public var min: UInt32 = 0
    public var datetime: String = ""
    public var timestmap: UInt32 = 0
    
}


public protocol BigDataProtocol {
    var timeStamp: UInt32 { get set }
}

public class DayStepModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var steps = ""
    public var calories = ""
    public var distance = ""
    public var activity = ""
    
    init(timeStamp: UInt32,
         steps: String,
         calories: String,
         distance: String,
         activity: String) {
        self.timeStamp = timeStamp
        self.steps = steps
        self.calories = calories
        self.distance = distance
        self.activity = activity
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
    
    public var macAddress = ""
    //json二维数组，[[1，2]]  1:持续时间，2:3清醒，1深睡，2浅睡 0无效数据
    public var sleepDetails = ""
    
    init(timeStamp: UInt32,
         startTimestamp: UInt32,
         endTimestamp: UInt32,
         totalMinutes: Int,
         lightSleepMinutes: Int,
         deepSleepMinutes: Int,
         awakeSleepMinutes: Int,
         awakeTimes: Int,
         macAddress: String,
         sleepDetails: String) {
        self.timeStamp = timeStamp
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.totalMinutes = totalMinutes
        self.lightSleepMinutes = lightSleepMinutes
        self.deepSleepMinutes = deepSleepMinutes
        self.awakeSleepMinutes = awakeSleepMinutes
        self.awakeTimes = awakeTimes
        self.macAddress = macAddress
        self.sleepDetails = sleepDetails
    }
    
    init() {
        self.timeStamp = 0
    }
    
}
public class DayBloodOxygenModel: BigDataProtocol {
    public var timeStamp: UInt32
    public var list: [DayBloodOxygenItemModel]
    
    init(timeStamp: UInt32,
         list: [DayBloodOxygenItemModel]) {
        self.timeStamp = timeStamp
        self.list = list
    }
    
    init() {
        self.timeStamp = 0
        self.list = [DayBloodOxygenItemModel]()
    }
}

public class DayBloodOxygenItemModel: BigDataProtocol {
    public var timeStamp: UInt32
    
    public var bloodOxygens: UInt8
    
    init(timeStamp: UInt32,
         bloodOxygens: UInt8) {
        self.timeStamp = timeStamp
        self.bloodOxygens = bloodOxygens
    }
    
    init() {
        self.timeStamp = 0
        self.bloodOxygens = 0
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


public struct LSMenuModel {
    public var type: UInt32? = nil //1代表的是一级排序
    public var supportCount: UInt32? = nil
    public var support: UInt32? = nil
    public var count: UInt32? = nil
    public var data: Data? = nil
}

public enum LSDeviceLanguageEnum: UInt8 {
    case en = 1
    case chs = 2 //中文简体
    case cht = 3
    case es = 4
    case ru = 5
    case ko = 6
    case fr = 7
    case de = 8
    case id = 9
    case pl = 10
    case it = 11
    case ja = 12
    case th = 13
    case ar = 14
    case vi = 15
    case pt = 16
    case nl = 17
    case tr = 18
    case uk = 19
    case he = 20
    case pt_br = 21
    case ro = 22
    case cs = 23
    case el = 24
    
    public init(rawVal: String) {
        
        if rawVal == "zh"{
            self = .chs
        }else if rawVal == "en"{
            self = .en
        }else if rawVal == "ko"{
            self = .ko
        }else if rawVal == "pt"{
            self = .pt
        }else if rawVal == "ja"{
            self = .ja
        }else if rawVal == "tw"{
            self = .cht
        }else if rawVal == "ru"{
            self = .ru
        }else if rawVal == "de"{
            self = .de
        }else if rawVal == "tr"{
            self = .tr
        }else if rawVal == "pl"{
            self = .pl
        }else if rawVal == "es"{
            self = .es
        }else if rawVal == "it"{
            self = .it
        }else if rawVal == "fr"{
            self = .fr
        }else if rawVal == "uk"{
            self = .uk
        }else if rawVal == "ar"{
            self = .ar
        }
//        else if rawVal == "be"{
//            self = .be
//        }
        else{
            self = .en
        }
    }
    
}
//
//ZH("zh", "中文","简体中文"),
//    EN("en", "英文","English"),
//    KO("ko", "韩文","한국어"),
//    PT("pt", "葡萄牙语","Português"),
//    JA("ja", "日文","日本語"),
//    TW("tw", "繁体","繁體中文"),
//    RU("ru", "俄文","Pусский"),
//    DE("de", "德文","Deutsch"),
//    TR("tr", "土耳其语","Türkçe"),
//    PL("pl", "波兰","Polski"),
//    ES("es", "西班牙","Español"),
//    IT("it", "意大利","Italiano"),
//    FR("fr", "法国","Français"),
//    BE("be", "白俄","беларуская"),
//    UK("uk", "乌克兰","Українськa"),
//    AR("ar","阿拉伯","العربية"),
//    GENERAL("general","通用语言","")
