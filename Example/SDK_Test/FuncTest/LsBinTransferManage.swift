//
//  LsBinTransferManage.swift
//  Haylou_Fun
//
//  Created by antonio on 2022/1/10.
//  Copyright © 2022 lieSheng. All rights reserved.
//

import Foundation
import RTKOTASDK
import RxCocoa
import RxSwift
import LsBleLibrary

public enum BinUpgradeProcess {
    case success                        // 成功
    case fail                           // 失败
    case progress(_ value: Float)       // 进度条
    case timeout                        // 发送数据超时
    case deviceDisconnect               // 发送数据超时
    case connectFail                    // 连接 OTA 和 DFU 外设失败
    case extractFromBinPathFail         // 提取数据过程异常
    case extractDataEmpty               // 提取数据为空
    case binPathError                   // 资源路径异常
    case bleNotPowerOn                  // 非power on状态
    case deviceNotConnected             // 外设非连接状态
    case transformOtaPreipheralFail                         // 转换ota 外设失败
    case transformDfuPreipheralFail                         // 转换dfu 外设失败
}

public class LsBinTransferManger: NSObject {
    
    private var binDataPath: String!                    // 需要升级的bin 文件
    private var cbPeripheral: CBPeripheral!
    private var protocalType: LSSportWatchSeries!
    
    private var otaPreipheral: RTKOTAPeripheral?
    private var dfuPreipheral: RTKMultiDFUPeripheral?
    private var otaProfile: RTKOTAProfile!
    private var upgradeResource: [RTKOTAUpgradeBin] = []
    
    public init(cbPeripheral: CBPeripheral, binDataPath: String, protocalType: LSSportWatchSeries) {
        super.init()
        self.cbPeripheral = cbPeripheral
        self.binDataPath = binDataPath
        self.protocalType = protocalType
        self.otaProfile = RTKOTAProfile.init()
        self.otaProfile.delegate = self
    }
    
    // 信号中转器，功能： 监听 cell 的点击，信号转发到外部
    typealias RouterAction = (
        progress: PublishRelay<BinUpgradeProcess>, ()
    )
    
    private let progressAction: RouterAction = (
        PublishRelay(), ()
    )
    
    typealias Routing = (
        event: Observable<BinUpgradeProcess>, ()
    )
    
    lazy var progressEvent: Routing = (
        event: progressAction.progress.asObservable(), ()
    )
    
    public func start() -> Observable<BinUpgradeProcess> {
        startUpgrade()
        return progressEvent.event
    }
    
    deinit {
        print("LsBinTransferManger deinit")
    }
    
    private func startUpgrade() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard self.cbPeripheral.state == .connected else {
                self.progressAction.progress.accept(.deviceNotConnected)
                return
            }
            self.otaPreipheral = self.otaProfile.otaPeripheral(from: self.cbPeripheral)
            guard let p = self.otaPreipheral else {
                self.progressAction.progress.accept(.transformOtaPreipheralFail)
                return
            }
            self.otaProfile.connect(to: p)
        }
    }
}

extension LsBinTransferManger : RTKMultiDFUPeripheralDelegate {
    
    public func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didFinishWithError err: Error?) {
        if err != nil {
            progressAction.progress.accept(.fail)
        } else {
            progressAction.progress.accept(.success)
        }
    }
    
    public func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didSend length: UInt, totalToSend totalLength: UInt) {
        print("length: \(length); total: \(totalLength)")
        let progress: Float = Float(length) / (Float(totalLength))
        progressAction.progress.accept(.progress(progress))
    }
}

extension LsBinTransferManger : RTKLEProfileDelegate {
    
    public func profileManagerDidUpdateState(_ profile: RTKLEProfile) {
        print("蓝牙状态变更: \(profile.centralManager.state.rawValue)")
    }
    
    public func profile(_ profile: RTKLEProfile, didDisconnectPeripheral peripheral: RTKLEPeripheral, error: Error?) {
        progressAction.progress.accept(.deviceDisconnect)
    }
    
    public func profile(_ profile: RTKLEProfile, didFailToConnect peripheral: RTKLEPeripheral, error: Error?) {
        progressAction.progress.accept(.connectFail)
    }
    
    public func profile(_ profile: RTKLEProfile, didConnect peripheral: RTKLEPeripheral) {
        if peripheral == otaPreipheral {
            // 准备数据
            prepareData()
            // 转换 dfu
            if protocalType == .LS {
                transformLSDfuPeripheral()
            }else {
                transformUTEDfuPeripheral()
            }
            
        } else if peripheral == dfuPreipheral {
            dfuPreipheral?.upgradeImages(upgradeResource, inOTAMode: false)
        }
    }
    
    
    public func transformLSDfuPeripheral() {
        
        otaProfile.translate(otaPreipheral!) { [unowned self] bool, error, peripheral in
            print("transformDfuPeripheral",bool, error ?? "", peripheral as Any)
            guard bool, error == nil else {
                progressAction.progress.accept(.transformDfuPreipheralFail)
                return
            }
            
            self.dfuPreipheral = peripheral as? RTKMultiDFUPeripheral
            
            let data = "3130303076733530736C756F6C7961483130303076733530736C756F6C796148".hexToData
            self.dfuPreipheral?.setEncryptKey(data)
            self.dfuPreipheral?.delegate = self
            self.otaProfile.connect(to: self.dfuPreipheral!)
            
        }
        
    }
    
    public func transformUTEDfuPeripheral() {
        guard let dfuPeripheral = otaProfile.dfuPeripheral(of: otaPreipheral!) as? RTKMultiDFUPeripheral  else {
            progressAction.progress.accept(.transformDfuPreipheralFail)
            return
        }
        
        let data = "4e46f8c5095554455f524b0cd1f610fb1f6763df807a7e70960d4cd3118e601a".hexToData
        dfuPeripheral.setEncryptKey(data)
        dfuPeripheral.delegate = self
        otaProfile.connect(to: dfuPeripheral)
        dfuPreipheral = dfuPeripheral
    }
    
    
    public func prepareData() {
        guard !binDataPath.isEmpty else {
            progressAction.progress.accept(.binPathError)
            print("资源路径有误")
            return
        }
        do {
            let resources = try RTKOTAUpgradeBin.imagesExtracted(fromMPPackFilePath: binDataPath)
            if otaPreipheral!.activeBank == RTKOTABankTypeSingle {
                upgradeResource = resources.filter({ $0.upgradeBank == .unknown || $0.upgradeBank == .singleOrBank0 })
            } else if otaPreipheral!.activeBank == RTKOTABankTypeBank0 {
                upgradeResource = resources.filter({ $0.upgradeBank == .unknown || $0.upgradeBank == .bank1 })
            } else {
                upgradeResource = resources
            }
            guard upgradeResource.count > 0 else {
                print("提取数据为空")
                progressAction.progress.accept(.extractDataEmpty)
                return
            }
            if upgradeResource.count == 1 && !upgradeResource.last!.icDetermined {
                upgradeResource.last!.assertAvailable(for: otaPreipheral!)
            }
            print("OTA资源数： \(upgradeResource.count)")
        } catch  {
            progressAction.progress.accept(.extractFromBinPathFail)
            print("提取数据出错")
        }
    }
}

