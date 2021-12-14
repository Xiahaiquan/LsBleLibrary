//
//  Ls02AnccViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/22.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary



class Ls02SwitchViewController: UIViewController, Storyboardable {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "开关设置"
    }
    
    let bag: DisposeBag = DisposeBag()
    
    @IBAction func switchStatus(_ sender: Any) {
        BleOperator.shared.requesFunctionStatus().subscribe { value in
            print(value)
            print("switchStatus",value)
        } onError: { e in
            
        } .disposed(by: bag)

    }
    @IBAction func quickSwitchSetting(_ sender: Any) {
        
        BleOperator.shared.requestQuickFunctionSetting().subscribe { value in
            print(value)
            print("quickSwitchSetting",value)
        } onError: { e in
            
        }.disposed(by: bag)

        
    }
    @IBAction func clickAnccNotificationBtn(_ sender: UIButton) {
        BleOperator.shared.setANCCItemSwitch(.instagram, .close)
            .subscribe { (flag) in
                print("ancc  \(flag)")
            } onError: { (error) in
                print("param error \(error)")
            }
            .disposed(by: self.bag)
    }
    
    
    @IBAction func clickNotDBtn(_ sender: UIButton) {
        
        // 子开关，
        let screenEnable: Bool = false               // 屏幕勿打扰 是否开启
        let shockEnable: Bool = true               // 震动勿打扰 是否开启
        let messageEnable: Bool = false              // 消息勿打扰 是否开启
        let callEnable: Bool = false                // 来电勿打扰 是否开启
        
        // 开关状态，开始时  开始分钟  结束时 结束分钟 子开关
        //
        BleOperator.shared.setNotDisturb(.open, 12, 0, 14, 0, (screenEnable, shockEnable, messageEnable, callEnable))
            .subscribe { (flag) in
                print("setNotDisturb  \(flag)")
            } onError: { (error) in
                print("param error \(error)")
            }
            .disposed(by: self.bag)
    }

    @IBAction func enterFactoryTest(_ sender: Any) {
        

        BleOperator.shared.deviceEntersTestMode(mode: .screenOff).subscribe { status in
            print("enterFactoryTest", status)
        } onError: { er in
            
        } .disposed(by: bag)

    }
}
