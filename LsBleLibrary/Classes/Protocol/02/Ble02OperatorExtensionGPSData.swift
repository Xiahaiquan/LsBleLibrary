//
//  Ble02OperatorExtensionGPSData.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

extension Ble02Operator {
    
    public func requestGPSSportData(year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Ls02GPSDataBackMode> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x80,
                                 UInt8((year>>8)&0xff),
                                 UInt8(year&0xff),
                                 UInt8(month),
                                 UInt8(day),
                                 UInt8(hour),
                                 UInt8(min)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "closeWatchGPS", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first,
                          let data = [UInt8](datas).first,
                          let status = Ls02GPSDataBackMode.init(rawValue: data) else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext(status)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func requestWatchGPSState() -> Observable<Ls02GPSStatusMode> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x81]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "requestWatchGPSState", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first,
                          let data = [UInt8](datas).first,
                          let status = Ls02GPSStatusMode.init(rawValue: data) else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext(status)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func deleteWatchGPSData() -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x82]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "deleteWatchGPSData", 3, nil)
                .subscribe { (bleResponse) in
                    //返回值 0x818200 删除成功
                    //返回值 0x818201 删除失败
                    guard let datas = bleResponse.datas?.first,
                          [UInt8](datas).count == 3 else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext([UInt8](datas)[2] == 0)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    //准备开始发送 AGPS 数据
    public func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatue> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, 0x00,
                               type.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "readyUpdateAGPSCommand", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first,
                          let data = [UInt8](datas).first,
                          let status = Ls02ReadyUpdateAGPSStatue.init(rawValue: data) else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext(status)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    public func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, type.rawValue,
                               type.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "updateAGPComplete", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    //检查星历数据是否有效
    public func checkBeidouDataInvalte() -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, 0x08]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "checkBeidouDataInvalte", 3, nil)
                .subscribe { (bleResponse) in
                    //返回值 0x81830800 星历数据无效
                    //返回值 0x81830801 星历数据有效
                    guard let datas = bleResponse.datas?.first,
                          [UInt8](datas).count == 4 else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext([UInt8](datas)[3] == 1)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    public func checkBeidouDataInvate() -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x84, 0x00]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "checkBeidouDataInvalte", 3, nil)
                .subscribe { (bleResponse) in
                    //返回值 0x81830800 星历数据无效
                    //返回值 0x81830801 星历数据有效
                    guard let datas = bleResponse.datas?.first,
                          [UInt8](datas).count == 4 else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext([UInt8](datas)[3] == 1)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    //准备开始发送 GPS 的 OTA 数据
    public func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, 0x00,
                               type.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "readyUpdateGPSCommand", 3 * 60, { data in
                
                let dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }

                let dataType = dataBytes[2]
                if dataType == 0x00 {
                    print("gps update.准备 ok")
                }else if dataType == 0x01{
                    print("gps update.发送 GPS OTA 数据不连 续，后面跟两个字节为断点序号，从此序号 重新发序号为：B3<<8|B4")
                }else if dataType == 0x02{
                    print("gps update.继续发送")
                }else if dataType == 0x03{
                    print("gps update.更新成功")
                    return true
                }else if dataType == 0x04{
                    print("gps update.数据 CRC 通过")
                }else if dataType == 0x05{
                    print("gps update.数据 CRC 不通过，数据无效")
                }else if dataType == 0x06 {
                    print("gps update.发送所有文件数据结束")
                    return true
                }
                return false
            })
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func getGPSFirmwareVersion() -> Observable<String> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x84,0x87]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "getGPSFirmwareVersion", 3, nil)
                .subscribe { (bleResponse) in
//                    返回 0x818407xxxxxx 准备开始发送 GPS 的 OTA 数据，数据格式参 照 5） 发送 0x8185+纬度（4b
                    subscriber.onNext("123")
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - latitude: <#latitude description#>
    ///   - longitude: <#longitude description#>
    ///   - altitude: 单位是米
    /// - Returns: <#description#>
    public func sentLocationInformation(latitude: Float, longitude: Float, altitude: Float) -> Observable<Bool> {
        let lat = Int64(latitude * pow(10, 7))
        let lon = Int64(longitude * pow(10, 7))
        let alt = Int64(longitude * pow(10, 2))

        let setCmd = [0x81, 0x85,
                      lat & 0xFF,
                      (lat >> 8) & 0xFF,
                      (lat >> 16) & 0xFF,
                      (lat >> 24) & 0xFF,
                      lon & 0xFF,
                      (lon >> 8) & 0xFF,
                      (lon >> 16) & 0xFF,
                      (lon >> 24) & 0xFF,
                      alt & 0xFF,
                      (alt >> 8) & 0xFF,
                      (alt >> 16) & 0xFF,
                      (alt >> 24) & 0xFF]
        
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "sentLocationInformation", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    
    
    
    public func openWatchGPS(sportType: Int) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x73,UInt8(sportType)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "openWatchGPS", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    //这个可以删除
    public func closeWatchGPS() -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x73, 0x00]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "closeWatchGPS", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    

    
    public func startAGPSDataCommand(agpsType: Int) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, UInt8(agpsType)]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "startAGPSDataCommand", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    

    

    public func startGPSOTADataCommand(gpsType: UInt8) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x84, gpsType]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "startGPSOTADataCommand", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatue> {
        let setCmd: [UInt8] = [LS02CommandType.receiveGPSCommand.rawValue,
                               UInt8((number>>8)&0xff),
                               UInt8(number&0xff)]
        var setData = Data.init(bytes: setCmd, count: setCmd.count)
        setData.append(gpsData)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "sendAGPSDataCommand", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first,
                          let data = [UInt8](datas).first,
                          let status = Ls02ReadyUpdateAGPSStatue.init(rawValue: data) else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    subscriber.onNext(status)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    //这个可能也可以删除
    public func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool> {
        let setCmd: [UInt8] = [0x82, UInt8((number>>8)&0xff), UInt8(number&0xff)]
        var setData = Data.init(bytes: setCmd, count: setCmd.count)
        setData.append(gpsData)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "sendAGPSDataCommand", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    

    
}
