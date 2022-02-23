//
//  Ble02Parser.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/8.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit

class Ble02Parser: NSObject {
    
    var receiveArray: [Data] = []
    
    var writeData: Data
    
    private var writeDataByte: [UInt8] {
        get {
            [UInt8](self.writeData)
        }
    }
    
    init(writeData: Data) {
        self.writeData = writeData
    }
    
    func accept(data: Data) {
        self.receiveArray.append(data)
    }
    
    func validate(_ data: Data) -> Bool {
        let dataByte = [UInt8](data)
        return dataByte[0] == writeDataByte[0]
    }
}
