# LsBleLibrary
 A library that encapsulates the system bluetooth, which can communicate with bluetooth using raw byte streams and Google Protocol Buffer(PB) format.

### Installation 

[CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html):

```sh
pod 'LsBleLibrary'
```
## How use the ble lib

### Config lib
```swift
        // Scan buileder
        let scanBuilder: BluetoothScanable.ScanBuilder = {
            BluetoothScan(centralManager: $0.centralManager, scanInfo: $0.scanInfo)
        }
        //Connect buileder
        let connectBuilder: BluetoothConnectable.ConnectBuilder = {
            BluetoothConnect(
                centralManager: $0.centralManager,
                connectInfo: $0.connectInfo,
                scaner: $0.scaner
            )
        }
        
        //Conifg scan and connect 
        BleFacade.shared.configBuider(scanBuilder, connectBuilder)
        
        //Configure what type of device to scan
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
                    print("Peripherals searched")
                    let devices = response?.filter({ $0.peripheral.name != nil })
                    self.dataSource.append(contentsOf: devices)
                    self.tableView.reloadData()
                } else if (state == .end) {
                    print("scan stop")
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
                    print("Connected waiting to scan for services and characteristics")
                    BleFacade.shared.bleDevice?.peripheral = response?.peripheral
                } else if (state == .dicoverChar) {
                    BleFacade.shared.bleDevice?.updateCharacteristic(characteristic: response?.characteristics, statusCallback: nil)
                    if ((BleFacade.shared.bleDevice?.connected) != nil) {
                        BleFacade.shared.connecter.finish()
                    }
                    print("characteristic found")
                } else if (state == .timeOut) {
                    print("connect timeout")
                    self.view.makeToast("connect timeout")
                }
            }, onError: { error in
                print("\(error)")
            })
            .disposed(by: bag)
```

## How to use the ble handler

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
                                         weaDesc: "sunny",
                                         airDesc: "good",
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
                print("set the weather successfully", value)
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
                    print("Current battery:",power)
                }
            } onError: {  error in
                print(error)
            }.disposed(by: bag)
```

## Release History 

* 0.2.1
    * CHANGE: Update docs
* 0.2.0
    * CHANGE: Remove `README.md`
* 0.1.0
    * Work in progress

## Authors 

[Haiquan](https://xiahaiquan.github.io/)

## License 

This project is under the MIT license, please click [LICENSE.md](https://github.com/Xiahaiquan/LsBleLibrary/blob/main/LICENSE) for more details.

