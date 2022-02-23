//
//  BleFacadeable.swift
//  LieShengBleSDK
//
//  Created by guotonglin on 2021/4/12.
//

import Foundation
import RxCocoa
import RxSwift

/*
 错误类型
 */
public enum BleError: Error {
    case timeout
    case peripheralError
    case dataError
    case powerOff
    case disConnect
    case error(_ messae: String)
}
public enum WriteError: Error {
    case error(messae: String)
}
/*
 设备返回数据
 */
public class BleResponse {
    public var datas: [Data]?
    public var pbDatas: [hl_cmds]?
    public var progress: CGFloat?
    public var writeError: WriteError?
//    public var backData: LsBackData?
    public var uteData: Any?
    
    var item: [BigDataProtocol]?
    var sprotItems: LSWorkoutItem?
    
    public init(datas: [Data] = []) {
        self.datas = datas
    }
    //一般数据发送的
    public init(pbDatas: [hl_cmds] = []) {
        self.pbDatas = pbDatas
    }
    //表盘发送进度
    init(progress: CGFloat = 0) {
        self.progress = progress
    }
    //错误有关的
    init(writeError: WriteError ) {
        self.writeError = writeError
    }
    
//    init(backData: LsBackData ) {
//        self.backData = backData
//    }
//    
    init(item: [BigDataProtocol]? ) {
        self.item = item
    }
    
    init(sprotItems: LSWorkoutItem? ) {
        self.sprotItems = sprotItems
    }
    
    init(uteData: Any? ) {
        self.uteData = uteData
    }
}



public protocol BleFacadeable {
    
    var dataObserver: Observable<BleBackDataProtocol>? {
        get
    }
    
    func write(_ writeData: Data,
               _ characteristic: Int,
               _ name: String,
               _ duration: Int,
               _ endRecognition: (((Data) -> Bool)?))  -> Observable<BleResponse>
    
    func directWrite(_ data: Data, _ type: WitheType)
    
    func readValue(channel: Channel)
    
}



