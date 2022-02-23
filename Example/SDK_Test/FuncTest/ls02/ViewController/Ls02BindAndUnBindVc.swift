//
//  Ls02BindAndUnBindVc.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/5.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit

import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary

class Ls02BindAndUnBindVc: UIViewController, Storyboardable {
    
    let bag: DisposeBag = DisposeBag()
    
    var previousBindState: LsBleBindState?
    var bindState: LsBleBindState?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "绑定&解绑"
        
        bindObserver()
    }
    
    @IBAction func clickBindDeviceBtn(_ sender: UIButton) {
        let userId = 11272025  //11272014
        self.bindDevice(userId)
    }
    
    /**
     解绑 无数据返回， 会直接重启
     */
    @IBAction func clickUnBindDeviceBtn(_ sender: UIButton) {
        BleHandler.shared.unBindDevice()
            .subscribe(onError: { (error) in
                switch error {
                case BleError.disConnect:
                    print("解绑完成(重置)")
                    self.view.makeToast("解绑完成(重置)", duration: TimeInterval(4), position: .center)
                default:
                    print("unbind error: \(error)")
                }
            })
            .disposed(by: self.bag)
    }
    
    /**
        业务：
        a: 如发送的UserId 与 设备上UserId 一致或者userId 不存在， 直接绑定成功
        b: 如发送的UserId 与 设备上UserId 不一致， 设备会重启， 需要重启后重连
     */
    func bindDevice(_ userId: Int) {
        
        BleHandler.shared.bindDevice(userId: UInt32(userId))
            .subscribe { (value) in
                print("state: \(value)")
                self.previousBindState = self.bindState
                self.bindState = value.bindStatus
                
                if value.bindStatus == .success {
                    print("绑定完成")
                    self.view.makeToast("绑定完成", duration: TimeInterval(4), position: .center)
                }
            } onError: { (e) in
                
                print("绑定状态: \(e)")
                
                switch e {
                case BleError.disConnect:
                    print("bind device disConnect error")
                    guard let state = self.bindState, let previousState = self.previousBindState else {
                        return
                    }
                    // 用户点击了确认， 设备需要重启断开，需要重连
                    if state == .confirm && (previousState == .timeout) {
                        print("设备会重启，2秒后再重连")
                    }
                default:
                    print("绑定失败: \(e)")
                }
            }
            .disposed(by: self.bag)
    }
    
    func bindObserver() {
        guard let obser = BleHandler.shared.dataObserver else {
            return
        }
        obser.subscribe { (p) in
          print("bindObserver",p)
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
    }
}
