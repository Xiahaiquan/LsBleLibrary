//
//  Ble02CmdsConfig.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/17.
//

import Foundation

class Ble02CmdsConfig {
    static let shared = Ble02CmdsConfig()
}

extension Ble02CmdsConfig {
    public func buildWeatherData(weathData: [LSWeather]) -> [Data] {
        guard weathData.count >= 7, let current = weathData.first else {
            return []
        }
        
        // 第一条
        var result: [Data] = []
        let todayState = UInt8(current.weatherState.rawValue)
        let todayHeight = UInt8(current.maxTemp)
        let todayLow = UInt8(current.minTemp)
        let pm1 = UInt8(((current.pm25>>8)&0xFF))
        let pm2 = UInt8(current.pm25&0xFF)
        let aqi1 = UInt8(((current.aqi>>8)&0xFF))
        let aqi2 = UInt8(current.aqi&0xFF)
        let weatherBytes: [UInt8] = [LS02CommandType.sendWeatherInfo.rawValue, 0x01, todayState, 0x00, UInt8(current.temperature), todayHeight, todayLow, pm1, pm2, aqi1, aqi2]
        var weatherData = Data.init(bytes: weatherBytes, count: weatherBytes.count)
        if let cityData = current.city.data(using: .unicode) {
            var cityBytes = [UInt8](cityData)
            let lessCount = 8 - cityBytes.count
            if lessCount > 0 {
                // 不够 8 字节 补 0
                for _ in 0..<lessCount {
                    cityBytes.append(0)
                }
            } else {
                // 大于 8 字节，舍去
                cityBytes = Array(cityBytes.prefix(8))
            }
            let cityTitleData = Data.init(bytes: cityBytes, count: cityBytes.count)
            weatherData.append(cityTitleData)
        } else {
            weatherData.append("0000000000000000".hexToData)
        }
        
        // 组装第二条
        let weatherSecondBytes: [UInt8] = [LS02CommandType.sendWeatherInfo.rawValue, 0x02]
        var weatherSecondData = Data.init(bytes: weatherSecondBytes, count: weatherSecondBytes.count)
        for i in 1 ... 4 {
            let weatherInfo = weathData[i]
            let tempWeatherBytes: [UInt8] = [UInt8(weatherInfo.weatherState.rawValue), 0x00, UInt8(weatherInfo.maxTemp), UInt8(weatherInfo.minTemp)]
            let tempWeatherData = Data.init(bytes: tempWeatherBytes, count: tempWeatherBytes.count)
            weatherSecondData.append(tempWeatherData)
        }
        // 组装第三条
        let weatherThirdBytes: [UInt8] = [LS02CommandType.sendWeatherInfo.rawValue, 0x03]
        var weatherThirdData = Data.init(bytes: weatherThirdBytes, count: weatherThirdBytes.count)
        for i in 5 ... 6 {
            let weatherInfo = weathData[i]
            let tempWeatherBytes: [UInt8] = [UInt8(weatherInfo.weatherState.rawValue), 0x00, UInt8(weatherInfo.maxTemp), UInt8(weatherInfo.minTemp)]
            let tempWeatherData = Data.init(bytes: tempWeatherBytes, count: tempWeatherBytes.count)
            weatherThirdData.append(tempWeatherData)
        }
        result.append(weatherData)
        result.append(weatherSecondData)
        result.append(weatherThirdData)
        return result
    }
}
