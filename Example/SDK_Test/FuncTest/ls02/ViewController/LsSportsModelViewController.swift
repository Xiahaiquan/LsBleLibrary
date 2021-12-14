//
//  LsSportsModelViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/30.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary


class LsSportsModelViewController: UIViewController, Storyboardable {

    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 监听数据返回， 如 用户点击暂停、恢复等
        self.sportingModelObserver()
    }
    
    var durationTimer: Timer?                                           // 定时向设备更新运动数据【只有手表发起运动时才这样做】
    var sportModelDuration: Int = 0                                     // 运动的总时长【暂停不计入】
    var sportModel: SportModel = SportModel.none                        // 当前开启的运动模式 如： 跑步、骑行等
    var sportModelState: SportModelState = SportModelState.start        // 当前运动模式的状态，如： 开、关 、暂停、 继续
    var saveInterval: SportModelSaveDataInterval = .s10

    /**
     获取设备当前运动模式， 和运动状态
     */
    @IBAction func getSportModelAndState(_ sender: UIButton) {
        BleOperator.shared.getSportModelState()
            .subscribe { (state, model) in
                print("状态: \(state)  运动模式:\(model)")
                self.view.makeToast("状态: \(state)  运动模式:\(model)", duration: TimeInterval(2), position: .center)
            } onError: { (error) in
                print("获取运动状态出错: \(error)")
            }
            .disposed(by: self.bag)
    }
    
    /**
        手机端主动开启运动
        1: 设备端主动开启运动时， 手表会实时上报 步数和心率
        2: 手机端 计算上报的 运动时长、 距离、配速、卡路里 写入到 设备端，（运动时长等数据，设备只负责显示）
     */
    @IBAction func clickStartSportModel(_ sender: UIButton) {
        
        // 假定用户UI上选择  【开启-跑步-10秒统计一次】
        self.sportModel = SportModel.running
        self.saveInterval = .s10
        
        // 手机端主动开启运动模式。（设备端发起时没有） 设备端会返回运动数据
        BleOperator.shared.startSportModel(model:self.sportModel, state: .start, interval: self.saveInterval)
            .subscribe { (model) in
                print("开始运动模式:\(model)")
                
                // 倒计时 3 秒
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.invalidateDurationTimer()
                    self.startCalculate()
                }
            } onError: { (error) in
                print("开始运动模式: \(error)")
            }
            .disposed(by: self.bag)
    }
    
    /**
        定时将设备上传的步数，计算出其他数据，并将计算结果同步到设备
     */
    func startCalculate() {
        self.addDurationTimer(timeOutInterval: 1, repeats: true) {
            if self.sportModelState != .suspend && self.sportModelState != .stop {
                self.sportModelDuration = self.sportModelDuration + 1
                
                print("运动时长： \(self.sportModelDuration)")
                //（app 自己计算距离 和卡路里 并发送到设备）卡路里 和距离 动态计算
                BleOperator.shared.updateSportModel(model:self.sportModel, state: .continued, interval: .s10,  speed: 0, flag: 0, senond: 0,duration: self.sportModelDuration, cal: 10, distance: 1200, step: 0)
                    .subscribe { (value) in
                        print("更新数据成功", value)
                    } onError: { (error) in
                        print("更新数据失败: \(error)")
                    }
                    .disposed(by: self.bag)
            }
        }
    }
    
    /**
     运动时 数据 和状态 会主动上报， 需要监听上报事件
     */
    func sportingModelObserver() {
        guard let obser = BleOperator.shared.dataObserver else {
            return
        }
        obser.subscribe { (p) in
            switch p {
            case let (dataType, sportInfo) as (Ls02DeviceUploadDataType, (model: SportModel, hr: Int, cal: Int, pace: Int, step: Int, count: Int, distance: Int)):
                if dataType == .sportmodeling {
                    print("\(sportInfo.model) 运动模式下 步数：\(sportInfo.step) 心率: \(sportInfo.hr)")
                }
            case let (dataType, sportInfo) as (Ls02DeviceUploadDataType, (model: SportModel, state: SportModelState, interval: SportModelSaveDataInterval, step: Int, cal: Int, distance: Int, pace: Int)):
                if dataType == .sportmodestatechange {
                    // 设备 运动状态变更  如： 暂停 恢复
                    self.sportModelState = sportInfo.state
                    print("运动模式: \(sportInfo.model)  状态 ：\(sportInfo.state) ")
                }
            case let (dataType, hrValue) as (Ls02DeviceUploadDataType, UInt8):
                if dataType == .realtimehr {
                    print("设备主动上报实时心率:", hrValue)
                }
            case let (dataType, statisticValue) as (Ls02DeviceUploadDataType, (datetime: String, max: UInt8, min: UInt8, avg: UInt8)):
                // 实时上报最大值。最小值 、 平均值
                if dataType == .statisticshr {
                    
                    print("\(statisticValue.datetime) 最大值: \(statisticValue.max)", "\(statisticValue.datetime) 平均值: \(statisticValue.avg)", "\(statisticValue.datetime) 最小值: \(statisticValue.min)")
                    
                }
            default :
                print("其他上报数据3")
            }
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
    }
    
    /**
        获取指定时间后产生的历史数据
     */
    @IBAction func getSportModelHistoryData(_ sender: Any) {
        BleOperator.shared.getSportModelHistoryData(datebyFar: Date())
            .subscribe { (models) in
                print("运动历史记录 记录数:\(models.count)")
                print("\(models)")
                var detail: String = ""
                models.forEach { (item) in
                    detail += "[模式: \(item.sportModel); 时间：\(item.startTime); 步数：\(item.step)];"
                }
                if detail.count > 0 {
                    self.view.makeToast(detail, duration: TimeInterval(5), position: .center)
                }
            } onError: { (error) in
                print("获取运动数据记录: \(error)")
            }
            .disposed(by: self.bag)
    }
    
    //MARK: 暂停运动
    @IBAction func clickPauseBtn(_ sender: UIButton) {
        // （app 自己计算距离 和卡路里 并发送到设备）卡路里 和距离 动态计算
        BleOperator.shared.updateSportModel(model:self.sportModel, state: .suspend, interval: .s10,  speed: 0, flag: 0, senond: 0,duration: self.sportModelDuration, cal: 20, distance: 1300, step: 0)
            .subscribe { (_) in
                print("暂停运动 完成")
                self.sportModelState = .suspend
            } onError: { (error) in
                print("暂停运动 出错: \(error)")
            }
            .disposed(by: self.bag)
    }
    
    //MARK: 继续运动
    @IBAction func clickResumeBtn(_ sender: UIButton) {
        // // （app 自己计算距离 和卡路里 并发送到设备）卡路里 和距离 动态计算
        BleOperator.shared.updateSportModel(model:self.sportModel, state: .resume, interval: .s10,  speed: 0, flag: 0, senond: 0,duration: self.sportModelDuration, cal: 30, distance: 1400, step: 0)
            .subscribe { (_) in
                print("继续运动")
                self.sportModelState = .continued

            } onError: { (error) in
                print("继续运动 出错: \(error)")
            }
            .disposed(by: self.bag)
    }
    
    //MARK: 停止运动
    @IBAction func clickSoptBtn(_ sender: UIButton) {
        BleOperator.shared.startSportModel(model:self.sportModel, state: .stop, interval: self.saveInterval)
            .subscribe { (model) in
                print("结束运动模式:\(model)")
                self.sportModelState = .stop
                self.invalidateDurationTimer()  //停止更新数据的定时器
            } onError: { (error) in
                print("结束运动模式: \(error)")
            }
            .disposed(by: self.bag)
    }
}

extension LsSportsModelViewController {
    
    func addDurationTimer(timeOutInterval:TimeInterval, repeats: Bool,  timerBlock: @escaping (() -> Void)) {
        self.durationTimer = Timer.init(timeInterval: timeOutInterval, repeats: repeats, block: { (timer) in
            timerBlock()
        })
//        RunLoop.current.add(self.durationTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func invalidateDurationTimer() {
        if self.durationTimer != nil {
            self.durationTimer?.invalidate()
            self.durationTimer = nil
        }
    }
}
