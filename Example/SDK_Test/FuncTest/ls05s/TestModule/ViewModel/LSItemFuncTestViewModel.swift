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


class LSItemFuncTestViewModel {
    
    let bag = DisposeBag()
    
    var cloudTransferManagerLS: Ls05sWatchFaceTransferManager!
    var cloudTransferManagerUTE: Ls02WatchFaceTransferManager!
    var gpsTransferManager: Ls02GPSTransferManager!
    
    
    init() {
        bleDataObserver()
        
    }
    
    func handleAction(value: String) {
    
        switch value {
            
        case "获取MTU":
            
            BleHandler.shared.getmtu().subscribe { (mtu) in
                print(mtu, "back mtu")
            } onError: { (err) in
                print(err)
            }.disposed(by: bag)
            
        case "绑定设备":
            
            //65214001
            BleHandler.shared.bindDevice(userId: 65214009).subscribe { (bindOperatnion) in
                print("bindOperatnion", bindOperatnion)
            } onError: { (err) in
                
            }.disposed(by: bag)
            
        case "配置设备":
            
            BleHandler.shared.configDevice(phoneInfo: (model: .iOS,
                                                       systemversion: 14,
                                                       appversion: 235,
                                                       language: .en),
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
                                           alarms: [AlarmModel(cfg: 1, hour: 2, min: 3, once: 4, reMark: "123", enable: false, index: 0)],
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
            
        case "获取设备信息":
            break
            
        case "断开连接":
            BleFacade.shared.connecter.disConnect().subscribe { status in
                print("断开连接", status)
            } onError: { er in
                print("断开连接", er)
            }.disposed(by: bag)
            
        case "重连":
            break
//            DeviceModel.shared.reConnect()
            
//            BleHandler.shared.getAlarmsMaxSupportNum().subscribe { value in
//                print("value", value)
//            } onError: { er in
//                print("断开连接123", er)
//            }.disposed(by: bag)

            
            
        case "同步手机信息":
            BleHandler.shared.syncPhoneInfoToLS(model: .iOS, systemversion: 1, appversion: 2, language: .en).subscribe { value in
                print("同步手机信息", value)
            } onError: { error in
                print("同步手机信息", error)
            }.disposed(by: bag)
        case "设置运动目标":
            BleHandler.shared.configureSportsGoalSettings(cal: 1, dis: 2, step: 3).subscribe { value in
                print("设置运动目标", value)
            } onError: { error in
                print("设置运动目标", error)
            }.disposed(by: bag)
        case "同步开关":
            break
            
        case "抬腕亮屏开关":
            
            BleHandler.shared.setANCCItemSwitch(.youtube, .open,  switchConfigValue: 0)
                .subscribe { value in
                print("抬腕亮屏开关", value)
            } onError: { error in
                print("抬腕亮屏开关", error)
            }.disposed(by: bag)
            
        case "抬腕亮屏时长":
            BleHandler.shared.configureTheBrightScreenDuration(brightTime: 10).subscribe { value in
                print("抬腕亮屏时长", value)
            } onError: { error in
                print("抬腕亮屏时长", error)
            }.disposed(by: bag)
            
        case "设置心率采样间隔" :
            BleHandler.shared.configureRealTimeHeartRateCollectionInterval(slot: 1).subscribe { value in
                print("", value)
            } onError: { error in
                print("", error)
            }.disposed(by: bag)
        case "设置久坐间隔" :
            print("没有实现")
        case "设置喝水间隔":
            BleHandler.shared.configureDrinkingReminderInterval(drinkSlot: 1, startTime: 2, endTime: 3, nodisturbStartTime: 4, nodisturbEndTime: 5).subscribe { value in
                print("设置喝水间隔", value)
            } onError: { error in
                print("设置喝水间隔", error)
            }.disposed(by: bag)
        case "设置闹钟":
            let alarm = AlarmModel(cfg: 1, hour: 3, min: 5, once: 6, reMark: "122", enable: false, index: 0)
            
            BleHandler.shared.configureAlarmReminder(alarms: [alarm]).subscribe { value in
                print("设置闹钟", value)
            } onError: { error in
                print("设置闹钟", error)
            }.disposed(by: bag)
        case "获取闹钟":
            BleHandler.shared.getWatchAlarm().subscribe { value in
                print("获取闹钟", value)
            } onError: { error in
                print("获取闹钟", error)
            }.disposed(by: bag)
        case "设置免打扰":
            BleHandler.shared.configureDoNotDisturbTime(notdisturbTime1: Data(), notdisturbTime2: Data()).subscribe { value in
                print("", value)
            } onError: { error in
                print("", error)
            }.disposed(by: bag)
        case "设置国家":
            BleHandler.shared.configureCountryInformation(name: "china".data(using: .utf8)!, timezone: 8).subscribe { value in
                print("设置国家", value)
            } onError: { error in
                print("设置国家", error)
            }.disposed(by: bag)
        case "设置UI风格":
            BleHandler.shared.configureUIStyle(style: 1, clock: 2).subscribe { value in
                print("设置UI风格", value)
            } onError: { error in
                print("设置UI风格", error)
            }.disposed(by: bag)
        case "设置时间格式":
            BleHandler.shared.setDateFormat(unit: .imperial, date: .h12).subscribe { value in
                print("设置时间格式", value)
            } onError: { error in
                print("设置时间格式", error)
            }.disposed(by: bag)
        case "设置亮屏时长":
            BleHandler.shared.configureTheBrightScreenDuration(brightTime: 5).subscribe { value in
                print("设置亮屏时长", value)
            } onError: { error in
                print("设置亮屏时长", error)
            }.disposed(by: bag)
        case "设置心率预警":
            BleHandler.shared.configureHeartRateWarning(upper: 1, lower: 2).subscribe { value in
                print("设置心率预警", value)
            } onError: { error in
                print("设置心率预警", error)
            }.disposed(by: bag)
        case "获取心率":
            BleHandler.shared.requestHeartRateData().subscribe { value in
                print("获取心率", value)
            } onError: { error in
                print("获取心率", error)
            }.disposed(by: bag)
        case "设置通知提醒":
            BleHandler.shared.notificationReminder(type: 1, titleLen: 2, msgLen: 3, reserved: Data(), title: Data(), msg: Data(), utc: 2) .subscribe { value in
                print("设置通知提醒", value)
            } onError: { error in
                print("设置通知提醒", error)
            }.disposed(by: bag)
        case "获取电量":
            BleHandler.shared.getBattery().subscribe { value in
                print("获取电量", value)
            } onError: { error in
                print("获取电量", error)
            }.disposed(by: bag)
        case "设置固件升级":
            BleHandler.shared.upgradeCommand(version: 1).subscribe { value in
                print("设置固件升级", value)
            } onError: { error in
                print("设置固件升级", error)
            }.disposed(by: bag)
        case "设置天气":
            let weather = LSWeather.init(currTem: 1, highTem: 2, lowTem: 3, wea: 4, airLevel: 5, pm25: 6, weatherState: .cloudy)
            BleHandler.shared.setWeatherData([weather]).subscribe { value in
                print("设置天气", value)
            } onError: { error in
                print("设置天气", error)
            }.disposed(by: bag)
            
            
            
        case "恢复出厂":
            
            let weather = LSWeather.init(timestamp: 1641571200,
                                         city: "shenzhen",
                                         air: 0,
                                         weaDesc: "晴",
                                         airDesc: "优",
                                         humidity: 1,
                                         uvIndex: 2,
                                         currTem: 3,
                                         highTem: 4,
                                         lowTem: 5,
                                         wea: 6,
                                         airLevel: 7,
                                         pm25: 8,
                                         weatherState: .sunny)
            BleHandler.shared.setWeatherData([weather]).subscribe { value in
                print("设置天气成功", value)
            } onError: { error in
                print("设置天气失败", error)
            }.disposed(by: bag)
            
            BleHandler.shared.unBindDevice().subscribe { value in
                print("恢复出厂", value)
                BleDeviceArchiveModel.delete()
            } onError: { error in
                print("恢复出厂", error)
                BleDeviceArchiveModel.delete()
            }.disposed(by: bag)
            
        case "工厂测试":
            BleHandler.shared.deviceEntersTestMode(mode: .none).subscribe { value in
                print("工厂测试", value)
            } onError: { error in
                print("工厂测试", error)
            }.disposed(by: bag)
        case "获取实时心率":
            BleFacade.shared.connecter.disConnect().subscribe { value in
                print("获取实时心率", value)
            } onError: { error in
                print("获取实时心率", error)
            }.disposed(by: bag)
        case "生成测试数据":
            BleHandler.shared.makeTestData().subscribe { value in
                print("生成测试数据", value)
            } onError: { (err) in
                print("生成测试数据", err)
            }.disposed(by: bag)
            
        case "监听电量":
            
            BleHandler.shared.dataObserver?
            .filter({ arg in
                return arg.type == .electricityUpdate
            })
            .subscribe { value in
                print("value", value)
            } onError: {  _ in
                
            }.disposed(by: bag)
                    
        case "监听蓝牙事件的完成":
            
            BleHandler.shared.dataObserver?.subscribe { _ in
                print("监听蓝牙事件的完成")
            } onError: { (err) in
                print("监听蓝牙事件的完成", err)
            }.disposed(by: bag)
            
        case "04的步数":
            BleHandler.shared.createTestStepsData(year: 2021, month: 12, day: 20)
                .subscribe { value in
                print("04的步数", value)
            } onError: { (err) in
                print("04的步数", err)
            }.disposed(by: bag)
            
        case "04的睡眠":
            BleHandler.shared.createTestSleepingData(year: 2021, month: 12, day: 20)
                .subscribe { value in
                print("04的睡眠", value)
            } onError: { (err) in
                print("04的睡眠", err)
            }.disposed(by: bag)
        case "04的心率":
            
            BleHandler.shared.getHistoryHeartrateData(dateByFar:  Date().addingTimeInterval(-7 * 24 * 60 * 60 ))
                .subscribe { value in
                    print("04的心率", value)
                } onError: { err in
                    print("err", err)
                } onCompleted: {
                    print("onCompleted")
                }.disposed(by: bag)
            
            
            
        case "04的运动":
            BleHandler.shared.createTestHeartRateData(sportType: 0, year: 2021, month: 12, day: 20, hour: 10, min: 10)
                .subscribe { value in
                print("04的运动", value)
            } onError: { (err) in
                print("04的运动", err)
            }.disposed(by: bag)
            
          
            
            
        case "设置运动状态":
            
            BleHandler.shared.updateSportModel(model: 1, state: .start, interval: .m1, speed: 1, flag: 2,  duration: 1, cal: 2, distance: 1, step: 1).subscribe { value in
                print("设置运动状态", value)
            } onError: { (err) in
                print("设置运动状态", err)
            }.disposed(by: bag)
            
        case "查询运动状态":
            
            BleHandler.shared.getSportModelState().subscribe { value in
                print("查询运动状态", value)
            } onError: { (err) in
                print("查询运动状态", err)
            }.disposed(by: bag)
            
        case "获取运动历史数据":
            
            BleHandler.shared.getSportModelHistoryData(datebyFar: Date().addingTimeInterval(-7 * 24 * 60 * 60 )).subscribe { model in
                print("获取运动历史数据", model)
            } onError: { err in
                print("获取运动历史数据", err)
            }.disposed(by: bag)
            
        case "同步步数":
            BleHandler.shared.getStepAfterHistoryData().subscribe { value in
                print("同步步数", value)
            } onError: { error in
                print("同步步数", error)
            }.disposed(by: bag)
        case "查询GPS信息":
            break
        case "设置GPS信息":
            break
        case "检查星历数据是否有效":
            BleHandler.shared.checkBeidouDataInvalte().subscribe { state in
                print("星历数据是否有效", state)
            } onError: { err in
                print("星历数据是否有效", err)
            }.disposed(by: self.bag)
        case "准备升级":
            
            BleHandler.shared.readyUpdateAGPSCommand(type: .beidou)
                .subscribe { state in
                print("准备升级", state)
            } onError: { err in
                print("准备升级", err)
            }.disposed(by: self.bag)
        case "升级星历文件":
            var gpsDatas = [Data]()
            
            gpsDatas.append(try! Data.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Documentationlle_bds", ofType: "lle")!)))
            gpsDatas.append(try! Data.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Documentationlle_gps", ofType: "lle")!)))
            gpsDatas.append(try! Data.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Documentationlle_qzss", ofType: "lle")!)))
            
            gpsTransferManager = Ls02GPSTransferManager.init(binsData: gpsDatas, type: .ephemeris)
            
            gpsTransferManager.start()
                .subscribe { (progressState) in
                    print("progressState", progressState)
//                    switch progressState {
//                    case .progress(let value):
//                        print("progress: \(value)")
//                    default:
//                        print("\(progressState)")
//                    }
                    
                } onError: { (error) in
                    print("start error")
                }
                .disposed(by: self.bag)
            
            
        case "升级年历文件":
            
            var gpsDatas = [Data]()
            
            gpsDatas.append(try! Data.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Documentationgps_alm", ofType: "bin")!)))
            gpsDatas.append(try! Data.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Documentationgln_alm", ofType: "bin")!)))
            
            gpsTransferManager = Ls02GPSTransferManager.init(binsData: gpsDatas, type: .almanac)
            
            gpsTransferManager.start()
                .subscribe { (progressState) in
                    print("progressState", progressState)
                    
                } onError: { (error) in
                    print("start error")
                }
                .disposed(by: self.bag)
        case "获取功能项目":
            BleHandler.shared.dataObserver?.subscribe { (arg) in
                guard arg.type == .functionTag, let val = arg.data as? UTEFunctionTag else {
                    return
                }
                print("value", val)
               
            } onError: { (error) in
                print("异常", error)
            }
            .disposed(by: self.bag)
            
            BleHandler.shared.readValue(channel: .ute33F1)
                
            
        case "获取表盘数据":
            BleHandler.shared.getDialConfigurationInformation().subscribe { value in
                print("获取表盘数据", value)
            } onError: { error in
                print("获取表盘数据", error)
            }.disposed(by: bag)
        case "设置提醒数据":
            BleHandler.shared.configSpo2AndHRWarning(type: .bloodOxygen, min: 2, max: 3).subscribe { value in
                print("设置提醒数据", value)
            } onError: { error in
                print("设置提醒数据", error)
            }.disposed(by: bag)
        case "设置血氧采样间隔":
            BleHandler.shared.setSpo2Detect(enable: .off, intersec: 1).subscribe { value in
                print("设置血氧采样间隔", value)
            } onError: { error in
                print("设置血氧采样间隔", error)
            }.disposed(by: bag)
        case "获取血氧采样间隔":
            BleHandler.shared.getSpo2Detect(enable: .on, intersec: 2).subscribe { value in
                print("获取血氧采样间隔", value)
            } onError: { error in
                print("获取血氧采样间隔", error)
            }.disposed(by: bag)
        case "获取一级排序":
            BleHandler.shared.getMenuConfig(type: 1).subscribe { value in
                print("获取一级排序", value)
            } onError: { error in
                print("获取一级排序", error)
            }.disposed(by: bag)
        case "设置一级排序":
            BleHandler.shared.configMenu(type: 1, count: 2, data: Data()).subscribe { value in
                print("设置一级排序", value)
            } onError: { error in
                print("设置一级排序", error)
            }.disposed(by: bag)
        case "获取手表Log":
            BleHandler.shared.getWatchLog().subscribe { value in
                print("获取手表Log", value)
            } onError: { error in
                print("获取手表Log", error)
            }.disposed(by: bag)
        case "发送App状态":
            BleHandler.shared.setAppStatus(status: .back).subscribe { value in
                print("发送App状态", value)
            } onError: { error in
                print("发送App状态", error)
            }.disposed(by: bag)
            
            
            
        case "升级05S的表盘":
            //Ls05s_2
            let filePath = Bundle.main.path(forResource: "Ls05sFace2", ofType: "bin")
            let watchFaceData = try! Data.init(contentsOf: URL(fileURLWithPath: filePath!))
            self.cloudTransferManagerLS = Ls05sWatchFaceTransferManager.init(binData: watchFaceData, fileType: .dial)
            
            self.cloudTransferManagerLS.start()
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
        case "升级05的表盘":
            guard BleFacade.shared.deviceConnected() else {
                print("设备未连接")
                return
            }
            
            BleHandler.shared.getCloudWatchFaceSetting()
                .subscribe { (cloudWatchFaceSeting) in
                    print("当前表盘编号: \(cloudWatchFaceSeting.watchFaceNo)")                // 升级前可以判断，如果一致就不需要再升级
                    print("宽: \(cloudWatchFaceSeting.watchFaceWidth)")
                    print("高: \(cloudWatchFaceSeting.watchFaceHeight)")
                    print("设备支持最大升级空间: \(cloudWatchFaceSeting.maxSpace)")           // 升级bin 文件大小如果大于最大升级空间， 不应该再升级 ，制作表盘文件时，
                } onError: { (error) in
                    print("clickGetCurrentWatchFaceSeting: \(error)")
                }
                .disposed(by: self.bag)
            
            
            // 1: 需要对比服务器下载表盘资源包的 WatchFaceNo 是否跟 设备当前 WatchFaceNo 一致， 如果一致则不需要更新的设备
            // 2: 需要将服务器下载的资源包大小 和 设备可支持最大升级空间 对比， 如果资源包较大，说明设备没有足够空间存储，放弃更新
            // 3: 从猎声服务器下载的表盘信息 会有： bin文件地址、表盘编号、bin文件大小、预览图、 md5
            guard let watchFacePath = Bundle.main.path(forResource: "WatchFace2", ofType: "bin") else {
                print("资源路径有误")
                return
            }
            do {
                let watchFaceData = try Data(contentsOf: URL(fileURLWithPath: watchFacePath))
                self.cloudTransferManagerUTE = Ls02WatchFaceTransferManager(binData: watchFaceData)
                
                self.cloudTransferManagerUTE.start()
                    .subscribe { (progressState) in
                        print("\(progressState)")

                        switch progressState {
                        case .progress(let value):
                            print("value", value)
                        case .success:
                            print("传输表盘完成")
                        case .notaccept:
                            print("设备不接受传输")
                           
                        case .spaceerror:
                            print("设备空间不足")
                           
                        case .crcerror:
                            print("CRC 校验不通过，停止传输")
                          
                        case .timeout:
                            print("发送数据超时")
                            
                        default:
                            print("其他异常")
                            
                        }

                    } onError: { (error) in
                        print("start error")
                    }
                    .disposed(by: self.bag)
            } catch {
                print("Bin 文件异常")
            }
            
        case "清除连接记录":
            BleDeviceArchiveModel.delete()
            
        case "获取步数历史数据":
            
            
            BleHandler.shared.getHistoryDayData(dateByFar: Date().addingTimeInterval(-7 * 24 * 60 * 60 )).subscribe { model in
                print("获取步数历史数据", model)
            } onError: { err in
                print("err", err)
            }.disposed(by: bag)
            
        case "获取血氧历史数据":
            BleHandler.shared.getHistorySp02Data(dateByFar:  Date().addingTimeInterval(-7 * 24 * 60 * 60 )).subscribe { model in
                print("获取血氧历史数据", model)
            } onError: { err in
                print("err", err)
            }.disposed(by: bag)
            
        case "获取心率历史数据":
            BleHandler.shared.getHistoryHeartrateData(dateByFar: Date().addingTimeInterval(-7 * 24 * 60 * 60 )).subscribe { model in
                print("获取心率历史数据", model)
            } onError: { err in
                print("err", err)
            }.disposed(by: bag)
        case "获取睡眠历史数据":
            BleHandler.shared.getHistorySleepData(dateByFar: Date().addingTimeInterval(-7 * 24 * 60 * 60 )).subscribe { model in
                print("获取睡眠历史数据", model)
            } onError: { err in
                print("err", err)
            }.disposed(by: bag)
            
            
        case "获取每日活动步数":
            break
        case "找手机":
            
            
            BleHandler.shared.dataObserver?
            .filter({ arg in
                return arg.type == .findPhone
            })
            .subscribe { value in
                print("value", value)
            } onError: {  _ in
                
            }.disposed(by: bag)
            
        case "勿扰模式":
            
            
            BleHandler.shared.dataObserver?
            .filter({ arg in
                return arg.type == .disturbSwitch
            })
            .subscribe { value in
                print("value", value)
            } onError: {  _ in
                
            }.disposed(by: bag)
            
        case "运动数据":

            
            BleHandler.shared.dataObserver?
            .filter({ arg in
                return arg.type == .sportHistoryData
            })
            .subscribe { value in
                print("value", value)
            } onError: {  _ in
                
            }.disposed(by: bag)
            
        case "实时步数":
            
            
            BleHandler.shared.dataObserver?
            .filter({ arg in
                return arg.type == .stepUpdate
            })
            .subscribe { value in
                print("value", value)
            } onError: {  _ in
                
            }.disposed(by: bag)
            
        default:
            break
        }
        
    }
    
    
}

extension LSItemFuncTestViewModel {
    
    func bleDataObserver() {
        
        BleHandler.shared.dataObserver?.subscribe(onNext: { data in
            print("bleDataObserver", data)
        }, onError: { e in
            print("bleDataObserver",e)
        }).disposed(by: bag)
        
    }
    
}
