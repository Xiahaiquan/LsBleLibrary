//
//  Ble02OperatorExtensionDial.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

//MARK: 在线表盘
extension Ble02Operator {
    /**
     获取设备表盘信息
     */
    public func getCloudWatchFaceSetting() -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        let setCmd: [UInt8] = [0x1A, 0x01]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return self.bleFacade!.write(setData, "getCloudWatchFaceSetting", 3, nil)
            .flatMap({
                self.parseCloudWatchFaceSetting(bleResponse: $0)
            })
    }
    
    public func writeComplete() -> Observable<Bool> {
        let setCmd: [UInt8] = [0x1A, 0x03, 0x00]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(setData, "writeComplete", 3, nil)
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
     询问设备是否可以传输表盘
     */
    public func requestCloudWatchFaceTransfer() -> Observable<Bool> {
        let setCmd: [UInt8] = [0x1A, 0x02]
        let setData = Data.init(bytes: setCmd, count: setCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            
            self.bleFacade?.write(setData, "requestCloudWatchFaceTransfer", 3, nil)
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
                    if dataBytes[0] == 0x0A && dataBytes[1] == 0x02 {
                        subscriber.onNext(true)
                    } else {
                        subscriber.onNext(false)
                    }
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    // 解析
    public func parseCloudWatchFaceSetting(bleResponse: BleResponse) -> Observable<(watchFaceNo: Int, watchFaceWidth: Int, watchFaceHeight: Int, watchFaceType: Int, maxSpace: Int)> {
        return Observable.create { (subscriber) -> Disposable in
            guard let datas = bleResponse.datas, let data = datas.first else {
                subscriber.onError(BleError.error("返回表盘设置数据异常"))
                return Disposables.create()
            }
            guard data.count >= 15 else {
                subscriber.onError(BleError.error("返回表盘设置数据长度异常"))
                return Disposables.create()
            }
            let watchFaceBytes = [UInt8](data)
            let watchFaceNo = (Int(watchFaceBytes[2]) << 24) + Int(watchFaceBytes[3]) << 16 + Int(watchFaceBytes[4]) << 8 + Int(watchFaceBytes[5])  //表盘编号
            let watchFaceWidth = Int(watchFaceBytes[6]) << 8 + Int(watchFaceBytes[7])               // 屏幕宽像素
            let watchFaceHeight = Int(watchFaceBytes[8]) << 8 + Int(watchFaceBytes[9])              // 屏幕宽像素
            let watchFaceType = Int(watchFaceBytes[10])                                             // 暂时固定为 0
            let maxSpace = (Int(watchFaceBytes[11]) << 24) + Int(watchFaceBytes[12]) << 16 + Int(watchFaceBytes[13]) << 8 + Int(watchFaceBytes[14]) //表盘支持升级空间
            subscriber.onNext((watchFaceNo, watchFaceWidth, watchFaceHeight, watchFaceType, (maxSpace)))
            return Disposables.create()
        }
    }
}
