//
//  NFCCMDProcess.swift
//  LsBleLibrary
//
//  Created by antonio on 2021/11/27.
//
import Foundation
import RxCocoa
import RxSwift


public typealias NFCCommand = (index: Int, checker: String?, command: String)
public typealias RegisterStep = (step: String, session: String, commands: [NFCCommand])

public enum NFCError: Error {
    case error(_ messae: String, _ code: Int = 0)
}

public typealias ExcuteResult = (index: Int, excuteResult: String)

public enum NFCService: UInt32 {
    case None = 0x00, Card, CardOn, CardOff, Charge, CardAndCharge, Emigration, ExitCard, DeleteCard, Unbind, Blance, Refund, UseRecords, CityList, SwitchCard
}

public protocol Command {
    func execute()
}
