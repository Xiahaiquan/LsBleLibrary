//
//  GeneralDevice.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/1.
//

import Foundation
///全局函数
func printLog<T>(_ message:T,file:String = #file,funcName:String = #function,lineNum:Int = #line){
    
    let file = (file as NSString).lastPathComponent;
    
    let formatter = DateFormatter.init()
    formatter.dateFormat = "HH:mm:ss"
    
    let date = formatter.string(from: Date())
    
    let consoleStr = "[\(file)]:[\(funcName)]:[\(lineNum)]:[\(date)]--\(message)"
    
    print(consoleStr)
    
    
}




