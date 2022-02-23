//
//  GeneralDevice.swift
//  LieShengSDKDemo
//
//  Created by Antonio on 2021/7/1.
//

import Foundation

public var isOpenLog: Bool = false
///全局函数
func printLog(_ message:Any...,file:String = #file,funcName:String = #function,lineNum:Int = #line){
    print(message, file: file, funcName: funcName, lineNum: lineNum)
}

func print(_ items: Any..., file:String = #file,funcName:String = #function,lineNum:Int = #line) {
    
    if !isOpenLog {
        return
    }
    
    let file = (file as NSString).lastPathComponent;
    
    let formatter = DateFormatter.init()
    if let identifier = Locale.preferredLanguages.first {
        formatter.locale = Locale.init(identifier: identifier)
    }
    formatter.dateFormat = "HH:mm:ss"
    
    let date = formatter.string(from: Date())
    let itemsDes = items.reduce("") { partialResult, result in
        var temp = "\(result)"
        if result is Array<Any> {
            temp = (result as! Array<Any>).reduce("") { arg1 , arg2 in
                return arg1 + "\(arg2)"
            }
        }
        return partialResult + temp
    }
    let consoleStr = "\n\(date) \(file) \(funcName)[\(lineNum)]:\n\(itemsDes)"
    
    Swift.print(consoleStr)
}


