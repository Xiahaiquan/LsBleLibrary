//
//  Ls02DeviceInfoViewConroller.swift
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


class Ls02DeviceInfoViewConroller: UIViewController, Storyboardable {

    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备信息"
        
    }
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBAction func clickGetMacAddress(_ sender: Any) {
        BleOperator.shared.getMacAddress()
            .subscribe { (macAddress) in
                print("mac Address:\(macAddress)")
                self.view.makeToast("mac地址: \(macAddress)", duration: TimeInterval(4), position: .center)
            } onError: { (error) in
                print("error")
            }
            .disposed(by: self.bag)

    }
    
    @IBAction func clickGetVersion(_ sender: Any) {
        BleOperator.shared.getDeviceVersion()
            .subscribe { (deviceVersion) in
                print("device version: \(deviceVersion)")
                self.view.makeToast("设备版本: \(deviceVersion)", duration: TimeInterval(4), position: .center)
            } onError: { (error) in
                print("error")
            }
            .disposed(by: self.bag)
    }
    
    @IBAction func clickGetPower(_ sender: Any) {
        BleOperator.shared.getDeviceBattery()
            .subscribe { (deviceVersion) in
                print("battery : \(deviceVersion)")
                self.view.makeToast("设备电量: \(deviceVersion)", duration: TimeInterval(4), position: .center)
            } onError: { (error) in
                print("Battery error")
            }
            .disposed(by: self.bag)
    }
    
    /**
     获取可用功能标志位，是被动监听， 要先确保连接状态执行 read
     */
    @IBAction func clickGetFunctionTag(_ sender: Any) {
        self.functionTagValueObserver()
    }
    
    func functionTagValueObserver() {
        guard BleFacade.shared.deviceConnected() else {
            return
        }
        guard let obser = BleOperator.shared.dataObserver else {
            return
        }
        obser.subscribe { [weak self] (value) in
            
            guard let p = value.ute else {
                return
            }
            
            
            switch p {
            case let (_, functionTag) as (Ls02DeviceUploadDataType, FunctionTag):
                
                let result = "NFC: \(functionTag.NFC); 自定义数据格式传输：\(functionTag.CustomDataTransfer); 血氧:\(functionTag.bloodOxygen); GPS: \(functionTag.GPS)"
                
                print("功能标志位", result)
                
                
                self?.resultLabel.text = result
            default :
                print("其他上报数据6")
            }
        } onError: { (error) in
            print("发生错误：\(error)")
        }
        .disposed(by: self.bag)
        // 查看33161查看功能标志位
        BleFacade.shared.readValue(type: 33161)
    }
    
}
