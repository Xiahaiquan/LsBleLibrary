//
//  Ble02OperatorExtensionCreateTestData.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/15.
//

import Foundation
import RxSwift

extension Ble02Operator {
    
    public func createTestStepsData(year: Int, month: Int, day: Int) -> Observable<Bool> {
        let resetCmd: [UInt8] = [LS02CommandType.creatTestData.rawValue, 0x01,
                                 UInt8((year>>8)&0xff),
                                 UInt8(year&0xff),
                                 UInt8(month),
                                 UInt8(day),
                                 0,0,0]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, "createTestStepsData", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    public func createTestSleepingData(year: Int, month: Int, day: Int) -> Observable<Bool> {
        let resetCmd: [UInt8] = [LS02CommandType.creatTestData.rawValue, 0x02,
                                 UInt8((year>>8)&0xff),
                                 UInt8(year&0xff),
                                 UInt8(month),
                                 UInt8(day),
                                 0,0,0]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, "createTestSleepingData", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    public func createTestHeartRateData(year: Int, month: Int, day: Int) -> Observable<Bool> {
        let resetCmd: [UInt8] = [LS02CommandType.creatTestData.rawValue, 0x03,
                                 UInt8((year>>8)&0xff),
                                 UInt8(year&0xff),
                                 UInt8(month),
                                 UInt8(day)]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, "createTestHeartRateData", 3, nil)
                .subscribe { (bleResponse) in
                    subscriber.onNext(true)
                } onError: { (error) in
                    subscriber.onError(error)
                }
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func createTestHeartRateData(sportType: Int, year: Int, month: Int, day: Int, hour: Int, min: Int) -> Observable<Bool> {
        let resetCmd: [UInt8] = [LS02CommandType.creatTestData.rawValue, 0x03,UInt8(sportType),
                                 UInt8((year>>8)&0xff),
                                 UInt8(year&0xff),
                                 UInt8(month),
                                 UInt8(day),
                                 UInt8(hour),
                                 UInt8(min)]
        let resetData = Data.init(bytes: resetCmd, count: resetCmd.count)
        return Observable.create { (subscriber) -> Disposable in
            self.bleFacade?.write(resetData, "createTestHeartRateData", 3, nil)
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
