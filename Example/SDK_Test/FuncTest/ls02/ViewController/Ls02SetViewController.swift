//
//  Ls02SetViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/8.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary


class Ls02SetViewController: UIViewController, Storyboardable {
    
    let bag: DisposeBag = DisposeBag()

    private var unit: Ls02Units = .metric
    private var dateFormat: Ls02TimeFormat = .h12
    
    private var reminders: [(index: Int, hour: Int, min: Int, period: UInt8, state: Bool)] = []
    private var tempReminders: [(index: Int, hour: Int, min: Int, period: UInt8, state: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
    }
    
    @IBAction func clickMetricBtn(_ sender: UIButton) {
        self.unit = .metric
        self.setUnitAndDateFormat()
    }
    
    @IBAction func clickImperialBtn(_ sender: UIButton) {
        self.unit = .imperial
        self.setUnitAndDateFormat()
    }
    
    @IBAction func clickH12Btn(_ sender: UIButton) {
        self.dateFormat = .h12
        self.setUnitAndDateFormat()
    }
    
    @IBAction func clickH24Btn(_ sender: UIButton) {
        self.dateFormat = .h24
        self.setUnitAndDateFormat()
    }
    
    @IBAction func clickSyncDateTime(_ sender: UIButton) {
        self.syncDatetime()
    }
    
    @IBAction func clickSetParam(_ sender: Any) {
        self.setDeviceParam()
    }
    
    @IBAction func clickAlertBtn(_ sender: Any) {
        self.setReminder()
    }
}


extension Ls02SetViewController {
    /**
        设置12 & 24 小时显示格式  和  公英制单位
     */
    func setUnitAndDateFormat() {
    
        BleOperator.shared.setDateFormat(unit: self.unit, date: self.dateFormat)
            .subscribe(onNext: { (result) in
                print("setUnitAndDateFormat result: \(result)")
                self.view.makeToast("设置成功", duration: TimeInterval(2), position: .center)
            }, onError: { (error) in
                self.view.makeToast("设置失败", duration: TimeInterval(2), position: .center)
            })
            .disposed(by: self.bag)
    }
    
    /**
     年 月 日  时 分 秒 时区
     */
    func syncDatetime() {
        
        let calendar: Calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        let min = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        
        BleOperator.shared.syncDateTime(year, UInt8(month), UInt8(day), UInt8(hour), UInt8(min), UInt8(second), 8)
            .subscribe { (flag) in
                print("flag \(flag)")
                self.view.makeToast("同步成功", duration: TimeInterval(2), position: .center)
            } onError: { (error) in
                print("error \(error)")
                self.view.makeToast("设置失败", duration: TimeInterval(2), position: .center)
            }
            .disposed(by: self.bag)
    }
    
    /**
     部分参数 要看设备是否支持
     
      设置设备参数
      height:      身高，单位为 cm
      weight:     体重，单位为 kg
      brightScreen： 灭屏时间，单位为秒，最小是 5 秒，最大为 255 秒，小于 5 秒为 5 秒
      stepGoal:  步数目标
      raiseSwitch： 抬手亮屏 开关
      maxHrAlert:  为最大警报心率   范围 100~200，设置为 0xff 代表关闭提醒
      minHrAlert:  为最小警报心率    范围 40~100，设置为 0x00 代表关闭提醒
      age：年龄   范围 1~100
      gender：性别
      lostAlert： 防丢失提醒
      language： 语言
      temperatureUnit： 温度单位设置
      
     */
    func setDeviceParam() {
        BleOperator.shared.setDeviceParameter(175, 77, 10, 2000, .open, 100, 50, 28, .female, .open, .chinese, .f)
            .subscribe { (flag) in
                print("param flag \(flag)")
                self.view.makeToast("设置成功", duration: TimeInterval(2), position: .center)
            } onError: { (error) in
                print("param error \(error)")
                self.view.makeToast("设置失败", duration: TimeInterval(2), position: .center)
            }
            .disposed(by: self.bag)
    }
    
    func setReminder() {
        
        self.reminders = [
            (1, 19, 27, 62, true),    //    7  周一 周二 周三
            (2, 19, 29, 62, true)     //   62  周一 到 周五
        ]
        self.tempReminders = reminders
        
        // 添加 或 更新
        self.addAndEditReminders(self.tempReminders.first!)
        
        // 删除 把对应的state 改为。false
        // self.deleteReminder((1, 19, 27, 62, false))

    }
    
    /**
     reminders
        1: index
        2: hour
        3: min
        4: priod  提醒循环周期，0x01，0x02，0x04，0x08，0x10，0x20,0x40。分别表示 周日  到 周六 ，  0x7f  表示 每天
        5: 表示是否启用
     
     新增 和 更新 要 把所有的reminder 都递归更新到设备
     */
    func addAndEditReminders(_ reminder: (index: Int, hour: Int, min: Int, period: UInt8, state: Bool)) {
        BleOperator.shared.setReminder(reminder)
            .subscribe { (flag) in
                print("addAndEditReminders : \(flag)")
                if self.tempReminders.count > 0 {
                    print("addAndEditReminders remove")
                    self.tempReminders.removeFirst()
                }
                print("addAndEditReminders remove\(self.tempReminders.count)")
                if self.tempReminders.count > 0 {
                    self.addAndEditReminders(self.tempReminders.first!)
                } else {
                    print("addAndEditReminders done")
                }
            } onError: { (error) in
                print("addAndEditReminders error \(error)")
            }
            .disposed(by: self.bag)
    }
    /*
    删除 提醒
    */
    func deleteReminder(_ reminder: (index: Int, hour: Int, min: Int, period: UInt8, state: Bool)) {
        BleOperator.shared.setReminder(reminder)
            .subscribe { (flag) in
                print("deleteReminder success")
            } onError: { (error) in
                print("deleteReminder error \(error)")
            }
            .disposed(by: self.bag)
    }
    
}
