//
//  Ls02SportAndSleepViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/16.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary


class Ls02SportAndSleepViewController: UIViewController, Storyboardable {
    
    let bag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var realTimeSportLabel: UILabel!
    
    private var sportDatas: [Ls02SportInfo] = []
    
    @IBOutlet weak var detaiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "运动&睡眠"
        
        self.realTimeObserver()
    }
    
    @IBAction func getCurerntStep(_ sender: Any) {
        BleHandler.shared.requestRealtimeSteps().subscribe { value in
            print("current", value)
        } onError: { e in
            
        }.disposed(by: bag)

    }
    /**
     获取运动， 历史数据， 传入年月日时，则只返回该时间后产生的数据
     */
    @IBAction func clickGetSport(_ sender: UIButton) {
        self.sportDatas.removeAll()
                
        BleHandler.shared.getHistoryDayData(dateByFar: Date().addingTimeInterval(-7 * 24 * 60 * 60))
            .subscribe(onNext: { (sportData) in
                print("持续接受数据")
                self.sportDatas.append(sportData)
            }, onError: { (error) in
                print("数据传输过程异常， 已收数据无效")
            }, onCompleted: {
                print("数据传输完成 ")
                var sportMsg = ""
                self.sportDatas.forEach { (sport) in
                    print("step: \(sport.totalStep)")
                    sportMsg = sportMsg + "[时间：\(sport.year):\(sport.month):\(sport.day):\(sport.hour) 开始: \(sport.runStart); 结束: \(sport.runEnd); 步数： \(sport.runStep); ]"
                }
                self.detaiLabel.text = "\(sportMsg)"
            })
            .disposed(by: self.bag)
    }
    
    /**
     运动时 数据会主动上报， 需要监听上报事件
     */
    func realTimeObserver() {
        guard let obser = BleHandler.shared.dataObserver else {
            return
        }
        obser.subscribe { (p) in
            switch p {
            case let (dataType, sportInfo) as (Ls02DeviceUploadDataType, Ls02SportInfo):
                self.realTimeSportLabel.text = "数据类型: \(dataType), 运动总数据: \(sportInfo.totalStep)"
                //print("年: \(year) 月: \(month) 日: \(day) 时: \(hour) ")
                //print("总步数: \(totalStep)")
                //print("开始跑步时：\(runStart) 结束跑步时：\(runEnd) 跑步时长:\(runDuration) 跑步数: \(runStep)")
                //print("开始走路时：\(walkStart) 结束走路时：\(walkEnd) 走路时长:\(walkDuration) 走路步数: \(walkStep)")
            default :
                print("其他上报数据7")
            }
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
    }
    
    
    /**
     获取睡眠历史数据数据
     */
    @IBAction func clickGetSleepBtn(_ sender: Any) {
        BleHandler.shared.getHistorySleepData(dateByFar: Date())
            .subscribe(onNext: { (sleepData) in
                print("持续接受数据")
                var sleepMsg = ""
                sleepData.forEach { (info) in
                    info.sleepItems.forEach { (item) in
                        sleepMsg = sleepMsg +  "\(info.year)年\(info.month)月\(info.day)日 共有 \(info.dataCount) 条数据"
                        print("开始时：\(item.startHour) 开始分：\(item.startMin) 睡眠类型： \(item.state) 睡眠时长：\(item.sleepDuration)")
                    }
                }
                self.detaiLabel.text = "\(sleepMsg)"
            }, onError: { (error) in
                print("数据传输过程异常， 已收数据无效")
            }, onCompleted: {
                print("数据传输完成")
            })
            .disposed(by: self.bag)
    }
    
}
