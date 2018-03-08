//
//  ViewController.swift
//  TDDroopMenuViewDemo
//
//  Created by lisilong on 2018/3/5.
//  Copyright © 2018年 tuandai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(self.infoLabel)
        self.infoLabel.frame = CGRect.init(x: 0, y: self.view.center.y, width: self.view.frame.size.width, height: 40)
        self.infoLabel.center.x = self.view.center.x
        self.setupDropListView()
    }
    
    func setupDropListView() {
        let moneyArray:[String] = ["全部","0~1000元","1001~2000元","2001~3000元","3001~5000元","5000元以上"]
        let limitArray:[String] = ["万分收益","0~14天","15~30天","30~60天","60~90天","90~180天","180~360天","360天以上"]
        let test:[String] = ["收益"]
        let sortArray:[String] = ["贷款成功率 ↓","日费率 ↑"]
        
        // 标题
        let titleModel1: DropListTitleModel = DropListTitleModel.init(title: "全部", icon: #imageLiteral(resourceName: "downUp"), selectedIcon: #imageLiteral(resourceName: "downUp"), type: .list, titleNormalColor: UIColor.lightGray, titleSelectedColor: UIColor.blue)
        
        let titleModel2: DropListTitleModel = DropListTitleModel.init(title: "万分收益", icon: #imageLiteral(resourceName: "downUp"), selectedIcon: #imageLiteral(resourceName: "downUp"), type: .list, titleNormalColor: UIColor.lightGray, titleSelectedColor: UIColor.blue)
        
        let titleModel3: DropListTitleModel = DropListTitleModel.init(title: "收益", icon: #imageLiteral(resourceName: "ascending"), selectedIcon: #imageLiteral(resourceName: "ascending"), type: .ascending, titleNormalColor: UIColor.lightGray, titleSelectedColor: UIColor.blue, isAscending: false)
        
        let titleModel4: DropListTitleModel = DropListTitleModel.init(title: "筛选", icon: #imageLiteral(resourceName: "downUp"), selectedIcon: #imageLiteral(resourceName: "downUp"), type: .listUnChanged, titleNormalColor: UIColor.lightGray, titleSelectedColor: UIColor.blue)
        
        // 列表
        let listModel1: DropListModel = DropListModel.init(titleModel: titleModel1, list: moneyArray, selectedIcon: #imageLiteral(resourceName: "selected"))
        let listModel2: DropListModel = DropListModel.init(titleModel: titleModel2, list: limitArray, selectedIcon: #imageLiteral(resourceName: "selected"))
        let listModel3: DropListModel = DropListModel.init(titleModel: titleModel3, list: test, selectedIcon: #imageLiteral(resourceName: "selected"))
        let listModel4: DropListModel = DropListModel.init(titleModel: titleModel4, list: sortArray, selectedIcon: #imageLiteral(resourceName: "selected"))
        let models = [listModel1, listModel2, listModel3, listModel4]
        
        let frame = CGRect.init(x: 0, y: kNaviHeight, width: screenWidth, height: 40)
        let dropList = TDDropListView.init(frame: frame, models: models) { [weak self] (model, models) in
            var str = "  "
            for model in models {
                switch model.titleModel.type {
                case .list,.listUnChanged:
                    str += "  \(model.didSelectedContent ?? "")"
                case .ascending:
                    str += "  \(model.titleModel.isAscending ? "升序" : "降序")"
                }
            }
            print(str)
            
            if let strongSelf = self {
                strongSelf.infoLabel.text = str
            }
        }
        dropList.cellHeight = 40.0
        view.addSubview(dropList)
    }
    
}

