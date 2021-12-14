//
//  StressFuncTestView.swift
//  Soundbrenner
//
//  Created by Hunter on 2019/7/3.
//  Copyright © 2019 Hunter. All rights reserved.
//

import UIKit

protocol LSItemFuncTestViewProtocol {
    func clickCollectViewCell(value: String)
}

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

struct WatchFunction {
    var column:String
    var item:[String]
}

class LSItemFuncTestView: UIView {
    
    private var collectionView:UICollectionView?
    
    var delegate: LSItemFuncTestViewProtocol!
    
    private let cellReuseId = "LSItemFuncTestView.cell.cellId"
    private let headReuseId = "LSItemFuncTestView.head.reuseId"
    
    private let footerHeight:CGFloat = 50
    
    let settings = WatchFunction(column: "手表设置", item: ["获取MTU","绑定设备", "配置设备","获取设备信息", "同步手机信息", "同步用户信息","设置天气","设置心率采样间隔", "设置久坐间隔","设置喝水间隔",  "设置免打扰", "设置国家", "设置UI风格", "设置时间格式", "设置公英制", "设置亮屏时长", "设置心率预警", "获取心率", "设置通知提醒",  "设置固件升级",   "获取实时心率", "设置免打扰开关",  "同步步数",  "获取功能项目",  "设置提醒数据", "设置血氧采样间隔", "获取血氧采样间隔", "发送App状态","同步时间","设置常用参数"])
    let bind = WatchFunction.init(column: "手表绑定", item: ["恢复出厂","工厂测试"])
    let alerm = WatchFunction.init(column: "闹钟", item: ["设置闹钟","获取闹钟"])
    let goal = WatchFunction.init(column: "运动目标", item: ["设置运动目标"])
    let sportStatus = WatchFunction.init(column: "运动状态", item: ["设置运动状态", "查询运动状态"])
    let switches = WatchFunction.init(column: "开关相关", item: ["同步开关"])
    let testData = WatchFunction.init(column: "测试数据", item: ["生成测试数据"])
    let bigData = WatchFunction.init(column: "大数据相关", item: ["获取步数历史数据", "获取血氧历史数据", "获取心率历史数据", "获取睡眠历史数据","获取运动数据", "获取手表Log"])
    let daile = WatchFunction.init(column: "表盘相关", item: ["获取表盘数据","升表盘1","升表盘2"])
    let inner = WatchFunction.init(column: "内部应用", item: ["清除连接记录"])
    let appFunc = WatchFunction.init(column: "App功能测试", item: ["获取每日步数", "获取手表功能列表"])
    let gps = WatchFunction.init(column: "GPS", item: ["查询GPS信息", "设置GPS信息"])
    
    let sort = WatchFunction(column: "排序", item: ["获取一级排序","设置一级排序"])
    
    var dataSource: [WatchFunction]!
    
    var  stressLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dataSource = [settings, bind,alerm, goal, sportStatus, switches, testData, bigData, daile, inner, appFunc, gps, sort]
        createCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.itemSize = CGSize(width: (SCREEN_WIDTH-25)/4, height: (SCREEN_WIDTH-25)/4)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.headerReferenceSize = CGSize(width: SCREEN_WIDTH, height: footerHeight) // 页脚宽高
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: flowLayout)
        collectionView!.backgroundColor = UIColor.white
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellReuseId)
        collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headReuseId)
        
        self.addSubview(collectionView!);
    }
    
}

extension LSItemFuncTestView:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard section < dataSource.count else {
            return 0
        }
        
        let values = dataSource[section]
        
        return values.item.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableview:UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: headReuseId, for: indexPath)
            
            for subView in reusableview.subviews {
                subView.removeFromSuperview()
            }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: reusableview.frame.size.width, height: reusableview.frame.size.height))
            label.numberOfLines = 0
            label.text = dataSource[indexPath.section].column
            label.textAlignment = .left
            reusableview.addSubview(label)
            
        }
        
        return reusableview
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath)
        
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        cell.backgroundColor = .lightGray
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        label.numberOfLines = 0
        label.text = dataSource[indexPath.section].item[indexPath.row]
        label.textAlignment = .center
        cell.contentView.addSubview(label)
        return cell;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        
        cell.backgroundColor = .blue;
        
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 0.1) {
            cell.backgroundColor = .lightGray;
        }
        
        delegate.clickCollectViewCell(value: dataSource[indexPath.section].item[indexPath.row])
    }
    
}
