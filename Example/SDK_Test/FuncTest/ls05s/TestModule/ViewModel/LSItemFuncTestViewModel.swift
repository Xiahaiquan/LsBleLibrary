//
//  LSItemFuncTestViewModel.swift
//  HaylouWatch
//
//  Created by Antonio on 2021/3/29.
//  Copyright © 2021 haylou. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth
import LsBleLibrary
//import LsDbLibrary

class LSItemFuncTestViewModel {
    
    let bag = DisposeBag()
    
    var cloudTransferManager: Ls05sWatchFaceTransferManager!
    
    init() {
        bleDataObserver()
        
    }
    
    func handleAction(value: String) {
        
        switch value {
            
        case "获取MTU":
            
            BleOperator.shared.getmtu().subscribe { (mtu) in
                print(mtu, "back mtu")
            } onError: { (err) in
                print(err)
            }.disposed(by: bag)
            
        case "绑定设备":
            
            //65214001
            BleOperator.shared.setUserInfo(userId: 65214007).subscribe { (bindOperatnion) in
                print("bindOperatnion", bindOperatnion)
            } onError: { (err) in
                
            }.disposed(by: bag)
            
        case "配置设备":
            
            BleOperator.shared.configDevice(phoneInfo: (model: .iOS,
                                                        systemversion: 14,
                                                        appversion: 235,
                                                        language: 1),
                                            switchs: Data(),
                                            longsit: (duration: 5,
                                                      startTime: 123,
                                                      endTime: 456,
                                                      nodisturbStartTime: 123,
                                                      nodisturbEndTime: 456),
                                            drinkSlot: (drinkSlot: 456,
                                                        startTime: 123,
                                                        endTime: 456,
                                                        nodisturbStartTime: 123,
                                                        nodisturbEndTime: 456),
                                            alarms: [AlarmModel()],
                                            countryInfo: (name: "china".data(using: .utf8)!,
                                                          timezone: 8),
                                            uiStyle:(style: 1,
                                                     clock: 2),
                                            target: (cal: 100,
                                                     dis: 200,
                                                     step: 300),
                                            timeFormat: .h24,
                                            metricInch: .imperial,
                                            brightTime: 5,
                                            upper: 80,
                                            lower: 20,
                                            code: 2,
                                            duration: 5).subscribe { (status) in
                print("configDevice", status)
            } onError: { (err) in
                
            }.disposed(by: bag)
            
        case "获取设备信息": break
            
            
        case "同步手机信息": break
        case "设置运动目标": break
        case "同步用户信息" : break
        case "同步开关": break
        case "设置心率采样间隔" : break
        case "设置久坐间隔" : break
        case "设置喝水间隔": break
        case "设置闹钟": break
        case "获取闹钟": break
        case "设置免打扰": break
        case "设置国家": break
        case "设置UI风格": break
        case "设置时间格式": break
        case "设置公英制": break
        case "设置亮屏时长": break
        case "设置心率预警": break
        case "获取心率": break
        case "设置通知提醒": break
        case "获取健康数据":
            BleOperator.shared.getHealthData().subscribe { (value) in
                print("getHealthData", value)
            } onError: { (err) in
                
            }.disposed(by: bag)
            
        case "获取电量": break
        case "设置固件升级": break
        case "找设备": break
        case "设置天气": break
        case "恢复出厂":
            BleOperator.shared.unBindDevice().subscribe { (status) in
                print("unBindDevice", status)
                BleDeviceArchiveModel.delete()
            } onError: { (err) in
                
            }.disposed(by: bag)
            
            
        case "设置运动状态": break
        case "查询运动状态": break
        case "Bin文件升级": break
        case "工厂测试": break
        case "发送Bin文件": break
        case "获取实时心率": break
        case "设置免打扰开关": break
        case "生成测试数据":
            BleOperator.shared.makeTestData().subscribe { (status) in
                print("makeTestData", status)
            } onError: { (err) in
                
            }.disposed(by: bag)
        case "获取运动数据":
            BleOperator.shared.getSportModelHistoryData(datebyFar: Date()).subscribe { (status) in
                print("multiSportQuery", status)
            } onError: { (err) in
                
            }.disposed(by: bag)
        case "同步步数": break
        case "查询GPS信息": break
        case "设置GPS信息": break
        case "获取功能项目": break
        case "获取表盘数据": break
        case "设置提醒数据": break
        case "设置血氧采样间隔": break
        case "获取血氧采样间隔": break
        case "获取一级排序": break
        case "设置一级排序": break
        case "获取手表Log": break
        case "发送App状态": break
            
        case "同步时间": break
        case "设置常用参数": break
            
        case "升表盘1":
            break
//            let filePath = Bundle.main.path(forResource: "Ls05s_1", ofType: "bin")
//            let watchFaceData = try! Data.init(contentsOf: URL(fileURLWithPath: filePath!))
//            self.cloudTransferManager = LsCloudWatchFaceViewController.init(binData: watchFaceData)
//
//            self.cloudTransferManager.start()
//                .subscribe { (progressState) in
//                    switch progressState {
//                    case .progress(let value):
//                        print("progress: \(value)")
//                    default:
//                        print("\(progressState)")
//                    }
//
//                } onError: { (error) in
//                    print("start error")
//                }
//                .disposed(by: self.bag)
        case "升表盘2":
//            break
            let filePath = Bundle.main.path(forResource: "Ls05s_2", ofType: "bin")
            let watchFaceData = try! Data.init(contentsOf: URL(fileURLWithPath: filePath!))
            self.cloudTransferManager = Ls05sWatchFaceTransferManager.init(binData: watchFaceData)

            self.cloudTransferManager.start()
                .subscribe { (progressState) in
                    print("progressState", progressState)
                    switch progressState {
                    case .progress(let value):
                        print("progress: \(value)")
                    default:
                        print("\(progressState)")
                    }

                } onError: { (error) in
                    print("start error")
                }
                .disposed(by: self.bag)
            
        case "清除连接记录":
            BleDeviceArchiveModel.delete()
            
        case "获取步数历史数据":
            
            
            BleOperator.shared.getHealthData(syncType: .stepsSend, secondStart: UInt32(Date().timeIntervalSince1970 - 7 * 24 * 60 * 60), secondEnd: UInt32(Date().timeIntervalSince1970))
                .subscribe { value in
                    print("获取步数历史数据", value)
                } onError: { _ in
                    
                }
                .disposed(by: self.bag)
            
        case "获取血氧历史数据":
            BleOperator.shared.getHealthData(syncType: .bloodOxygenSend, secondStart: UInt32(Date().timeIntervalSince1970 - 7 * 24 * 60 * 60), secondEnd: UInt32(Date().timeIntervalSince1970))
                .subscribe { value in
                    print("获取血氧历史数据返回的状态", value)
                }
                .disposed(by: self.bag)
            
        case "获取心率历史数据":
            BleOperator.shared.getHealthData(syncType: .heartRateSend, secondStart: UInt32(Date().timeIntervalSince1970 - 7 * 24 * 60 * 60), secondEnd: UInt32(Date().timeIntervalSince1970))
                .subscribe { value in
                    print("获取心率数据返回的状态", value)
                }
                .disposed(by: self.bag)
        case "获取睡眠历史数据":
            BleOperator.shared.getHealthData(syncType: .sleepSend, secondStart: UInt32(Date().timeIntervalSince1970 - 7 * 24 * 60 * 60), secondEnd: UInt32(Date().timeIntervalSince1970))
                .subscribe { value in
                    print("获取睡眠数据返回的状态", value)
                }
                .disposed(by: self.bag)
            
            
        case "监听找手机的命令":
            break
            
        case "获取每日步数":
            break
//            LSGetDataManager().getStepData(date: Date()).subscribe { models in
//                print(models)
//            } onFailure: { error in
//                print(error)
//            }.disposed(by: bag)
            
        case "获取手表功能列表":
            break
//            AppFeaturesModel.share.getAppFeaturesModel().subscribe { model in
//                print(model)
//            } onError: { e in
//
//            }.disposed(by: bag)

        default:
            break
        }
        
    }
}



extension LSItemFuncTestViewModel {
    
    func bleDataObserver() {
        
        BleOperator.shared.dataObserver?.subscribe(onNext: { data in
            print("bleDataObserver", data)
        }, onError: { e in
            print("bleDataObserver",e)
        }).disposed(by: bag)
        
    }
    
}
