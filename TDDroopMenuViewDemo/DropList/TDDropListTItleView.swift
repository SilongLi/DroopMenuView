//
//  TDDropListTitleView.swift
//  TDDropListView
//
//  Created by lisilong on 2018/3/7.
//  Copyright © 2018年 tuandai. All rights reserved.
//

import UIKit

class DropListTitleModel {
    var title: String
    var icon: UIImage?
    var selectedIcon: UIImage?
    var type: TDDropListTitleViewType = .list
    var titleNormalColor: UIColor = UIColor.lightGray
    var titleSelectedColor: UIColor = UIColor.red
    var isSelected: Bool = false
    var isAscending: Bool = false // 是否为升序, 默认降序
    
    init(title: String, icon: UIImage?, selectedIcon: UIImage?, type: TDDropListTitleViewType = .list, titleNormalColor: UIColor = UIColor.lightGray, titleSelectedColor: UIColor = UIColor.red, isAscending: Bool = false) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.type = type
        self.titleNormalColor = titleNormalColor
        self.titleSelectedColor = titleSelectedColor
        self.isAscending = isAscending
    }
}

enum TDDropListTitleViewType {
    /// 下拉列表形式
    case list
    
    /// 升降序
    case ascending
    
    /// 下拉列表形式，但不刷新标题
    case listUnChanged
}


typealias GesClosure = (_ model: DropListTitleModel) -> Void

class TDDropListTitleView: UIView {
    fileprivate let duration: TimeInterval = 0.25
    fileprivate let iconW: CGFloat = 12.0
    var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    lazy var icon: UIImageView = {
        let icon = UIImageView()
        return icon
    }()
    var titleLabelWidth: CGFloat?
    var bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.lightGray
        return line
    }()
    var title: String? {
        didSet {
            let width = self.frame.size.width - iconW
            self.titleLabelWidth = self.getLabWidth(labelStr: self.title!, font: UIFont.systemFont(ofSize: 12), width: width, height: 12) + 2
            label.text = self.title
            layout()
        }
    }
    var _isSelect: Bool = false
    fileprivate var gesClosure: GesClosure?
    var isSelected: Bool? {
        didSet{
            switch self.type {
            case .list, .listUnChanged:
                self._isSelect = isSelected!
                self.bottomLine.isHidden = isSelected!
                self.label.textColor = isSelected! ? UIColor.red : UIColor.black
                let transform = isSelected! ? CGAffineTransform.init(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
                UIView.animate(withDuration: duration, animations: {
                    self.icon.transform = transform
                })
                
            case .ascending:
                let isAscending = self.model?.isAscending ?? false
                let transform = isAscending ? CGAffineTransform.init(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
                UIView.animate(withDuration: duration, animations: {
                    self.icon.transform = transform
                })
            }
        }
    }
    var type: TDDropListTitleViewType = .list
    var model: DropListTitleModel?
    var merger: CGFloat = 1.0
    
    // MARK: - init
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, model: DropListTitleModel) {
        super.init(frame: frame)
        self.model = model
        self.setupContent()
        layout()
        
        let lineH: CGFloat = 0.2
        let topLine = UIView.init(frame: CGRect.init(x: -merger * 0.5, y: 0.0, width: frame.size.width + merger, height: lineH))
        topLine.backgroundColor = UIColor.lightGray
        self.addSubview(topLine)
        
        bottomLine.frame = CGRect.init(x: -merger * 0.5, y: frame.size.height - lineH, width: frame.size.width + merger, height: lineH)
        self.addSubview(bottomLine)
        
        let ges = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(ges)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup
    
    func setupContent() {
        self.type = self.model?.type ?? .list
        
        self.title = self.model?.title
        self.titleLabelWidth = self.getLabWidth(labelStr: self.model?.title ?? "",
                                                font: UIFont.systemFont(ofSize: 12),
                                                width: frame.size.width - iconW,
                                                height: 14) + 2
        label.text = self.model?.title ?? ""
        addSubview(label)
        
        if let i = self.model?.icon {
            icon.image = i
        }
        switch self.type {
        case .list, .listUnChanged:
            break
        case .ascending:
            let isAscending = self.model?.isAscending ?? false
            let transform = !isAscending ? CGAffineTransform.init(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
            UIView.animate(withDuration: duration, animations: {
                self.icon.transform = transform
            })
        }
        addSubview(icon)
    }
    
    func layout() {
        let labelW: CGFloat = titleLabelWidth ?? 0.001
        let labelX = (self.frame.size.width - iconW - labelW - 2.0 * suitParm) * 0.5
        label.frame = CGRect.init(x: labelX, y: 0.0, width: titleLabelWidth!, height: self.frame.size.height)
        
        icon.frame = CGRect(x: label.frame.maxX + 2.0 * suitParm, y: (self.frame.size.height - iconW) * 0.5, width: iconW, height: iconW)
    }
    
    // MARK: - actions
    
    /// 回调
    func didClickedButtonClosure(_ block: @escaping GesClosure) {
        self.gesClosure = block
    }
    
    @objc func tapAction(){
        self._isSelect = !self._isSelect
        self.isSelected = self._isSelect
        var isSelected = true
        switch self.type {
        case .list, .listUnChanged:
            isSelected = self.isSelected!
        case .ascending:
            self.model?.isAscending = !(self.model?.isAscending ?? false)
        }
        self.model?.isSelected = isSelected
        if self.gesClosure != nil, let model = self.model {
            self.gesClosure!(model)
        }
    }
    
    func getLabWidth(labelStr: String, font: UIFont, width: CGFloat, height: CGFloat) -> CGFloat {
        let statusLabelText: NSString = labelStr as NSString
        let size = CGSize(width: width, height: height)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : AnyObject], context: nil).size
        return strSize.width
    }
}

