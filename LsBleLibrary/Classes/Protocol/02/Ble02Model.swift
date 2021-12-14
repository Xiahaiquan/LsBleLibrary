//
//  Ble02Model.swift
//  SDK_Test
//
//  Created by antonio on 2021/11/5.
//

import Foundation


struct Characteristic02 {
    static let char6101 = "6101"
    static let char33F1 = "33F1"
}

public enum LsBleBindState : Int {
    case success = 1
    case cancel = 2
    case confirm = 3
    case timeout = 4
    case preParePair = 5
    case exsitValidId = 6
    case notExsitValidId = 7
    case error = 8
    
    public init(uteType: Int) {
        if uteType == 1 {
            self = .success
        }else if uteType == 2 {
            self = .confirm
        }else if uteType == 3 {
            self = .exsitValidId
        }else if uteType == 4 {
            self = .preParePair
        }else if uteType == 5 {
            self = .cancel
        }else {
            self = .error
        }
    }
    
}


public enum Ls02Units : Int {
    case metric = 1             // 公
    case imperial = 2           // 英
}

public enum Ls02TimeFormat : Int {
    case h12 = 1                // 12 小时制
    case h24 = 2                // 24 小时制
}

public enum Ls02Switch : UInt8 {
    case open = 0                   // 打开
    case close = 1                  // 关闭
}

public enum Ls02SwitchReverse : UInt8 {
    case open = 1                   // 打开
    case close = 0                  // 关闭
}

public enum WearstyleEnum: Int {
    case left = 0
    case right = 1
}

public enum Ls02Gender : Int {
    case male = 1                   // 男
    case female = 2                  // 女
}

public enum Ls02Language : Int {
    case english = 1                   // 英文
    case chinese = 2                   // 中文
}

public enum Ls02TemperatureUnit : Int {
    case c = 1                   // 摄氏度
    case f = 2                   // 华氏度
}

public enum Ls02DeviceUploadDataType : Int {
    case realtimesport                               // 实时运动
    case sleepdetail
    case unknow
    case realtimehr
    case statisticshr
    case statistics10Mhr
    case heartratedetail
    case u6101maxvalue
    case cloudwatchface
    case sportmodeling
    case sportmodestatechange
    case functionTag
    case bindState
    case realtimeGPS
    case sp02Data
    case shortcutSwitchStatus
    case watchKeyEvent
}

public struct Ls02SportInfo {
    public let year, month, day, hour, totalStep, runStart, runEnd, runDuration, runStep, walkStart, walkEnd, walkDuration, walkStep: Int
}

public struct FunctionTag {
    public let muLanguageShow, queryLanguage, updateLanguage, languageMenu, sportModelStatiStepAndCal, sportControlSyn, bloodOxygen, GPS, NFC, gPSAndAGPSUpdate, CustomDataTransfer, PumpBloodOxygen : Bool
}

public enum Ls02SleepState : Int {
    case unknow = 0
    case deep = 1                   // 摄氏度
    case light = 2
    case awake = 3
}

public enum Ls02SleepFlag : Int {
    case unknow = 0
    case none = 1                   // 摄氏度
    case night = 2
    case daytime = 3
}

public struct Ls02SleepInfo {
    public let year, month, day, dataCount: Int
    public let sleepItems: [Ls02SleepItem]
}

public struct Ls02SleepItem {
    public let startHour, startMin, sleepDuration: Int
    public let state: Ls02SleepState
    public let flag: Ls02SleepFlag
}

enum Ls02BraceletKeyEvent: UInt8 {
    case button1ShortPrees = 0x01
    case button1LongPrees = 0x02
    case button2ShortPrees = 0x03
    case button2SLongPrees = 0x04
    case button3ShortPrees = 0x05
    case button3LongPrees = 0x06
//    case button1LongPrees = 0x07
//    case button1ShortPrees = 0x08
//    case button1ShortPrees = 0x09
    case findPhonePrees = 0x0A
//    case button1ShortPrees = 0x0B
//    case button1ShortPrees = 0x0C
//    case button1ShortPrees = 0x0D
//    case button1ShortPrees = 0x0E
    
    
    
    
}

public protocol Ls02sShortcutSwitchsProtocol { }

public struct Ls02sShortcutSwitchsSupporedStatus: Ls02sShortcutSwitchsProtocol {
    public let foundWristband, lightWhenWristUp, longSitNotification, noDisturb, lossPrevent, messageNotification, heartRate: Bool
}

public struct Ls02sShortcutSwitchsOpenStatus: Ls02sShortcutSwitchsProtocol {
    public let foundWristband, lightWhenWristUp, longSitNotification, noDisturb, lossPrevent, messageNotification, heartRate: Bool
}


public class LSWeather {
    var date: String = ""
    var city: String
    var weatherTag: Int = 0
    var temperature: Int = 0
    var maxTemp: Int = 0
    var minTemp: Int = 0
    var pm25: Int = 0
    var aqi: Int = 0
    
    var air: Int = 0
    
    var humidity: Int = 0
    
    var uvIndex: Int = 0
    
    var weatherState: Ls02WeatherState = .cloudy
    var timestamp: UInt64 = 0
    
    public init(date: String,
         city: String,
         weatherTag: Int,
         temperature:Int,
         maxTemp: Int,
         minTemp: Int,
         pm25: Int = 100,
         aqi: Int = 100,
         air:Int,
         humidity:Int,
         uvIndex:Int,
         weatherState: Ls02WeatherState,
        timestamp: UInt64) {
        self.date = date
        self.city = city
        self.weatherTag = weatherTag
        self.temperature = temperature
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.pm25 = pm25
        self.aqi = aqi
        
        self.humidity = humidity
        self.air = air
        self.uvIndex = uvIndex
        self.weatherState = weatherState
        self.timestamp = timestamp
        
//        super.init()

    }
    
}
public enum Ls02WeatherState : Int {
    case none = 0
    case sunny = 1
    case cloudy = 2
    case overcast = 3
    case shower = 4
    case tStorm = 5
    case sleet = 6
    case lightRain = 7
    case heavyRain = 8
    case snow = 9
    case sandStorm = 10
    case haze = 11
    case windy = 12
    
    var desc : String {
        switch self {
        case .none:
            return "无"
        case .sunny:
            return "晴"
        case .cloudy:
            return "多云"
        case .overcast:
            return "阴"
        case .shower:
            return "阵雨"
        case .tStorm:
            return "雷阵雨"
        case .sleet:
            return "雨夹雪"
        case .lightRain:
            return "小雨"
        case .heavyRain:
            return "大雨"
        case .snow:
            return "雪"
        case .sandStorm:
            return "沙尘暴"
        case .haze:
            return "雾霾"
        case .windy:
            return "风"
        }
    }
}

public enum Ls02ANCCItem : UInt32 {
    
    case message            = 0x00000001
    case qq                 = 0x00000002
    case wechat             = 0x00000004
    case telephone          = 0x00000008
    case otherReminders     = 0x00000010
    case facebook           = 0x00000020
    case twitter            = 0x00000040
    case whatsApp           = 0x00000080
    case facebookMessenger  = 0x00000100
    case line               = 0x00000200
    case skype              = 0x00000400
    case hangouts           = 0x00000800
    case linkedIn           = 0x00001000
    case instagram          = 0x00002000
    case viber              = 0x00004000
    case kakaoTalk          = 0x00008000
    case vkontakte          = 0x00010000
    case snapchat           = 0x00020000
    case googlePlus         = 0x00040000
    case gmail              = 0x00080000
    case flickr             = 0x00100000
    case tumblr             = 0x00200000
    case pintrrest          = 0x00400000
    case youtube            = 0x00800000
    case unowned            = 0100000000
    
}

public enum Ls02ANCCSwitch : Int {
    case open = 1                   // 打开
    case close = 2                  // 关闭
}

public enum Ls02NotDisturb : UInt8 {
    case screen = 0                   //屏幕
    case shock = 1                  // 震动
    case message = 2                   // 消息
    case call = 3                  // 电话
}

public enum Ls02Error: Error {
    case error(_ messae: String, _ code: Int = 0)
}

public enum SportModel: UInt8 {
    case none = 0x00
    case running                        // 跑步
    case riding                         // 骑行
    case jumprope                       // 跳绳
    case swimming                       // 游泳
    case badminton                      // 羽毛球
    case tabletennis                    // 乒乓球
    case tennis                         // 网球
    case climbing                       // 登山
    case walking                        // 徒步
    case basketball                     // 篮球
    case football                       // 足球
    case baseball                       // 棒球
    case volleyball                     // 排球
    case cricket                        // 板球
    case rugby                          // 橄榄球 或 美式足球
    case hockey                         // 曲棍球
    case dance                          // 跳舞
    case spinning                       // 动感单车
    case yoga                           // 瑜伽
    case situp                          // 仰卧起坐
    case treadmill                      // 跑步机
    case gymnastics                     // 体操
    case boating                        // 划船
    case jumpingjack                    // 开合跳
    case freetraining                   // 自由训练
    case outdoorswimming                // 开放水域游泳
    case indoorswimming                 // 室内游泳
}

public struct SportModelItem {
    public var sportModel: SportModel = .badminton         // 运动模式
    public var heartRateNum: Int = 0              // 心率总数
    public var startTime: String = ""             // 开始时间
    public var endTime: String = ""                // 结束时间
    public var step: Int = 0                          // 步数
    public var count: Int  = 0                        // 次数
    public var cal: Int  = 0                          // 卡路里
    public var distance: String = ""                // 距离
    public var hrAvg: Int = 0                         // 平均心率
    public var hrMax: Int = 0                         // 最大心率
    public var hrMin: Int = 0                         // 最小心率
    public var pace: Int = 0                          // 配速
    public var hrInterval: Int = 0                    // 心率数据间隔
    public var heartRateData: Data = Data()            // 详细数据
    
}

public enum SportModelState: UInt8 {
    case stop = 0x00
    case start = 0x11
    case suspend = 0x22
    case resume = 0x33
    case continued = 0x44
}

public enum SportModelSaveDataInterval: UInt8 {
    case s10 = 1
    case s20 = 2
    case s30 = 3
    case m1 = 6
    case m2 = 12
    case m3 = 18
    case m4 = 24
    case m5 = 30
}

public typealias UTEOriginalData = (from: String, data: Data)
public typealias UTEBackData = (dataType: Ls02DeviceUploadDataType, data: Any)


public enum Ls02CameraMode:UInt8 {
    case enterCamera = 0x01
    case startPhoto = 0x02
    case exitCamera = 0x03
}


public enum Ls02HRdetectionSettings: UInt8 {
    case automatic = 0x01 //设置动态测试心率
    case manual = 0x02 //设置手动测试心率 0x1802
    case reportEvery10Minutes = 0x03 //每隔 10 分钟心率测试出值后上 报心率数值
    case currentExtreme = 0x04 //上报当天测试的心率最大值和最 小值及平均值。在同步 24h 心率 前和每次测试出心率时会上报
}


public enum FactoryTestMode: UInt16 {
    case enterCamera = 0xFFF0 //查询功能指令，
    case lightOn = 0x0001 //手机开手环心率漏光，
    case lightOff = 0x0002 //手机关手环心率漏光
    case screenOff = 0x0003 //打开屏幕常亮测试
    case screenOn = 0x0004 //关闭屏幕常亮测试
    case pressure = 0x0005 //打开压力测试模式
    case none = 0
    
}

public enum Ls02GPSStatusMode:UInt8 {
    case search = 0x01
    case localSucccess = 0x02
    case storageFull = 0x04
    case otaIng = 0x08
//    case none = 0xFF
}
public enum Ls02UpdateAGPSMode:UInt8 {
    case beidou = 0x00
    case gps = 0x01
    case glonass = 0x02
}

public enum Ls02GPSDataBackMode:UInt8 {
    case noData = 0x00 //表示无相应的数据
    case have = 0x01 //有相应的数据，接着返回 相应的数据
    case complete = 0x02 //数据同步结束
}

public enum Ls02UpdateAGPSCompleteMode:UInt8 {
    case signle = 0x01 //发送当前文件数据结束
    case all = 0x07 //发送所有文件数据结束
}


public enum Ls02ReadyUpdateAGPSStatue: UInt8 {
    case ready = 0x00
    case complete = 0x01
    case continueSend = 0x02
    case success = 0x03
    case faile = 0x04
    case allComplete = 0x07
}

public enum Ls02GPSOTAType: UInt8 {
    case agps_beidou = 0
    case agps_gps = 1
    case agps_qzss = 2
    case gps = 3
    case gpsBin = 4
    case glnBin = 5
}

public enum LsSpo2Status: UInt8 {
    case autoTestOpen = 0x01
    case open = 0x11
    case close = 0x00
    case inquire = 0xAA
    case timeout = 0xFD
    case delete = 0x0C
    
    
    public enum InquireStatus: UInt8 {
        case testing = 0x11
        case notSupport = 0xFF
    }
    
    public enum CollectionTime: UInt16 {
        case interval_1 = 0x0001
        case interval_5 = 0x0005
        case interval_10 = 0x000A
        case interval_30 = 0x001E
        case interval_60 = 0x003C
        case interval_120 = 0x0078
        case interval_180 = 0x00B4
        case interval_240 = 0x00F0
        case interval_360 = 0x0168
        case interval_480 = 0x01E0
        case interval_720 = 0x02D0 //12 小时固定每天 8点测试
        case interval_1440 = 0x05A0 //24 小时固定每天 8点测试
        
        case periodAm = 0x081E //表示 8 点 30 分。
        case periodPm = 0x141E //表示 20 点 30 分
        
    }
    
    public enum CollectionPeriod: UInt16 {
        
        case am = 0x081E //表示 8 点 30 分。
        case pm = 0x141E //表示 20 点 30 分
        
    }
    
}


