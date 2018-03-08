//
//  TDDropListView.swift
//  TDDroopMenuViewDemo
//
//  Created by lisilong on 2018/3/7.
//  Copyright © 2018年 tuandai. All rights reserved.
//

import UIKit

class DropListModel {
    var titleModel: DropListTitleModel
    var list: [String]?
    
    var titleNormalColor: UIColor = UIColor.lightGray
    var titleSelectedColor: UIColor = UIColor.red
    var selectedIcon: UIImage?
    
    /// 当前选中的类型
    var didSelectedContent: String?
    
    init(titleModel: DropListTitleModel, list: [String]?, selectedIcon: UIImage?, titleNormalColor: UIColor = UIColor.lightGray, titleSelectedColor: UIColor = UIColor.red) {
        self.titleModel = titleModel
        self.list = list
        self.selectedIcon = selectedIcon
        self.titleNormalColor = titleNormalColor
        self.titleSelectedColor = titleSelectedColor
    }
}


typealias SelectClosure = (_ currentSelectedModel: DropListModel, _ models: [DropListModel]) -> Void

class TDDropListView: UIView {
    fileprivate let cellId = "cellId"
    fileprivate let duration: TimeInterval = 0.25
    fileprivate let lineH: CGFloat = 0.2
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    var bgMaskView: UIView?
    private var selectClosure: SelectClosure?
    var models: [DropListModel] = [DropListModel]()
    var didSelectedModel: DropListModel?
    var cellHeight: CGFloat = 40.0
    
    // MARK: - init
    
    init(frame: CGRect, models modelArray: [DropListModel], selectClosure : @escaping SelectClosure) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.models = modelArray
        self.selectClosure = selectClosure
        
        setupbgMaskView()
        setupsubView()
        
        // 默认选中第一个
        for model in modelArray {
            switch model.titleModel.type {
            case .list, .listUnChanged:
                model.didSelectedContent = model.list?.first ?? ""
            case .ascending:
            break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup
    
    func setupbgMaskView(){
        let heigth: CGFloat = self.frame.size.height > 0.0 ? self.frame.size.height : 0.0
        bgMaskView = UIView(frame: CGRect.init(x: 0.0, y: heigth, width: screenWidth, height: screenHeight-heigth-kNaviHeight))
        bgMaskView?.backgroundColor = RGBA(r: 0, g: 0, b: 0, a: 0.1)
        bgMaskView?.alpha = 0
        bgMaskView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapAction)))
    }
    
    func setupsubView() {
        let merger: CGFloat  = 0.2
        let width: CGFloat  =  (screenWidth - CGFloat(models.count - 1) * merger) /  CGFloat(models.count)
        let height: CGFloat = self.frame.size.height > 0.0 ? self.frame.size.height : 0.0
        
        for i in 0..<models.count {
            let model = models[i]
            // 中间分割线
            let lineX: CGFloat = (CGFloat(i + 1) * width + CGFloat(i) * merger) + merger * 0.5 - lineH * 0.5
            if i < self.models.count-1 {
                let rightLine = UIView.init(frame: CGRect.init(x: lineX, y: 0.0, width: lineH, height: self.frame.size.height))
                rightLine.backgroundColor = UIColor.lightGray
                self.addSubview(rightLine)
            }
            
            // title view
            let titleView = TDDropListTitleView.init(frame: CGRect(x: CGFloat(i) * (width + merger), y: 0.0, width: width, height: height),
                                                     model: model.titleModel)
            titleView.backgroundColor = UIColor.white
            titleView.merger = merger
            titleView.didClickedButtonClosure({ [weak self] (titleModel) in
                if let strongSelf = self {
                    strongSelf.didSelectRowAt(titleModel)
                }
            })
            self.addSubview(titleView)
        }
        
        // table View
        tableView.frame = CGRect(x: 0.0, y: height, width: screenWidth, height: 0.01)
        self.addSubview(tableView)
    }
    
    // MARK: - actions
    
    /// 点击某个分类的时候，刷新选项列表页
    func didSelectRowAt(_ titleModel: DropListTitleModel) {
        // 1. 获取当前选中分类列表
        for model in self.models {
            if model.titleModel === titleModel {
                self.didSelectedModel = model
                break
            }
        }
        guard let didSelectedModel = self.didSelectedModel else {
            return
        }
        
        // 2. 刷新选中分类标题
        for titleView in self.subviews {
            if titleView.isKind(of: TDDropListTitleView.self) {
                let view: TDDropListTitleView = titleView as! TDDropListTitleView
                if view.model !== didSelectedModel.titleModel, view.model?.type != .ascending {
                    view.isSelected = false
                }
            }
        }
        
        // 3. 刷新列表
        switch titleModel.type {
        case .list, .listUnChanged:
            if titleModel.isSelected {
                self.showListView()
            } else {
                self.hiddenListView()
            }
        case .ascending:
            // 回调
            if let block = self.selectClosure {
                block(didSelectedModel, self.models)
            }
            self.hiddenListView()
        }
    }
    
    /// 展示列表和遮罩
    func showListView() {
        guard let selectedModel = self.didSelectedModel else {
            return
        }
        tableView.reloadData()
        self.insertSubview(self.bgMaskView!, at: 0)
        UIView.animate(withDuration: self.duration, animations: {
            self.bgMaskView?.alpha = 1
        })
        let count: CGFloat = CGFloat(selectedModel.list?.count ?? 0)
        let markViewH = (screenHeight - kNaviHeight - self.cellHeight) * 0.8
        let tableViewH = count * self.cellHeight > markViewH ? markViewH : count * self.cellHeight
        UIView.animate(withDuration: self.duration, animations: {
            self.tableView.frame = CGRect.init(x: 0.0, y: self.bounds.size.height, width: screenWidth, height: tableViewH)
        })
    }
    
    /// 取消所有分类标题的选中状态
    func cancelSelectedStatus() {
        self.hiddenListView()
        for titleView in self.subviews {
            if titleView.isKind(of: TDDropListTitleView.self) {
                let view: TDDropListTitleView = titleView as! TDDropListTitleView
                if view.model?.type != .ascending {
                    view.isSelected = false
                }
            }
        }
    }
    
    /// 收起列表和遮罩
    func hiddenListView() {
        self.disminssMarkView()
        self.hiddenTableView()
    }
    
    /// 移除遮罩
    func disminssMarkView() {
        guard let _ = self.bgMaskView?.superview else {
            return
        }
        UIView.animate(withDuration: self.duration, animations: {
            self.bgMaskView?.alpha = 0
        }, completion: { (idCom) in
            self.bgMaskView?.removeFromSuperview()
        })
    }
    
    /// 隐藏列表
    func hiddenTableView() {
        guard self.tableView.frame.size.height > 10 else {
            return
        }
        let height: CGFloat = self.frame.size.height
        UIView.animate(withDuration: self.duration, animations: {
            self.tableView.frame = CGRect.init(x: 0.0, y: height, width: screenWidth, height: 0.01)
        })
    }
    
    /// 点击遮罩，退出列表页
    @objc func tapAction(){
        self.cancelSelectedStatus()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, with: event)
        if view == nil {
            for subView in self.subviews {
                let tp = subView.convert(point, from: self)
                if subView.bounds.contains(tp) {
                    view = subView
                }
            }
        }
        return view
    }
}


// MARK: - <UITableViewDelegate, UITableViewDataSource>

extension TDDropListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.didSelectedModel?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        if let list = self.didSelectedModel?.list {
            let title = list[indexPath.row]
            cell.textLabel?.text = title
            
            if let icon = self.didSelectedModel?.selectedIcon {
                // 设置选中样式
                var accessoryView: UIImageView? = cell.viewWithTag(666) as? UIImageView ?? nil
                if accessoryView == nil {
                    accessoryView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
                    accessoryView?.tag   = 666
                    cell.accessoryView   = accessoryView
                }
                accessoryView?.image = icon
                accessoryView?.isHidden = true
            }
            
            let isSelected = (title == self.didSelectedModel?.didSelectedContent ?? "") ? true : false
            cell.textLabel?.textColor = isSelected ? self.didSelectedModel?.titleSelectedColor : self.didSelectedModel?.titleNormalColor
            cell.accessoryView?.isHidden = isSelected ? false : true
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let list = self.didSelectedModel?.list else {
            return
        }
        let title = list[indexPath.row]
        for model in self.models {
            if self.didSelectedModel === model {
                model.didSelectedContent = title
            }
        }
        
        // 回调
        if let block = self.selectClosure {
            block(self.didSelectedModel!, self.models)
        }
        self.hiddenTableView()
        self.disminssMarkView()
        
        // 获取当前的分类标题view
        guard let titleModel = self.didSelectedModel?.titleModel else {
            return
        }
        var currentTitleView: TDDropListTitleView?
        for titleView in self.subviews {
            if titleView.isKind(of: TDDropListTitleView.self) {
                let view: TDDropListTitleView = titleView as! TDDropListTitleView
                if view.model === titleModel {
                    currentTitleView = view
                    break
                }
            }
        }
        guard let titleView: TDDropListTitleView = currentTitleView else {
            return
        }
        // 刷新分类标题view
        switch titleModel.type {
        case .list:
            titleView.title = title
        default:
            break
        }
        titleView.isSelected = false
        self.cancelSelectedStatus()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
