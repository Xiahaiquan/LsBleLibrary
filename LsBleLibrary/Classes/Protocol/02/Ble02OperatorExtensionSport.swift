//
//  Ble02OperatorExtensionSport.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

//MARK: 运动相关
extension Ble02Operator {
    
    /**
     查询设备多运动状态
     */
    public func getSportModelState() -> Observable<(state: SportModelState, sportModel: Int)> {
        let setCmd: [UInt8] = [LS02CommandType.multiSport.rawValue, LS02Placeholder.aa.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"getSportModelState", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let dataBytes = [UInt8](data)
                    guard dataBytes.count >= 4 else {
                        subscriber.onError(BleError.error("设备返回数据不匹配"))
                        return
                    }
                    guard let state = SportModelState(rawValue: dataBytes[2]) else {
                        subscriber.onError(BleError.error("未知运动模式或未知开关状态"))
                        return
                    }
                    subscriber.onNext((state, Int(dataBytes[3])))
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func startSportModel(sportType: Int, state: SportModelState, interval: SportModelSaveDataInterval) -> Observable<Bool>  {
        
        let setCmd: [UInt8] = [LS02CommandType.multiSport.rawValue, state.rawValue, UInt8(sportType), interval.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"getSportModelState", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let dataBytes = [UInt8](data)
                    guard dataBytes.count >= 2 else {
                        subscriber.onError(BleError.error("设备返回数据不匹配"))
                        return
                    }
                    
                    subscriber.onNext(true)
                    
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
        
    }
    
    /**
     解析 运动模式下设备主动上传
     */
    public func analysisSportModelUpload(_ data: Data) -> (model: Int, hr: Int, cal: Int, pace: Int, step: Int, count: Int, distance: Int)? {
        guard data.count > 13 else {
            return nil
        }
        
        let dataBytes: [UInt8] = [UInt8](data)
        
        let model = Int(dataBytes[1])
        let hr = Int(dataBytes[2])
        let cal = (Int(dataBytes[3]) << 8) + Int(dataBytes[4])
        let pace = (Int(dataBytes[5]) << 8) + Int(dataBytes[6])
        let step = (Int(dataBytes[7]) << 16) + (Int(dataBytes[8]) << 8) + Int(dataBytes[9])
        let count = (Int(dataBytes[10]) << 8) + Int(dataBytes[11])
        let distance = (Int(dataBytes[12]) << 8) + Int(dataBytes[13])
        return (model, hr, cal, pace, step, count, distance)
    }
    
    
    /**
     解析 设备 状态变更 上报
     */
    public func analysisSportModelStateChange(_ data: Data) -> (model: Int, state: SportModelState, interval: SportModelSaveDataInterval, step: Int, cal: Int, distance: Int, pace: Int)? {
        guard data.count > 12 else {
            return nil
        }
        let dataBytes: [UInt8] = [UInt8](data)
        let model = Int(dataBytes[2])
        let state = SportModelState(rawValue: dataBytes[1]) ?? SportModelState.start
        let interval = SportModelSaveDataInterval(rawValue: dataBytes[3]) ?? SportModelSaveDataInterval.s10
        let step = (Int(dataBytes[4]) << 16) + (Int(dataBytes[5]) << 8) + Int(dataBytes[6])
        let cal = (Int(dataBytes[7]) << 8) + Int(dataBytes[8])
        let distance = (Int(dataBytes[9]) << 8) + Int(dataBytes[10])
        let pace = (Int(dataBytes[11]) << 8) + Int(dataBytes[12])
        return (model, state, interval, step, cal, distance, pace)
    }
    
    /**
     手机开启的运动， 同步数据到设备
     */
    public func updateSportModel(model: Int, state: SportModelState, interval: SportModelSaveDataInterval, speed: Int, flag: Int,duration: Int, cal: Int, distance: Float, step: Int) -> Observable<BleBackData?>  {
        
        QueueManager.shared.syncDataQueue.cancelAllOperations()
        
        let hour = UInt8(duration / 3600)
        let min = UInt8((duration % 3600) / 60)
        let second = UInt8((duration % 3600) % 60)
        
        let cal1 = UInt8(((cal>>8)&0xFF))
        let cal2 = UInt8(cal&0xFF)
        
        let distanceKmVlaue: Float = Float(distance) / 1000.0          // KM
        
        let distanceDoubleValue = Double(String(format: "%.2f", distanceKmVlaue))!
        let dis1 = UInt8(Int(distanceDoubleValue))
        let dis2 = UInt8(Int(distanceDoubleValue * 100) - Int(distanceDoubleValue) * 100)
        
        var pace = 0
        // 秒 除 千米
        if distanceKmVlaue != 0 {
            var pace = Int(Float(duration) / distanceKmVlaue)
        }
        
        if pace > 0xFFFF {
            pace = 0
        }
        
        let pace1 = UInt8(((pace>>8)&0xFF))
        let pace2 = UInt8(pace&0xFF)
        
        let setCmd: [UInt8] = [0xFD, state.rawValue, UInt8(model), interval.rawValue, hour, min, second, cal1, cal2, dis1, dis2, pace1, pace2]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"getSportModelState", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    let dataBytes = [UInt8](data)
                    guard dataBytes.count >= 2 else {
                        subscriber.onError(BleError.error("设备返回数据不匹配"))
                        return
                    }
                    
                    guard let sportModelInfo = self.analysisSportModelStateChange(data) else {
                        subscriber.onError(BleError.error("运动解析失败"))
                        return
                    }
                    
                    //FD //运动状态44 //运动标志01 //N:06 //运动时长00 00 1E //卡路里00 00 //距离00 00 //配速 0000
                    let item = LSSportRealtimeItem.init(status: sportModelInfo.state, sportModel: sportModelInfo.model, step: UInt32(sportModelInfo.step), calories: UInt32(sportModelInfo.cal), distance: UInt32(sportModelInfo.distance), timeSeond: 0, spacesKm: UInt32(sportModelInfo.pace), interval: sportModelInfo.interval)
    
//                    subscriber.onNext(BleBackData.init(type: .realtimeSporthr, data: item))
                    subscriber.onCompleted()
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
        
    }
    
    /**
     获取多运动模式历史数据, 获取 传入时间后产生的数据
     */
    public func getSportModelHistoryData(datebyFar: Date) -> Observable<LSWorkoutItem?> {
        
        let yearByte1 = UInt8(((datebyFar.year()>>8)&0xFF))
        let yearByte2 = UInt8(datebyFar.year()&0xFF)
        
        let getCmd: [UInt8] = [LS02CommandType.multiSport.rawValue, 0xFA,
                               yearByte1, yearByte2,
                               UInt8(datebyFar.month()),
                               UInt8(datebyFar.day()),
                               UInt8(datebyFar.hour()),
                               UInt8(datebyFar.min())]
        let getData = Data.init(bytes: getCmd, count: getCmd.count)
        
        var sportNum: Int?                                      // 总运动记录数
        
        var sportModel: Int = 0x01            // 运动模式
        var heartRateNum: Int = 0                               // 心率总数
        var startTimestamp: Int = 0                             //开始的时间戳
        var endTimestamp: Int = 0                               //开始的时间戳
        var step: Int = 0                                       // 步数
        var count: Int = 0                                      // 次数
        var cal: Int = 0                                        // 卡路里
        var distance: String = ""                               // 距离
        var hrAvg: Int = 0                                      // 平均心率
        var hrMax: Int = 0                                      // 最大心率
        var hrMin: Int = 0                                      // 最小心率
        var pace: Int = 0                                       // 配速
        var hrInterval: Int = 0                                 // 心率数据间隔
        var duration: Int = 0
        var heartRateData: Data = Data()
        var result: [SportModelItem] = []
        
        var tempCrc: UInt8 = 0                                  // CRC计算
        
        return Observable.create { (subscriber) -> Disposable in
            
            self.bleFacade?.write(getData, 0,"getSportModelHistoryData", 2 * 60, { (data) -> Bool in
                return result.count == sportNum
            })
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas, let data = datas.first else {
                        return
                    }
                    var dataBytes = [UInt8](data)
                    guard dataBytes.count >= 3 else {
                        subscriber.onError(BleError.error("设备返回数据缺失"))
                        return
                    }
                    
                    // 如果是FA会携带运动记录数
                    if dataBytes[1] == 0xFA {
                        sportNum = Int(Int(dataBytes[8]) << 8) + Int(dataBytes[9])
                        tempCrc = 0
                        if sportNum == 0 {
                            subscriber.onNext(nil)
                            subscriber.onCompleted()
                        }
                        return
                    }
                    
                    // 如果是FD表示单条数据传输完成
                    if dataBytes[1] == 0xFD  {
                        
                        let item = SportModelItem.init(sportModel: sportModel, heartRateNum: heartRateNum, startTimestamp: startTimestamp, endTimestamp: endTimestamp, step: step, count: count, cal: cal * 1000, distance: distance, hrAvg: hrAvg, hrMax: hrMax, hrMin: hrMin, pace: pace, hrInterval: hrInterval, heartRateData: heartRateData, durations: duration)
                        result.append(item)
                        print("result.coun",result.count, sportNum, "tempCrc",tempCrc,dataBytes[2] )
                        if result.count == sportNum  {
                            let items = LSWorkoutItem.init(value: result)
                            subscriber.onNext(items)
                            subscriber.onCompleted()
                        }
                        return
                    }
                    
                    let indexByte = Int(Int(dataBytes[1]) << 8) + Int(dataBytes[2])
                    
                    if indexByte == 0x00 {
                        guard dataBytes.count >= 19 else {
                            subscriber.onError(BleError.error("设备返回多运动数据缺失"))
                            return
                        }
                        
                        let s_year = Int(Int(dataBytes[6]) << 8) + Int(dataBytes[7])
                        let s_month = dataBytes[8]
                        let s_day = dataBytes[9]
                        let s_hour = dataBytes[10]
                        let s_min = dataBytes[11]
                        let s_second = dataBytes[12]
                        
                        let startDate = Calendar.init(identifier: Calendar.Identifier.gregorian).date(from: DateComponents(year: Int(s_year), month: Int(s_month), day: Int(s_day), hour: Int(s_hour), minute: Int(s_min), second: Int(s_second)))
                        
                        heartRateData = Data()
                        sportModel = Int(dataBytes[3])
                        heartRateNum = Int(Int(dataBytes[4]) << 8) + Int(dataBytes[5]) //心率数据总长度
                        
                        startTimestamp = Int(startDate?.timeIntervalSince1970 ?? 0)
                        var endDate:Date?
                        
                        if Ble02Operator.shared.uteFunc?.multiSportDuration ?? false {
                            let timestamp = Int(dataBytes[13])<<24|Int(dataBytes[14])<<16|Int(dataBytes[15])<<8|Int(dataBytes[16])
                            let timestamps = Int((dataBytes[13]&0xff)<<24)|Int((dataBytes[14]&0xff)<<16)|Int((dataBytes[15]&0xff)<<8)|Int((dataBytes[16]&0xff))
                            
                            let sportTime = dataBytes[17]<<16|dataBytes[18]<<8|dataBytes[19]
                            let timeInterval = TimeInterval(timestamp)
                            endDate = Date.init(timeIntervalSince1970: timeInterval)
                            duration = Int(sportTime)
                            endTimestamp = Int(timeInterval)
                        }else {
                            let end_year = Int(Int(dataBytes[13]) << 8) + Int(dataBytes[14])
                            let end_month = dataBytes[15]
                            let end_day = dataBytes[16]
                            let end_hour = dataBytes[17]
                            let end_min = dataBytes[18]
                            let end_second = dataBytes[19]
                            endDate = Calendar.init(identifier: Calendar.Identifier.gregorian).date(from: DateComponents(year:  Int(end_year), month: Int(end_month), day: Int(end_day), hour: Int(end_hour), minute: Int(end_min), second: Int(end_second)))
                            endTimestamp = Int(endDate?.timeIntervalSince1970 ?? 0)
                            if let endD = endDate, let startD = startDate {
                                duration = Int(endD.timeIntervalSince(startD))
                            }
                        }
                        
                    } else if indexByte == 0x01 {
                        guard dataBytes.count >= 17 else {
                            subscriber.onError(BleError.error("设备返回多运动数据缺失"))
                            return
                        }
                        step = Int(Int(dataBytes[3]) << 8) + Int(dataBytes[4]) + Int(dataBytes[5])
                        count = Int(Int(dataBytes[6]) << 8) + Int(dataBytes[7])
                        cal = Int(Int(dataBytes[8]) << 8) + Int(dataBytes[9]) //协议返回的就是千卡
                        distance = "\(dataBytes[10]).\(dataBytes[11])"
                        hrAvg = Int(dataBytes[12])
                        hrMax = Int(dataBytes[13])
                        hrMin = Int(dataBytes[14])
                        pace = Int(Int(dataBytes[15]) << 8) + Int(dataBytes[16])
                        hrInterval = Int(dataBytes[17])
                    } else {
                        // 除去 头 和序列都是心率内容
                        let startIndex = data.index(data.startIndex, offsetBy: 3)
                        let subDataRange: Range = startIndex..<data.endIndex
                        let heartRateContentData = data.subdata(in: subDataRange)
                        heartRateData.append(heartRateContentData)
                    }
                    dataBytes.removeFirst()
                    dataBytes.forEach { (v) in          // CRC 计算
                        tempCrc = tempCrc ^ v
                    }
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    func analysisGPSRealtime(_ data: Data) -> (lat: Double, long: Double, speed: Double, altitude: Double, signal: Int)? {
        let byteArray = [UInt8](data)
        guard byteArray.count > 16 else {
            return nil
        }
        
        let intbyte2 = Int(byteArray[2])
        let intbyte3 = Int(byteArray[3])
        let intbyte4 = Int(byteArray[4])
        let intbyte5 = Int(byteArray[5])
        let intbyte6 = Int(byteArray[6])
        let intbyte7 = Int(byteArray[7])
        let intbyte8 = Int(byteArray[8])
        let intbyte9 = Int(byteArray[9])
        let intbyte10 = Int(byteArray[10])
        let intbyte11 = Int(byteArray[11])
        let intbyte12 = Int(byteArray[12])
        let intbyte13 = Int(byteArray[13])
        let intbyte14 = Int(byteArray[14])
        let intbyte15 = Int(byteArray[15])
        let intbyte16 = Int(byteArray[16])
        
        
        let lat = Double(intbyte2<<24|intbyte3<<16|intbyte4<<8|intbyte5)/1000000
        let long = Double(intbyte6<<24|intbyte7<<16|intbyte8<<8|intbyte9)/1000000
        let speed = Double(intbyte10<<8|intbyte11)/100
        let altitude = Double(intbyte12<<24|intbyte13<<16|intbyte14<<8|intbyte15)/100
        let signal = intbyte16
        
        if signal == 0xff {
            return nil
        }
        
        return (lat, long, speed, altitude, signal)
    }
    
}
