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
            self.bleFacade?.write(setData, 0,"closeWatchGPS", 3, nil)
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
            self.bleFacade?.write(setData, 0,"requestWatchGPSState", 3, nil)
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
            self.bleFacade?.write(setData, 0,"deleteWatchGPSData", 3, nil)
                .subscribe { (bleResponse) in
                    //????????? 0x818200 ????????????
                    //????????? 0x818201 ????????????
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
    
    //?????????????????? AGPS ??????
    public func readyUpdateAGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Ls02ReadyUpdateAGPSStatus> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, 0x00,
                               type.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"readyUpdateAGPSCommand", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first
                    else {
                        subscriber.onError(BleError.error("????????????"))
                        return
                    }
                    
                    let bytes = [UInt8](datas)
                    
                    guard bytes.count > 2 else {
                        subscriber.onError(BleError.error("??????????????????"))
                        return
                    }
                    
                    let status = Ls02ReadyUpdateAGPSStatus.init(rawValue: bytes[2])
                    
                    subscriber.onNext(status ?? .faile)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    //????????????????????????or?????????????????????
    public func updateAGPComplete(type: Ls02UpdateAGPSCompleteMode) -> Observable<Ls02ReadyUpdateAGPSStatus> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, type.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"updateAGPComplete", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first,
                          [UInt8](datas).count == 3 else {
                              subscriber.onError(BleError.error(""))
                              return
                          }
                    let state = Ls02ReadyUpdateAGPSStatus.init(rawValue: [UInt8](datas)[2])
                    subscriber.onNext(state ?? .allComplete)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
    //??????????????????????????????
    public func checkBeidouDataInvalte() -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, 0x08]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"checkBeidouDataInvalte", 3, nil)
                .subscribe { (bleResponse) in
                    //????????? 0x81830800 ??????????????????
                    //????????? 0x81830801 ??????????????????
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
    

    //?????????????????? GPS ??? OTA ??????
    public func readyUpdateGPSCommand(type: Ls02UpdateAGPSMode) -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x83, 0x00,
                               type.rawValue]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"readyUpdateGPSCommand", 3 * 60, { data in
                
                let dataBytes = [UInt8](data)
                guard dataBytes.count >= 3 else {
                    return false
                }

                let dataType = dataBytes[2]
                if dataType == 0x00 {
                    print("gps update.?????? ok")
                }else if dataType == 0x01{
                    print("gps update.?????? GPS OTA ???????????? ????????????????????????????????????????????????????????? ?????????????????????B3<<8|B4")
                }else if dataType == 0x02{
                    print("gps update.????????????")
                }else if dataType == 0x03{
                    print("gps update.????????????")
                    return true
                }else if dataType == 0x04{
                    print("gps update.?????? CRC ??????")
                }else if dataType == 0x05{
                    print("gps update.?????? CRC ????????????????????????")
                }else if dataType == 0x06 {
                    print("gps update.??????????????????????????????")
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
            self.bleFacade?.write(setData, 0,"getGPSFirmwareVersion", 3, nil)
                .subscribe { (bleResponse) in
//                    ?????? 0x818407xxxxxx ?????????????????? GPS ??? OTA ???????????????????????? ??? 5??? ?????? 0x8185+?????????4b
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
    ///   - altitude: ????????????
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
            self.bleFacade?.write(setData, 0,"sentLocationInformation", 3, nil)
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
            self.bleFacade?.write(setData, 0,"openWatchGPS", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    //??????????????????
    public func closeWatchGPS() -> Observable<Bool> {
        let setCmd: [UInt8] = [LS02CommandType.gpsCommand.rawValue, 0x73, 0x00]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"closeWatchGPS", 3, nil)
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
            self.bleFacade?.write(setData, 0,"startAGPSDataCommand", 3, nil)
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
            self.bleFacade?.write(setData, 0,"startGPSOTADataCommand", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func sendAGPSDataCommand(gpsData: Data, number: Int) -> Observable<Ls02ReadyUpdateAGPSStatus> {
        let setCmd: [UInt8] = [LS02CommandType.receiveGPSCommand.rawValue,
                               UInt8((number>>8)&0xff),
                               UInt8(number&0xff)]
        var setData = Data.init(bytes: setCmd, count: setCmd.count)
        setData.append(gpsData)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"sendAGPSDataCommand", 3, nil)
                .subscribe { (bleResponse) in
                    guard let datas = bleResponse.datas?.first,
                          let data = [UInt8](datas).first,
                          let status = Ls02ReadyUpdateAGPSStatus.init(rawValue: data) else {
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
    
    //???????????????????????????
    public func sendGPSOTADataCommand(gpsData: Data, number: Int) -> Observable<Bool> {
        let setCmd: [UInt8] = [0x82, UInt8((number>>8)&0xff), UInt8(number&0xff)]
        var setData = Data.init(bytes: setCmd, count: setCmd.count)
        setData.append(gpsData)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, 0,"sendAGPSDataCommand", 3, nil)
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
