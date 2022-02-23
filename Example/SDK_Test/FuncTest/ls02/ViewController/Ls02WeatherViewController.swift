//
//  Ls02WeatherViewController.swift
//  RxSwiftPro
//
//  Created by guotonglin on 2021/3/18.
//  Copyright © 2021 LieSheng. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxCocoa
import RxSwift
import LsBleLibrary

class Ls02WeatherViewController: UIViewController, Storyboardable {
    
    private var weather: [Data] = []
    private var tempWeathers: [Data] = []
    
    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        self.title = "7 天天气设置"
        
        super.viewDidLoad()
    }
    
    @IBAction func clickSyn7DayWeatherBtn(_ sender: UIButton) {
        
        // 今天 到 未来 6 天的 最高温、最低温、和气候状态
        let temperature = [
            (32, 18, Ls02WeatherState.sunny),
            (33, 17, Ls02WeatherState.cloudy),
            (34, 19, Ls02WeatherState.overcast),
            (35, 20, Ls02WeatherState.shower),
            (36, 21, Ls02WeatherState.sleet),
            (37, 22, Ls02WeatherState.lightRain),
            (38, 23, Ls02WeatherState.heavyRain)
        ]
        
        var dataSource = [LSWeather]()
//        for item in 0 ... 6 {
//            let weather = LSWeather.init(date: "", city: "", weatherTag: item, temperature: item, maxTemp: item, minTemp: item, air: item, humidity: item, uvIndex: item, weatherState: .cloudy, timestamp: UInt64(item))
//            dataSource.append(weather)
//        }

        BleHandler.shared.setWeatherData(dataSource)
            .subscribe { (flag) in
                print("updateWeather : \(flag)")
                if flag {
                    self.view.makeToast("更新完成", duration: TimeInterval(2), position: .center)
                }
                
            } onError: { (error) in
                print("updateWeather error \(error)")
                self.view.makeToast("更新失败", duration: TimeInterval(2), position: .center)
            }
            .disposed(by: self.bag)
        
    }
    
}
