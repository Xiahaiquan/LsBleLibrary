//
//  Ble05sParser.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2020/12/21.
//  Copyright © 2020 appscomm. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift

/*
 错误类型
 */
enum ParserState {
    case dataError
    case byteError
    case dataLengthError
    case crcError
    case deserialize
    case pbDataError
    case pbDataNotMatch
    case dataContinue
    case dataItemEnd
    case dataEnd
    case noData
    case bigDataEnd
    case binInTransit
}

enum BigDataParserState {
    case start
    case error
    case invalid
    case dataContinue
    case end
}

class Ble05sParser {
    
    // 一个以7E6D开头的完整数据
    var receiveData = Data()
    // 多个以7E6D开头数据的合并，大数据的形式
    var receiveBigData = Data()
    //多个大数据的数据
    var receiveWholeBigData = [Data]()
    
    // 一条命令可能多条数据返回
    var receiveArray: [hl_cmds] = []
    
    var bigDataParserState: BigDataParserState = .invalid
    
    var bigDataItems = [BigDataProtocol]()
    var bigSportDataItems = [SportModelItem]()
    var currentSportDataCount = 0
    
    func resetAcceptancePackage() {
        self.receiveData.removeAll()
        self.receiveBigData.removeAll()
        self.receiveArray.removeAll()
        self.receiveWholeBigData.removeAll()
        self.bigDataItems.removeAll()
        
        self.bigDataParserState = .invalid
        
        currentSportDataCount = 0
        bigSportDataItems.removeAll()
        
    }
    
    func accept(data: Data) -> ParserState {
        
        let acceptBytes = [UInt8](data)
        
        guard acceptBytes.count > 9 else {
            return .dataError
        }
        
        if acceptBytes[0] == 0x7E && acceptBytes[1] == 0x6D {
            receiveData = Data()
        }
        
        receiveData.append(data)
        
        let totalLength = Int(receiveData[3]) + (Int(receiveData[4]) << 8) + Int(9)
//        print("PB 期待总数长: \(totalLength), current lenght:", receiveData.count)
        if receiveData.count != totalLength { return .dataContinue }
        // 单条数据接受完成，校验CRC
        let responseCrcNumber = Int(receiveData[5]) + (Int(receiveData[6]) << 8)
        let startIndex = receiveData.index(receiveData.startIndex, offsetBy: 9)
        let endIndex = receiveData.endIndex
        let subDataRange: Range = startIndex..<endIndex
        let responsePbData = receiveData.subdata(in: subDataRange)
        let responsePbBytes = [UInt8](responsePbData)
        
        let calculateCrcNumber = crc16ccitt(data: responsePbBytes)
        
        // CRC 不符合
        guard calculateCrcNumber == responseCrcNumber else {
            return .crcError
        }
        var responseObj: hl_cmds!
        do {
            responseObj = try hl_cmds(serializedData: responsePbData)
        } catch {
            print("PB 反序列化 Error")
        }
        
        guard let pbObj = responseObj else {
            print("PB 反序列化 obj Error")
            return .pbDataError
        }
        
        print("callback pbObj:",pbObj)
        
        // 符合校验的 PB 数据集合
        self.receiveArray.append(pbObj)
        
        if responseObj.cmd == .cmdSetBinDataUpdate {
            return .dataItemEnd
        }
        
        if responseObj.cmd == .cmdSetUpdateGpsData ||
            responseObj.cmd == .cmdSetSyncHealthData  {
            bigDataParserState = .start
            print("开始接受大数据")
            let errCode = UInt32(pbObj.rErrorCode.err)
            
            //没有数据
            if errCode == BleDataSymbol.noBigData.rawValue || errCode == BleDataSymbol.parameterError.rawValue {
                print("没有大数据")
                bigDataParserState = .end
                
            }
            
        }
        
        if responseObj.cmd == .cmdSetActiveRecordData {
            bigDataParserState = .start
            print("开始接受大数据")
            let errCode = UInt32(pbObj.rErrorCode.err)
            
            //没有数据
            if errCode == BleDataSymbol.noBigData.rawValue || errCode == BleDataSymbol.parameterError.rawValue {
                print("没有大数据")
                bigDataParserState = .end
                
            }
        }
        
        
        if responseObj.cmd == .cmdGetHealthData ||
            responseObj.cmd == .cmdGetLogInfoData {
            
            self.receiveBigData.append(responseObj.rGetHealthData.mData)
            
            if responseObj.rGetHealthData.mSn == BleDataSymbol.SNEndSymbol.rawValue {
                
                receiveWholeBigData.append(receiveBigData)
                
                let typeData: UInt8 = receiveBigData.scanValue(at: 0)
                let timestamp: UInt32 = receiveBigData.scanValue(at: 1)
                print("timestampe", timestamp)
                let UTC = handleBackTimestamp(original: timestamp)
                let dataTotalLength: UInt16 = receiveBigData.scanValue(at: 5)
                let daysTotal: UInt16 = receiveBigData.scanValue(at: 7)
                let dataUnitLength: UInt8 = receiveBigData.scanValue(at: 9)
                
                let dataArr = Ble05sCmdsConfig.shared.chunked(data: Data(receiveBigData.suffix(from: 10)), chunkSize: Int(dataUnitLength))
                
                //接受下一个包块
                receiveBigData.removeAll()
                
                if typeData == HealthDataSyncType.stepsBack {
                    
                    handleStepData(dataArr: dataArr, timeStamp: UTC)
                }else if typeData == HealthDataSyncType.heartRateBack  {
                    handleHRData(dataArr,UTC)
                }else if typeData == HealthDataSyncType.sleepBack  {
                    handleSleepData(dataArr,UTC)
                }else if typeData == HealthDataSyncType.bloodOxygenBack {
                    handleBloodOxygenData(dataArr,UTC)
                }else if typeData == HealthDataSyncType.activityStatisticsBack {
                    handleActivityStatisticsData(dataArr,UTC)
                } else {
                    print("接受到了异常数据")
                }
                print("typeData", typeData, "UTC",UTC, "dataTotalLength", dataTotalLength, "daysTotal", daysTotal, "dataUnitLength", dataUnitLength)
                
                if receiveWholeBigData.count == daysTotal {
                    print("结束接受大数据")
                    bigDataParserState = .end
                }
                
            }else {
                bigDataParserState = .dataContinue
            }
            
        }
        
        
        if responseObj.cmd == .cmdGetActiveRecordData {
            self.receiveBigData.append(responseObj.rGetActiveRecord.mHrData)
            
            if responseObj.rGetActiveRecord.mSn == BleDataSymbol.SNEndSymbol.rawValue {
                
                self.handleSportRecordHRData(hrData: self.receiveBigData, decodedInfo: responseObj)
                
                currentSportDataCount += 1
                if currentSportDataCount == responseObj.rGetActiveRecord.mCountNum {
                    bigDataParserState = .end
                    currentSportDataCount = 0
                }
                                
            }else {
                bigDataParserState = .dataContinue
            }
        }
        
        return .dataItemEnd
        
    }
}

extension Ble05sParser {
   private func handleStepData(dataArr: [Data], timeStamp: UInt32) {
        
       var steps: [Float] = [Float]()
       var calories: [Float] = [Float]()
       var distance: [Float] = [Float]()
       
       for (_, subData) in dataArr.enumerated() {
           if subData.count < 6 { continue } // 接受到的数据可能是错乱的
           
           let st: UInt16 = Data(subData).scanValue(at: 0)
           let cal: UInt16 = Data(subData).scanValue(at: 2)
           let dis: UInt16 = Data(subData).scanValue(at: 4)
           
           steps.append(Float(st))
           calories.append(Float(cal))
           distance.append(Float(dis))
           
       }
       
       var chunkSize = 6
       if steps.count > 144 {
           chunkSize = 60
       }
       
       //处理时长数据
       let stepsDetail = Ble05sCmdsConfig.shared.chunked(dataArray: steps, chunkSize: chunkSize)
       let caloriesDetail = Ble05sCmdsConfig.shared.chunked(dataArray: calories, chunkSize: chunkSize)
       let distanceDetail = Ble05sCmdsConfig.shared.chunked(dataArray: distance, chunkSize: chunkSize)
       
       bigDataItems.append(DayStepModel.init(timeStamp: timeStamp,
                                             steps: stepsDetail.description,
                                             calories: caloriesDetail.description,
                                             distance: distanceDetail.description))
        
    }
    
    func handleHRData(_ dataArr: [Data], _ timestamp: UInt32) {
        var heartRates = [Int](repeating: 0, count: 144)
        
        for (index, subData) in dataArr.enumerated() {
            
            if subData.isEmpty { continue } // 接受到的数据可能是错乱的
            
            let heartRate = [UInt8](subData).first ?? 0
            
            if BleDataStatus.isLessHistoryData {
                let order = Int(index)
                if order < heartRates.count { heartRates[order] = Int(heartRate) }
                
            }else {
                if index % 10 != 0 { continue }
                    heartRates[Int(index/10)] = Int(heartRate)
            }
        }
        
        bigDataItems.append(DayHRModel.init(timeStamp: timestamp, heartRates: heartRates.description))
    }
    func handleSleepData(_ dataArr: [Data], _ timestamp: UInt32) {
    
        var startSleepIndex = 0 , endSleepIndex = 0
        
        //算出总的睡眠段
        for (index, subData) in dataArr.enumerated() {
            
            if subData.isEmpty { continue } // 接受到的数据可能是错乱的
            
            let value = [UInt8](subData).first ?? 0
            let sleepStates = value & 0x0F
            
            if sleepStates == 2 && startSleepIndex == 0 {
                startSleepIndex = index
            }
            
            if sleepStates == 2 {
                endSleepIndex = index
            }
            
        }
        
        let sleepValidSleepData = dataArr[startSleepIndex ..< endSleepIndex]
        
        //算出有几段睡眠
        var sleepSegment = [(start: Int, end: Int)]()
        var startActivity = 0, endActivity = 0, previousState = 0
        for (index, subData) in sleepValidSleepData.enumerated() {
            let value = [UInt8](subData).first ?? 0
            let sleepStates = value & 0x0F
            
            if sleepStates != 2 && previousState == 2 {
                print("activity")
                startActivity = index
            }
            
            if previousState != 2 && sleepStates == 2 {
                //要大于2个小时才算有效的活动时间
                if index - startActivity > 2 * 60 {
                    endActivity = index
                    sleepSegment.append((start: startActivity, end: endActivity))
                    print("have one sleep segment")
                }else {
                    print("no activity enought")
                }
                
            }
            
            previousState = Int(sleepStates)
        }
        
        print("sleepSegment", "\(sleepSegment)")
        
        if startSleepIndex == 0 || endSleepIndex == 0 {
            return
        }
        
        var totalMinutes = 0, lightSleepMinutes = 0, deepSleepMinutes = 0, awakeSleepMinutes = 0, invalidSleepMinutes = 0, activityMinutes = 0
        
        var sleepArr = [[Int]]()
        var sleepPre = 0, sleepCount = 0
        
        for (index, subData)  in sleepValidSleepData.enumerated() {
            
            if subData.isEmpty { continue } // 接受到的数据可能是错乱的
            
            let value = [UInt8](subData).first ?? 0
            
            let slepLevel = (value & 0xF0) >> 4
            var sleepType = (value == 0x31 || value == 0x41) ? 0x01 : slepLevel
            
            if value != BleReceiveErrorCode.ERROR_INVALID.rawValue  {
                sleepCount += 1
            }
            
            //APP 1:持续时间，2:3清醒，1深睡，2浅睡 0无效数据 FW: 0无效 1 清醒 3 浅睡 4 深睡
            //FW 高位 3 浅睡 4 深睡 。 低位 1 清醒 2 睡眠。其他不满足规则的都是无效数据
            
            //算法要求加入，判断的是无效的数据。判断到无效的睡眠数据，都以浅睡处理
            
            if (value != 0x31 && value != 0x41
                && value != 0x32 && value != 0x42 && value != 0x7f
                && (value & 0xff) != 0xf7 && (value & 0xff) != 0xff) {
                sleepType = 0x03
                invalidSleepMinutes += 1
                
            }
            
            if self.inEffect(i: index, d: sleepSegment) {
                sleepType = 0
            }
            
            //let sleepCurrent = sleepStates == 1 ? sleepStates : slepLevel
            if sleepPre != sleepType,  index != 0, index != sleepValidSleepData.count - 1, value != BleReceiveErrorCode.ERROR_INVALID.rawValue {
                
                if sleepArr.isEmpty {
                    sleepCount -= 1
                }
                
                let newSleepState = transitionSleepState(value: Int(sleepPre))
                
                sleepArr.append([sleepCount, newSleepState])
                
                sleepCount = 0
                
            }
            
            if index == sleepValidSleepData.count - 1{ //最后一组数据
                sleepCount += 1
                let newSleepState = transitionSleepState(value: Int(sleepType))
                sleepArr.append([sleepCount, newSleepState])
                
            }
        
            if value != BleReceiveErrorCode.ERROR_INVALID.rawValue && value != 0 {
                sleepPre = Int(sleepType)
            }
            
        }
        
        //3清醒，1深睡，2浅睡 0无效数据
        var awakeTimes = 0
        for subSleepArr  in sleepArr {
            
            let sleepType = subSleepArr.last ?? 0
            if sleepType == 3 {
                awakeTimes += 1
                awakeSleepMinutes += subSleepArr.first ?? 0
            }else if sleepType == 2 {
                lightSleepMinutes += subSleepArr.first ?? 0
            }else if sleepType == 1 {
                deepSleepMinutes += subSleepArr.first ?? 0
            }else if sleepType == 0 {
                activityMinutes += subSleepArr.first ?? 0
            }
            
        }
        
        //去掉无效的数据分钟
        lightSleepMinutes -= invalidSleepMinutes
        
        totalMinutes = lightSleepMinutes + deepSleepMinutes + awakeSleepMinutes + activityMinutes
        
        let offsetTimeStamp = 6 * 60 * 60 //从前一天的18时开始计算的
        let startSleepTimestamp = UInt32(Int(timestamp) - offsetTimeStamp + startSleepIndex * 60)
        //1608745260
        //1608739200 - 21600 + 25560 26730 （445.5）
        let endSleepTimestamp = UInt32(Int(timestamp) - offsetTimeStamp + endSleepIndex * 60)
        
        bigDataItems.append(DaySleepModel.init(timeStamp: timestamp, startTimestamp: startSleepTimestamp, endTimestamp: endSleepTimestamp, lightSleepMinutes: lightSleepMinutes, deepSleepMinutes: deepSleepMinutes, awakeSleepMinutes: awakeSleepMinutes, awakeTimes: awakeTimes, deviceId: "", sleepDetails: sleepArr.description))

    }
    func handleBloodOxygenData(_ dataArr: [Data], _ timestamp: UInt32) {
        var bloodOxygens = [Int](repeating: 0, count: 144)
        
        for (index, subData) in dataArr.enumerated() {
            
            if subData.isEmpty { continue } // 接受到的数据可能是错乱的
            
            let bloodOxygen = [UInt8](subData).first ?? 0
            
            if BleDataStatus.isLessHistoryData {
                let order = Int(index)
                if order < bloodOxygens.count { bloodOxygens[order] = Int(bloodOxygen) }
                
            }else {
                if index % 10 != 0 { continue }
                bloodOxygens[Int(index/10)] = Int(bloodOxygen)
            }
        }
        
        bigDataItems.append(DayBloodOxygenModel.init(timeStamp: timestamp, bloodOxygens: bloodOxygens.description))
    }
    func handleActivityStatisticsData(_ dataArr: [Data], _ timestamp: UInt32) {
        

        var durationDetailsArr:[UInt16] = []
        for item in dataArr {
            var time: UInt16 = Data(item).scanValue(at: 0)

            durationDetailsArr.append(time)
        }
        //模拟时长数据
        //        durationDetailsArr = [2,3,4,5,6,1,2,4,5,6,8,9,1,3,4,5,2,1,4,5,7,8,9,5,1,2,4,5,3,5,4,5,6,8,9,1,3,4,5,6,1,2,4,5,2,1,4,5,5,7,8,9,5,1,5,7,8,9,5,1,5,3,5,4,5,6,9,1,3,4,5,2,8,9,1,3,4,5,7,8,9,5,1,2,5,3,5,4,5,6,9,1,3,4,5,6,1,2,4,5,2,1,2,4,5,3,5,4,5,1,2,4,5,3,5,7,8,9,5,1,5,7,8,9,5,1,3,4,5,2,8,9,8,9,1,3,4,5,7,8,9,5,1,2]
        
        let sportTimeFloatArray = durationDetailsArr.compactMap({ Float($0)/60 })
        let totalTime = sportTimeFloatArray.reduce(0,+)
        
        var chunkSize = 6
        if sportTimeFloatArray.count > 144 {
            chunkSize = 60
        }
        
        //处理时长数据
        let sportTimesDetail = Ble05sCmdsConfig.shared.chunked(dataArray: sportTimeFloatArray, chunkSize: chunkSize)
        
        bigDataItems.append(DayActivityStatisticsModel.init(timeStamp: timestamp, activityStatistics: sportTimesDetail.description))
        
    }
    
    //运动历史的
    private func handleSportRecordHRData(hrData: Data, decodedInfo:hl_cmds) {
        let heartRates = Ble05sCmdsConfig.shared.chunked(data: hrData, chunkSize: 1).map { (data: Data) -> UInt8 in
            return [UInt8](data).first ?? UInt8(0)
        }
        
        let activeRecord = decodedInfo.rGetActiveRecord
        
        let startTime = handleBackTimestamp(original: activeRecord.mActiveStartSecond)
        
        let sportModelItem = SportModelItem.init(sportModel: .badminton, heartRateNum: 1, startTime: "", endTime: "", step: Int(activeRecord.mActiveStep), count: 0, cal: Int(activeRecord.mActiveCalories), distance: activeRecord.mActiveDistance.description, hrAvg: Int(activeRecord.mActiveAvgHr), hrMax: Int(activeRecord.mActiveMaxHr), hrMin: Int(activeRecord.mActiveMinHr), pace: Int(activeRecord.mActiveSpeed), hrInterval: Int(activeRecord.mActiveHrCount), heartRateData: Data())
        
        
        
        bigSportDataItems.append(sportModelItem)
                                               
    }
    
}

private extension Ble05sParser {
     func handleBackTimestamp(original: UInt32) ->UInt32 {
        
         guard original > 0 else {
             return 0
         }
         
        var localTimestamp = original
        let secondsFromGMT = UInt32(TimeZone.current.secondsFromGMT())
        
        if secondsFromGMT < 0 {
            localTimestamp += secondsFromGMT
        } else {
            localTimestamp -= secondsFromGMT
        }
        
        return localTimestamp
        
    }
    
    func inEffect(i: Int, d: [(start: Int, end: Int)]) ->Bool {
        
        for item in d {
            if i >= item.start && i < item.end {  return true  }
        }
        return false
    }
    
    func transitionSleepState(value: Int) ->Int { //APP 1:持续时间，2:3清醒，1深睡，2浅睡 0无效数据 FW: 1 清醒 3 浅睡 4 深睡
        if value == 1 {
            return 3
        }else if value == 3 {
            return 2
        }else if value == 4 {
            return 1
        }
        return 0
    }
}

