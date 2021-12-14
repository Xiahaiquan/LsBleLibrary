//
//  LsYcyViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/4/10.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import RTKOTASDK
import RxCocoa
import RxSwift
import LsBleLibrary


/**
 
 1: 用已连接的设备信息， 重新获取一个 ota 的 CentralManager 和 Peripheral 对象
 2: 用新对象过滤支持的升级数据
 */

class LsYcyOtaViewController: UIViewController, Storyboardable {
    
    @IBOutlet weak var clickStartBtn: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    let bag: DisposeBag = DisposeBag()
    
//    var binTransferManager: LsBinTransferManger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "OTA"
    }
    
    deinit {
        print("LsYcyOtaViewController deinit")
    }
    
    @IBAction func clickStartBtn(_ sender: UIButton) {
        
        // 从服务器下载的资源路径
        guard let binPath = Bundle.main.path(forResource: "Ls05_2", ofType: "bin") else {
            print("资源路径有误")
            return
        }
        
//        self.binTransferManager = LsBinTransferManger(cbPeripheral: (BleFacade.shared.bleDevice?.peripheral!)!, binDataPath: binPath)

//        self.binTransferManager.start()
//            .subscribe { (progressState) in
//                switch progressState {
//                case .progress(let value):
//                    self.progressView.progress = value
//                case .success:
//                    print("数据传输完成, 设备正在重启")
//                    self.view.makeToast("数据传输完成, 设备正在重启", duration: TimeInterval(2), position: .center)
//                case .deviceDisconnect:
//                    print("蓝牙连接断开")
//                    self.view.makeToast("蓝牙连接断开", duration: TimeInterval(2), position: .center)
//                case .connectFail:
//                    print("连接失败")
//                    self.view.makeToast("连接失败", duration: TimeInterval(2), position: .center)
//                case .extractFromBinPathFail:
//                    print("从路径中提取数据失败")
//                    self.view.makeToast("从路径中提取数据失败", duration: TimeInterval(2), position: .center)
//                case .extractDataEmpty:
//                    print("提取数据为空")
//                    self.view.makeToast("提取数据为空", duration: TimeInterval(2), position: .center)
//                case .binPathError:
//                    print("资源路径不对，检查路径是否正确")
//                    self.view.makeToast("资源路径不对，检查路径是否正确", duration: TimeInterval(2), position: .center)
//                case .bleNotPowerOn:
//                    print("蓝牙开关状态 非 PowerOn")
//                    self.view.makeToast("蓝牙开关状态 非 PowerOn", duration: TimeInterval(2), position: .center)
//                case .deviceNotConnected:
//                    print("传入的外设对象 未连接")
//                    self.view.makeToast("传入的外设对象 未连接", duration: TimeInterval(2), position: .center)
//                case .transformOtaPreipheralFail:
//                    print("传入外设对象转换为OTA 外设失败")
//                    self.view.makeToast("传入外设对象转换为OTA 外设失败", duration: TimeInterval(2), position: .center)
//                case .transformDfuPreipheralFail:
//                    print("OTA 外设对象转换为DFU 外设失败")
//                    self.view.makeToast("OTA 外设对象转换为DFU 外设失败", duration: TimeInterval(2), position: .center)
//                default:
//                    print("升级失败")
//                    self.view.makeToast("升级失败", duration: TimeInterval(2), position: .center)
//                }
//            } onError: { (error) in
//                print("未知错误:\(error)")
//            }.disposed(by: self.bag)
        
    }
}
