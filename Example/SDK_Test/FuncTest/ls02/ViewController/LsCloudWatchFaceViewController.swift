//
//  LsCloudWatchFaceViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/30.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary

public class LsCloudWatchFaceViewController: UIViewController, Storyboardable {

    let bag: DisposeBag = DisposeBag()
    
    private var watchFaceNo: Int = 0
    private var maxSpace: Int = 0
                
    @IBOutlet weak var progressView: UIProgressView!
    
//    var cloudTransferManager: Ls02WatchFaceTransferManager!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("LsCloudWatchFaceViewController deinit")
    }
    
    /**
     获取设备上在线表盘信息
     */
    @IBAction func clickGetCurrentWatchFaceSeting(_ sender: UIButton) {
        BleOperator.shared.getCloudWatchFaceSetting()
            .subscribe { (cloudWatchFaceSeting) in
                print("当前表盘编号: \(cloudWatchFaceSeting.watchFaceNo)")                // 升级前可以判断，如果一致就不需要再升级
                print("宽: \(cloudWatchFaceSeting.watchFaceWidth)")
                print("高: \(cloudWatchFaceSeting.watchFaceHeight)")
                print("设备支持最大升级空间: \(cloudWatchFaceSeting.maxSpace)")           // 升级bin 文件大小如果大于最大升级空间， 不应该再升级 ，制作表盘文件时，
                
                self.view.makeToast("编号：\(cloudWatchFaceSeting.watchFaceNo)", duration: TimeInterval(2), position: .center)

                self.watchFaceNo = cloudWatchFaceSeting.watchFaceNo
                self.maxSpace = cloudWatchFaceSeting.maxSpace
            } onError: { (error) in
                print("clickGetCurrentWatchFaceSeting: \(error)")
            }
            .disposed(by: self.bag)
        
    }
    
    @IBAction func clickSetCloudWatchFace(_ sender: UIButton) {
        
        guard BleFacade.shared.deviceConnected() else {
            print("设备未连接")
            return
        }
        // 1: 需要对比服务器下载表盘资源包的 WatchFaceNo 是否跟 设备当前 WatchFaceNo 一致， 如果一致则不需要更新的设备
        // 2: 需要将服务器下载的资源包大小 和 设备可支持最大升级空间 对比， 如果资源包较大，说明设备没有足够空间存储，放弃更新
        // 3: 从猎声服务器下载的表盘信息 会有： bin文件地址、表盘编号、bin文件大小、预览图、 md5
        guard let watchFacePath = Bundle.main.path(forResource: "WatchFace2", ofType: "bin") else {
            print("资源路径有误")
            return
        }
        do {
            
            let watchFaceData = try Data(contentsOf: URL(fileURLWithPath: watchFacePath))
//            self.cloudTransferManager = Ls02WatchFaceTransferManager(binData: watchFaceData)
            
//            self.cloudTransferManager.start()
//                .subscribe { (progressState) in
//                    print("\(progressState)")
//
//                    switch progressState {
//                    case .progress(let value):
//                        self.progressView.progress = value
//                    case .success:
//                        print("传输表盘完成")
//                        self.view.makeToast("传输表盘完成", duration: TimeInterval(2), position: .center)
//                    case .notaccept:
//                        print("设备不接受传输")
//                        self.view.makeToast("设备不接受传输", duration: TimeInterval(2), position: .center)
//                    case .spaceerror:
//                        print("设备空间不足")
//                        self.view.makeToast("设备空间不足", duration: TimeInterval(2), position: .center)
//                    case .crcerror:
//                        print("CRC 校验不通过，停止传输")
//                        self.view.makeToast("CRC 校验不通过，停止传输", duration: TimeInterval(2), position: .center)
//                    case .timeout:
//                        print("发送数据超时")
//                        self.view.makeToast("发送数据超时", duration: TimeInterval(2), position: .center)
//                    default:
//                        print("其他异常")
//                        self.view.makeToast("其他异常", duration: TimeInterval(2), position: .center)
//                    }
//
//                } onError: { (error) in
//                    print("start error")
//                }
//                .disposed(by: self.bag)
        } catch {
            print("Bin 文件异常")
        }
    }
}

