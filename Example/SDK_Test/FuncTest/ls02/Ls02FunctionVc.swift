//
//  Ls02FunctionVc.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/5.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum FuncItem: String {
    case ConnectAndScan = "连接&扫描"
    case BindAndUnBind = "绑定&解绑"
    case UnitAndDateFormat = "设置"
    case DeviceInfo = "设备信息"
    case SportAndSleep = "运动&睡眠"
    case Weather = "天气"
    case AnccNotification = "开关"
    case Heartrate = "心率"
    case CloudWatchFace = "在线表盘"
    case SportsModel = "运动模式"
    case OTA = "升级"
    case ls05sTest = "测试ls05s"
}



class Ls02FunctionVc: UIViewController, Storyboardable {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: Array = [FuncItem.ConnectAndScan, FuncItem.BindAndUnBind, FuncItem.UnitAndDateFormat, FuncItem.DeviceInfo, FuncItem.SportAndSleep, FuncItem.Weather, FuncItem.AnccNotification, FuncItem.Heartrate, FuncItem.SportsModel, FuncItem.CloudWatchFace,  FuncItem.OTA, FuncItem.ls05sTest]
    private static let CellId = "FunctionCell"
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.title = "功能列表"
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: Ls02FunctionVc.CellId)
        self.tableView.rowHeight = 60
    
    }
}

extension Ls02FunctionVc: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.dataSource[indexPath.row] {
        case .ConnectAndScan:
            self.navigationController?.pushViewController(Ls02ConnectAndScanVc.instantiate("L02Function"), animated: true)
        case .BindAndUnBind:
            self.navigationController?.pushViewController(Ls02BindAndUnBindVc.instantiate("L02Function"), animated: true)
        case .UnitAndDateFormat:
            self.navigationController?.pushViewController(Ls02SetViewController.instantiate("L02Function"), animated: true)
        case .DeviceInfo:
            self.navigationController?.pushViewController(Ls02DeviceInfoViewConroller.instantiate("L02Function"), animated: true)
        case .SportAndSleep:
            self.navigationController?.pushViewController(Ls02SportAndSleepViewController.instantiate("L02Function"), animated: true)
        case .Weather:
            self.navigationController?.pushViewController(Ls02WeatherViewController.instantiate("L02Function"), animated: true)
        case .AnccNotification:
            self.navigationController?.pushViewController(Ls02SwitchViewController.instantiate("L02Function"), animated: true)
        case .Heartrate:
            self.navigationController?.pushViewController(Ls02HeartrateViewController.instantiate("L02Function"), animated: true)
        case .CloudWatchFace:
            self.navigationController?.pushViewController(LsCloudWatchFaceViewController.instantiate("L02Function"), animated: true)
        case .SportsModel:
            self.navigationController?.pushViewController(LsSportsModelViewController.instantiate("L02Function"), animated: true)
        case .OTA:
            self.navigationController?.pushViewController(LsYcyOtaViewController.instantiate("L02Function"), animated: true)
        case .ls05sTest:
            self.navigationController?.pushViewController(TestViewController(), animated: true)
        }
    }
}

extension Ls02FunctionVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Ls02FunctionVc.CellId, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = self.dataSource[indexPath.row].rawValue
        return cell
    }
    
}
