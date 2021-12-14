//
//  BleHelper.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/12/10.
//

import Foundation

struct BleHelper {
    
    static func getOperateSwitch(value: UInt32, type: LSSupportFunctionEnum) ->Bool {
        
        if (value >> type.rawValue) & 1 == 1 {
            return true
        }
        
        return false
    }
}


