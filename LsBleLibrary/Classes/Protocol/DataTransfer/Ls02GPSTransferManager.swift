//
//  Ls02GPSTransferManager.swift
//  LsBleLibrary
//
//  Created by antonio on 2022/1/5.
//

import Foundation
import RxCocoa
import RxSwift

public enum GPSDataType {
    case ephemeris //星历数据
    case almanac //年历数据
}
 
public class Ls02GPSTransferManager {
    
    private var GPSType:GPSDataType = .ephemeris
    
    private var writeMaxValue: Int = 128        //每一包可发送的最大字节数 （默认 128 - 3 个头字节）
    private let waitPointLenght = 2048
    private var serialNo: Int = 0               //发送的编号
    private let timeInterval = TimeInterval(80/100)
    
    private var packageTotal = 0
    private var packageCurrent = 0
    
    private var writeDataSuspend: Bool = false  //暂停递归发送数据
    private var suspendCount: Int = 1
    
    private var binsData: [Data]!                  // 需要升级的bin 文件数据
    private var splitDataArray: [Data] = []       //按 mtu 切分好的数据
    
    private let bag: DisposeBag = DisposeBag()
    
    var syncAGPSDataTimer: Timer?
    
    public init(binsData: [Data], type: GPSDataType) {
        self.binsData = binsData
        self.GPSType = type
        
        for items in binsData {
            let splitCount = items.count / writeMaxValue
            let lastLeft = items.count % writeMaxValue
            
            packageTotal += splitCount
            packageTotal += (lastLeft > 0 ? 1 : 0)
            print("packageTotal", packageTotal)
        }
        
        self.gpsUpgradeValueObserver()
    }
    
    deinit {
        printLog("Ls02GPSTransferManager deinit")
    }
    
    // 信号中转器，功能： 监听 cell 的点击，信号转发到外部
    typealias RouterAction = (
        progress: PublishRelay<CloudWatchFaceProcess>, ()
    )
    
    private let progressAction: RouterAction = (
        PublishRelay(), ()
    )
    
    typealias Routing = (
        event: Observable<CloudWatchFaceProcess>, ()
    )
    
    lazy var progressEvent: Routing = (
        event: progressAction.progress.asObservable(), ()
    )
    
    public func start() -> Observable<CloudWatchFaceProcess> {
        self.requestCloudWatchFaceTransfer()
        return progressEvent.event
    }
    
    func requestCloudWatchFaceTransfer() {
        
        BleHandler.shared.checkBeidouDataInvalte()
            .do { [unowned self] _ in
                self.splitData(data: self.binsData.first!, mtu: self.writeMaxValue)
            }
            .flatMap({ [unowned self] _ ->Observable<Ls02ReadyUpdateAGPSStatus> in
                if self.GPSType == .ephemeris {
                    return BleHandler.shared.readyUpdateAGPSCommand(type: .beidou)
                }
                return BleHandler.shared.readyUpdateAGPSCommand(type: .gps)
            })
            .subscribe { [unowned self] (state) in
                print("设备接受传输:", state)
                
                switch state {
                case .ready:
                    self.writeDataSuspend = false
                    self.createSendAGPSDataTimer()
                default:
                    break
                }
            } onError: {[weak self] (error) in
                print("设备不接受传输，请检查是否已存在或空间是否足够")
                self?.progressAction.progress.accept(.notaccept)
            }
            .disposed(by: self.bag)
    }
    
    func gpsUpgradeValueObserver() {
        guard let obser = Ble02Operator.shared.dataObserver else {
            return
        }
        obser.subscribe { [unowned self] (arg) in
            
            if arg.type != .gpsUpgradeStatus {
                return
            }
            
            let state = (arg.data as! Ls02ReadyUpdateAGPSStatus)
            print("gpsUpgradeValueObserver,",state)
            switch state {
            case .ready:
                self.createSendAGPSDataTimer()
            case .continueSend:
                self.writeDataSuspend = false
                self.createSendAGPSDataTimer()
            case .success:
                print("星历数据更新成功")
            case .faile:
                print("星历数据更新失败")
            case .allComplete:
                print("星历数据全部更新完成")
            case .complete:
                print("星历数据更新完成")
            }
            
        } onError: { (error) in
            print("异常")
        }
        .disposed(by: self.bag)
        
    }
    
    
    func writeComplete() {
        
        var type: Ls02UpdateAGPSCompleteMode = .all
        if self.GPSType == .ephemeris {
            type = binsData.isEmpty ? .all : .signle
        }
        
        BleHandler.shared.updateAGPComplete(type: type)
            .subscribe { [unowned self](result) in
                print("升级完成", result)
                
                self.invalidateTimer()
                
                switch result {
                case .continueSend:
                    
                    guard let d = self.binsData.first else {
                        self.progressAction.progress.accept(.success)
                        return
                    }
                    
                    self.serialNo = 0
                    self.suspendCount = 1
                    
                    self.splitData(data: d, mtu: self.writeMaxValue)
                    
                    self.writeDataSuspend = false
                    self.createSendAGPSDataTimer()
                case .success:
                    if self.GPSType != .almanac {
                        break
                    }
                    if self.binsData.isEmpty {
                        break
                    }
                    BleHandler.shared.readyUpdateAGPSCommand(type: .glonass)
                        .subscribe { state in
                            print("state", state)
                            if state == .ready {
                                guard let d = self.binsData.first else {
                                    self.progressAction.progress.accept(.success)
                                    return
                                }
                                
                                self.serialNo = 0
                                self.suspendCount = 1
                                
                                self.splitData(data: d, mtu: self.writeMaxValue)
                                
                                self.writeDataSuspend = false
                                self.createSendAGPSDataTimer()
                            }
                        } onError: { error in
                            
                        } onCompleted: {
                            
                        }.disposed(by: self.bag)

                default:
                    break
                }
            
            } onError: { [unowned self] (error) in
                print("升级失败", error)
                self.progressAction.progress.accept(.unknow)
                
            }
            .disposed(by: self.bag)
    }
    
    @objc func sendAGPSDataToWatch() {
        
        print("serialNo", serialNo, self.splitDataArray.count, self.binsData.count)
        
        let serialByte1 = UInt8((serialNo>>8)&0xff)
        let serialByte2 = UInt8(serialNo&0xff)
        
        let writeCmd: [UInt8] = [0x82, serialByte1, serialByte2]
        var writeData = Data.init(bytes: writeCmd, count: writeCmd.count)
        
        if(self.serialNo == self.splitDataArray.count - 1) {
            
            let subData = self.splitDataArray.last!
            writeData.append(subData)
            Ble02Operator.shared.directWrite(writeData, .withoutResponse)
            
            self.writeDataSuspend = true
            self.createSendAGPSDataTimer()
            
            self.binsData.removeFirst()
            self.writeComplete()
            
        } else {
            
            let subData = self.splitDataArray[serialNo]
            writeData.append(subData)
            Ble02Operator.shared.directWrite(writeData, .withoutResponse)
        }
        
        
        self.serialNo += 1
        
        self.packageCurrent += 1
        
        let progress: Float = Float(self.packageCurrent) / Float(self.packageTotal)
        self.progressAction.progress.accept(.progress(progress))
        print("发送了\(self.serialNo * self.writeMaxValue)字节", "限定", waitPointLenght * suspendCount, "progress", progress)
        
        if self.serialNo * self.writeMaxValue >= waitPointLenght * suspendCount {
            print("等待下一发送周期")
            self.writeDataSuspend = true
            self.createSendAGPSDataTimer()
            self.suspendCount += 1
        }
        
    }
    
    //MARK: 按照mtu切割数据
    func splitData(data: Data, mtu: Int) {
        
        self.splitDataArray.removeAll()
        
        let splitCount = data.count / mtu
        let lastLeft   = data.count % mtu
        print("总包大小：", data.count, "mtu", mtu, "splitCount",splitCount, "lastLeft",lastLeft)
        for i in 0..<splitCount {
            let startIndex = data.index(data.startIndex, offsetBy: i * mtu)
            let endIndex = data.index(startIndex, offsetBy: mtu)
            let subDataRange:Range = startIndex..<endIndex
            self.splitDataArray.append(data.subdata(in: subDataRange))
        }
        
        if lastLeft > 0 {
            let startIndex = data.index(data.endIndex, offsetBy: -lastLeft)
            let subDataRange:Range = startIndex..<data.endIndex
            self.splitDataArray.append(data.subdata(in: subDataRange))
        }
    }
}

extension Ls02GPSTransferManager {
    private func createSendAGPSDataTimer(){
        
        if writeDataSuspend {
            syncAGPSDataTimer?.invalidate()
            syncAGPSDataTimer = nil
            
        }else {
            syncAGPSDataTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(sendAGPSDataToWatch), userInfo: nil, repeats: true)
            syncAGPSDataTimer?.fire()
        }
        
    }
    
    private func invalidateTimer() {
        syncAGPSDataTimer?.invalidate()
        syncAGPSDataTimer = nil
    }
    
}
