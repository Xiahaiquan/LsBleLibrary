//
//  BleModel.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/12/16.
//

import Foundation

public typealias ScanItem = (uuid: String, deviceName: String, rssi: NSNumber, macAddress: String, category: LSDeviceCategory, type: LSSportWatchType, series: LSSportWatchSeries)


//是不是准确的时间错。兼容老版本，默认的是新版本
var isAccurateTimestamp = true
var mtu = 20

public enum WitheType: Int {
    case withResponse = 0
    case withoutResponse = 1
}

public enum MonitoredType {
    case unknow
    case sleepdetail
    case realtimehr
    case statisticshr
    case statistics10Mhr
    case heartratedetail
    case u6101maxvalue
    case cloudwatchface
    case sportmodestatechange
    case functionTag
    case bindState
    case realtimeGPS
    case gpsUpgradeStatus
    case shortcutSwitchStatus
    case watchKeyEvent
    
    
    case findPhone
    case disturbSwitch
    case sportHistoryData
    case sportRealtimeData
    case binDataUpdate
    case realtimeSporthr
    case alarmUpdate
    case electricityUpdate
    case stepUpdate
    case spo2Update
    
    var name: String {
        switch self {
        case .unknow:
            return "unknow"
        case .sleepdetail:
            return "sleepdetail"
        case .realtimehr:
            return "realtimehr"
        case .statisticshr:
            return "statisticshr"
        case .statistics10Mhr:
            return "statistics10Mhr"
        case .heartratedetail:
            return "heartratedetail"
        case .u6101maxvalue:
            return "u6101maxvalue"
        case .cloudwatchface:
            return "cloudwatchface"
        case .sportmodestatechange:
            return "sportmodestatechange"
        case .functionTag:
            return "functionTag"
        case .bindState:
            return "bindState"
        case .realtimeGPS:
            return "realtimeGPS"
        case .gpsUpgradeStatus:
            return "gpsUpgradeStatus"
        case .shortcutSwitchStatus:
            return "shortcutSwitchStatus"
        case .watchKeyEvent:
            return "watchKeyEvent"
        case .findPhone:
            return "findPhone"
        case .disturbSwitch:
            return "disturbSwitch"
        case .sportHistoryData:
            return "sportHistoryData"
        case .sportRealtimeData:
            return "sportRealtimeData"
        case .binDataUpdate:
            return "binDataUpdate"
        case .realtimeSporthr:
            return "realtimeSporthr"
        case .alarmUpdate:
            return "alarmUpdate"
        case .electricityUpdate:
            return "electricityUpdate"
        case .stepUpdate:
            return "stepUpdate"
        case .spo2Update:
            return "spo2Update"
        }
    }
    
}

public protocol BleBackDataProtocol { }



