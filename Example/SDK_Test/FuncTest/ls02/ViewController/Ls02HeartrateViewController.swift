//
//  Ls02HeartrateViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/23.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary


class Ls02HeartrateViewController: UIViewController, Storyboardable {

    let bag: DisposeBag = DisposeBag()

    @IBOutlet weak var currentHRLabel: UILabel!
    
    @IBOutlet weak var maxLabel: UILabel!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var avgLabel: UILabel!
    
    @IBOutlet weak var tenMinuterLabel: UILabel!
    
    private var heartRateDatas: [(datetime: String, heartRateDatas: [UInt8])] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.realTimeObserver()
        
        self.statisticsHrObserver()
    }
    
    func realTimeObserver() {
        guard let obser = BleOperator.shared.dataObserver else {
            return
        }
        obser.subscribe { (p) in
            switch p {
            case let (dataType, hrValue) as (Ls02DeviceUploadDataType, UInt8):
                if dataType == .realtimehr {
                    self.currentHRLabel.text = "设备主动上报实时心率: \(hrValue)"
                }
            default :
                print("其他上报数据4")
            }
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
    }
    
    func statisticsHrObserver() {
        guard let obser = BleOperator.shared.dataObserver else {
            return
        }
        obser.subscribe { (p) in
            switch p {
            case let (dataType, statisticValue) as (Ls02DeviceUploadDataType, (datetime: String, max: UInt8, min: UInt8, avg: UInt8)):
                // 实时上报最大值。最小值 、 平均值
                if dataType == .statisticshr {
                    self.maxLabel.text = "\(statisticValue.datetime) 最大值: \(statisticValue.max)"
                    self.minLabel.text = "\(statisticValue.datetime) 最小值: \(statisticValue.min)"
                    self.avgLabel.text = "\(statisticValue.datetime) 平均值: \(statisticValue.avg)"
                }
            case let (dataType, statisticValue) as (Ls02DeviceUploadDataType, (datetime: String, value: UInt8)):
                // 每 10 分钟 上报心率数据
                if dataType == .statistics10Mhr {
                    self.tenMinuterLabel.text = "每10 分钟上报，\(statisticValue.datetime) 值: \(statisticValue.value)"
                }
            default :
                print("其他上报数据5")
            }
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
    }
    
    @IBAction func setHRModel(_ sender: UIButton) {
        
        BleOperator.shared.setHeartRateMeasureMode(settings: .automatic).subscribe { value in
            print("setHRModel", value)
        } onError: { er in
            
        } .disposed(by: bag)

        
    }
    /**
     获取每10 分钟统计一次的 历史数据
     */
    @IBAction func clickHistoryBtn(_ sender: UIButton) {
        self.heartRateDatas.removeAll()
        BleOperator.shared.getHistoryHeartrateData(dateByFar: Date())
            .subscribe(onNext: { (heartRateItem) in
                print("持续接受心率数据")
                self.heartRateDatas.append(heartRateItem)
            }, onError: { (error) in
                print("心率传输过程异常，已收数据无效")
            }, onCompleted: {
                print("心率传输完成 \(self.heartRateDatas.count)")
                // 1: heartRateDatas 表示每 10 分钟采集的数据， 共 12 个元素， 也就是 2 个小时的数据
                // 2: datetime， 表示时间，如： 2022-3-23-16， 表示 heartRateDatas 中的数据是 2022-3-23 14:00:00 到 2022-3-23 16:00:00 之间的数据。
                // 3: 补充第2点， 如果 datetime 为 2022-3-23-00， 表示时间段为  2022-3-22 22:00:00 - 2022-3-23 00:00:00 (22 号的数据)
                self.heartRateDatas.forEach { (hearRateItem) in
                    print("==========hear rate datatime: \(hearRateItem.datetime)")
                    hearRateItem.heartRateDatas.forEach { (value) in
                        print("==========heart reat value: \(value)")             // 0xFF(255)： 表示数据无效
                    }
                }
            })
            .disposed(by: self.bag)
    }
}
