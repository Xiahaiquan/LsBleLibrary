//
//  BLEOperation.swift
//  ble_debugging
//
//  Created by Antonio on 2021/5/31.
//

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth

class BLEOperation: ConcurrentOperation {
    
    var bag: DisposeBag = DisposeBag()
    
    var dataArr: [Data]!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    var timeoutTimeInterval: TimeInterval!
    var endRecognition: ((Data) -> Bool)?
    var observer : AnyObserver<BleResponse>?
    
    var ble02Parser: Ble02Parser?
    
    init(dataArr: [Data],
         peripheral: CBPeripheral,
         characteristic: CBCharacteristic, name: String,
         endRecognition: ((Data) -> Bool)? = nil,
         ble02Parser: Ble02Parser? = nil,
         observer: AnyObserver<BleResponse>,
         timeoutTimeInterval: TimeInterval) {
        
        self.peripheral = peripheral
        self.characteristic = characteristic
        self.dataArr = dataArr
        
        self.ble02Parser = ble02Parser
        
        self.observer = observer
        self.endRecognition = endRecognition
        self.timeoutTimeInterval = timeoutTimeInterval
        
        super.init()
        self.name = name
    }
    
    override func main() {
        
        printLog("\(self)")
        //任务取消了， 就不往下执行了
        if isCancelled {
            cancel()
            return
        }
        
        DispatchQueue.global().async { [self] in
            //分包，逐步发送数据数据到手表
            for data in dataArr {
                print("send data:", data.desc())
                peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutTimeInterval) { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if self.isFinished {
                return
            }
            self.timeout()
            
        }
        
    }
    
    func timeout() {
        observer?.onError(BleError.timeout)
        print("current operation timeout")
        finish()
    }
    
    deinit {
        print("deinit", self)
    }
}
// MARK: - ConcurrentOperation
class ConcurrentOperation: Operation {
    
    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        if !isExecuting {
            state = .executing
        }
        main()
    }
    
    func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    override func cancel() {
        super.cancel()
        finish()
    }
}

// MARK: - QueueManager
class QueueManager {
    
    var observation : NSKeyValueObservation?
    
    lazy var syncDataQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Sync data queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    static let shared = QueueManager()
    
    private func `init`() {
        
        observation = QueueManager.shared.syncDataQueue.observe(\.operationCount, options: [.new]) { (queue, change) in
            let changeNewValue = Int(change.newValue ?? 0)
            printLog("Current operation count: \(changeNewValue.description)")
            printLog("\(String(describing: QueueManager.shared.syncDataQueue.operations.first?.name))")
        }
    }
    
    func enqueueToQueue(_ operation: BLEOperation) {
        syncDataQueue.addOperation(operation)
        
    }
    
    
}


