# LsBleLibrary
 封装系统蓝牙，同时可使用原始字节流和pb格式与蓝牙通信的库。

### Installation 安装

[CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html):

```sh
pod 'LsBleLibrary'
```
## How use ble lib

### Config lib
```swift
        // 扫描 和 连接 的具体实现
        let scanBuilder: BluetoothScanable.ScanBuilder = {
            BluetoothScan(centralManager: $0.centralManager, scanInfo: $0.scanInfo)
        }
        let connectBuilder: BluetoothConnectable.ConnectBuilder = {
            BluetoothConnect(
                centralManager: $0.centralManager,
                connectInfo: $0.connectInfo,
                scaner: $0.scaner
            )
        }
        
        // 配置扫描和连接实现
        BleFacade.shared.configBuider(scanBuilder, connectBuilder)
        
        //要扫描什么类型的设备
        BleFacade.shared.configDeviceInfo(BleScanDeviceConfig(
            services: nil,
            deviceCategory: [.Watch],
            deviceType: [.LS04,.LS05, .LS05S, .LS09A, .LS09B, .LS10, .LS11]
        ))
 ```

### Search
```swift
        BleFacade.shared.scaner
            .scan(duration: 5)
            .subscribe(onNext: { (state, response) in
                if state == .nomal {
                    print("已搜索出外设")
                    let devices = response?.filter({ $0.peripheral.name != nil })
                    self.dataSource.append(contentsOf: devices)
                    self.tableView.reloadData()
                } else if (state == .end) {
                    print("扫描结束")
                }
            }, onError: { error in
                print("\(error)")
            })
            .disposed(by: bag)
```
### Connect
```swift
               BleFacade.shared.connecter.connect(duration: 5)
            .subscribe(onNext: { (state, response) in
                if state == .connectSuccessed {
                    print("已连接等待扫描服务及特征")
                    BleFacade.shared.bleDevice?.peripheral = response?.peripheral
                } else if (state == .dicoverChar) {
                    BleFacade.shared.bleDevice?.updateCharacteristic(characteristic: response?.characteristics, statusCallback: nil)
                    if ((BleFacade.shared.bleDevice?.connected) != nil) {
                        BleFacade.shared.connecter.finish()
                    }
                    print("发现了特征值")
                } else if (state == .timeOut) {
                    print("连接超时，未找到配置信息指定设备")
                    self.view.makeToast("连接超时, 请重试")
                }
            }, onError: { error in
                print("\(error)")
            })
            .disposed(by: bag)
```

## How to use ble handler

### Get data from device

```swift
            BleHandler.shared.getmtu().subscribe { (mtu) in
                print(mtu, "back mtu")
            } onError: { (err) in
                print(err)
            }.disposed(by: bag)
```

### Set data to device
```swift
                let weather = LSWeather.init(timestamp: 1641571200,
                                         city: "shenzhen",
                                         air: 0,
                                         weaDesc: "晴",
                                         airDesc: "优",
                                         humidity: 1,
                                         uvIndex: 2,
                                         currTem: 3,
                                         highTem: 4,
                                         lowTem: 5,
                                         wea: 6,
                                         airLevel: 7,
                                         pm25: 8,
                                         weatherState: .sunny)
            BleHandler.shared.setWeatherData([weather]).subscribe { value in
                print("设置天气成功", value)
            } onError: { error in
                print("设置天气失败", error)
            }.disposed(by: bag)
  ```
  
### Monitor  device data update

```swift
        BleHandler.shared.dataObserver?.filter({ arg in
            return arg.type == .electricityUpdate
        })
            .subscribe { value in
                if let power = value.data as? UInt32 {
                    print("当前电量:",power)
                }
            } onError: {  error in
                print(error)
            }.disposed(by: bag)
```

## Release History 版本历史

* 0.2.1
    * CHANGE: Update docs
* 0.2.0
    * CHANGE: Remove `README.md`
* 0.1.0
    * Work in progress

## Authors 关于作者

[Haiquan](https://xiahaiquan.github.io/)

## License 授权协议

这个项目 MIT 协议， 请点击 [LICENSE.md](https://github.com/Xiahaiquan/LsBleLibrary/blob/main/LICENSE) 了解更多细节。
