//
//  Ble02CmdType.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation

enum LS02CommandType: UInt8 {
    case setClockAndDistanceFormat = 0x01
    case getVersionNum = 0x02
    case getBatteryLevel = 0x03
    case setDateAndTime = 0x04
    case setWatch = 0x05
    case setTimerAndMotorParams = 0x06
    case requstFactoryReset = 0x07
    case requestBluetoothAddress = 0x08
    case requestRealtimeSteps = 0x09
    case requestSevenDaysHistorySteps = 0x0a
    case requestHistorySleepingData = 0x0b
    case requestFunctionSetAndStatus = 0x0c
    case setCameraMode = 0x0e
    case sendWeatherInfo = 0x11
    case watchBtnFunction = 0x12
    case configPushNotification = 0x13
    case setLongSitNotification = 0x14
    case setNoDisturbanceMode = 0x15
    case requestRealtimeHeartRate = 0x16
    case phoneControlPowerOff = 0x17
    case historyHeartRateData = 0x18
    case multiSport = 0x19
    case enterFactoryTest = 0x1C
    case sevenDaysHistorySleepingDataSend = 0x1D
    case sevenDaysHistorySleepingDataReceive = 0x1E
    case bindingWatch = 0x20
    case supportMultiLanguageDisplay = 0x25
    
    case gpsCommand = 0x81
    case receiveGPSCommand = 0x82
    case historySpo2Data = 0x86
    
    case supportAlarmsNum = 0x87
    
    case getWatchSkinTheme = 0x1A
    case sendWatchSkinTheme = 0x1B
    
    case creatTestData = 0x1F
    case updateAGPS = 0xF1
    case updateYearGPS = 0xF2
    case beidouGPSAvailable = 0xF6
    
    case generalEnds = 0xFD
    
    var name: String {
        get {
            switch self {
            case .setClockAndDistanceFormat:
                return "setClockAndDistanceFormat"
            case .getVersionNum:
                return "getVersionNum"
            case .getBatteryLevel:
                return "getBatteryLevel"
            case .setDateAndTime:
                return "setDateAndTime"
            case .setWatch:
                return "setWatch"
            case .setTimerAndMotorParams:
                return "setTimerAndMotorParams"
            case .requstFactoryReset:
                return "requstFactoryReset"
            case .requestBluetoothAddress:
                return "requestBluetoothAddress"
            case .requestRealtimeSteps:
                return "requestRealtimeSteps"
            case .requestSevenDaysHistorySteps:
                return "requestSevenDaysHistorySteps"
            case .requestHistorySleepingData:
                return "requestHistorySleepingData"
            case .requestFunctionSetAndStatus:
                return "requestFunctionSetAndStatus"
            case .setCameraMode:
                return "setCameraMode"
            case .sendWeatherInfo:
                return "sendWeatherInfo"
            case .watchBtnFunction:
                return "watchBtnFunction"
            case .configPushNotification:
                return "configPushNotification"
            case .setLongSitNotification:
                return "setLongSitNotification"
            case .setNoDisturbanceMode:
                return "setNoDisturbanceMode"
            case .requestRealtimeHeartRate:
                return "requestRealtimeHeartRate"
            case .phoneControlPowerOff:
                return "phoneControlPowerOff"
            case .historyHeartRateData:
                return "historyHeartRateData"
            case .multiSport:
                return "multiSport"
            case .enterFactoryTest:
                return "enterFactoryTest"
            case .sevenDaysHistorySleepingDataSend:
                return "sevenDaysHistorySleepingDataSend"
            case .sevenDaysHistorySleepingDataReceive:
                return "sevenDaysHistorySleepingDataReceive"
            case .bindingWatch:
                return "bindingWatch"
            case .supportMultiLanguageDisplay:
                return "supportMultiLanguageDisplay"
            case .gpsCommand:
                return "gpsCommand"
            case .receiveGPSCommand:
                return "receiveGPSCommand"
            case .historySpo2Data:
                return "historySpo2Data"
            case .supportAlarmsNum:
                return "supportAlarmsNum"
            case .getWatchSkinTheme:
                return "getWatchSkinTheme"
            case .sendWatchSkinTheme:
                return "sendWatchSkinTheme"
            case .creatTestData:
                return "creatTestData"
            case .updateAGPS:
                return "updateAGPS"
            case .updateYearGPS:
                return "updateYearGPS"
            case .beidouGPSAvailable:
                return "beidouGPSAvailable"
            case .generalEnds:
                return "generalEnds"
            }
        }
    }
    
}

enum LS02Placeholder: UInt8 {
    case zero = 0x00
    case one = 0x01
    case two = 0x02
    case three = 0x03
    case four = 0x04
    case five = 0x05
    case eleven = 0x11
    case a = 0x0a
    case aa = 0xaa
    case ab = 0xab
}

