//
//  HomeTitlesView.swift
//  MGDYZB
//
//  Created by ming on 16/10/25.
//  Copyright © 2016年 ming. All rights reserved.
//

import UIKit

private let kScrollLineH: CGFloat = 2
private let kNormalColor : (CGFloat, CGFloat, CGFloat) = (85, 85, 85)
private let kSelectColor : (CGFloat, CGFloat, CGFloat) = (255, 128, 0)

// MARK:- 定义协议
@objc
protocol HomeTitlesViewDelegate: NSObjectProtocol {
    @objc optional func HomeTitlesViewDidSetlected(_ homeTitlesView: HomeTitlesView, selectedIndex: Int)
}


class HomeTitlesView: UIView {
    // MARK: - 属性
    var titles: [String]
    var titleLabels: [UILabel] = [UILabel]()
    fileprivate var currentIndex : Int = 0
    weak var deledate: HomeTitlesViewDelegate?
    var HomeTitlesViewWhenTitleSelect : ((_ homeTitlesView: HomeTitlesView, _ selectedIndex: Int) -> ())?
    
    // MARK: - lazy属性
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
        }()
    fileprivate lazy var scrollLine : UIView = {
        let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor.orange
        return scrollLine
    }()
    
    
    // MARK:- 自定义构造函数
    // MARK:- 自定义构造函数
    init(frame: CGRect, titles: [String]) {
        self.titles = titles
        super.init(frame: frame)
        self.backgroundColor = UIColor(r: 166, g: 166, b: 166, a: 0.2)
        setUpUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 初始化UI
extension HomeTitlesView {
    fileprivate func setUpUI() {
        // 1.添加UIScrollView
        addSubview(scrollView)
        scrollView.frame = bounds
        
        // 2.添加title对应的Label
        setupTitleLabels()
        
        // 3.设置底线和滚动的滑块
        setupBottomLineAndScrollLine()
    }
    
    fileprivate func setupTitleLabels() {
        // 0.确定label的一些frame的值
        let labelW: CGFloat = kScreenW/CGFloat(self.titles.count)
        let labelH: CGFloat = frame.height - kScrollLineH
        let labelY: CGFloat = 0
        
        for (index, title) in self.titles.enumerated() {
            // 1.创建UILabel
            let labelX : CGFloat = labelW * CGFloat(index)
            let label = UILabel(frame: CGRect(x: labelX, y: labelY, width: labelW, height: labelH))
            
            // 2.设置Label属性
            label.textAlignment = .center
            label.text = title
            label.tag = index
            label.textColor = UIColor.RGBColor(red: 85, green: 85, blue: 85)
            label.font = UIFont.systemFont(ofSize: 16.0)
            
            // 3.将label添加到scrollView中
            scrollView.addSubview(label)
            titleLabels.append(label)
            
            // 4.给Label添加手势
            label.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(HomeTitlesView.titleLabelClick(_:)))
            label.addGestureRecognizer(tapGes)
        }
    }
    
    fileprivate func setupBottomLineAndScrollLine() {
        // 1.添加底线
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.lightGray
        let lineH : CGFloat = 0.5
        bottomLine.frame = CGRect(x: 0, y: frame.height - lineH, width: frame.width, height: lineH)
        addSubview(bottomLine)
        
        // 2.添加scrollLine
        // 2.1.获取第一个Label
        guard let firstLabel = titleLabels.first else { return }
        firstLabel.textColor = UIColor.KNormalColorForPageTitle()
        
        // 2.2.设置scrollLine的属性
        scrollView.addSubview(scrollLine)
        scrollLine.frame = CGRect(x: firstLabel.frame.origin.x, y: frame.height - kScrollLineH, width: firstLabel.frame.width, height: kScrollLineH)
    }
    
}

// MARK:- 监听Label的点击
extension HomeTitlesView {
    @objc func titleLabelClick(_ tap: UITapGestureRecognizer) {
        // 0.获取当前Label
        guard let currentLabel = tap.view as? UILabel else { return }
        
        // 1.如果是重复点击同一个Title,那么直接返回
        if currentLabel.tag == currentIndex { return }
        
        // 2.获取之前的Label
        let oldLabel = titleLabels[currentIndex]
        
        // 3.切换文字的颜色
        currentLabel.textColor = UIColor.KSelectedColorForPageTitle()
        oldLabel.textColor = UIColor.KNormalColorForPageTitle()
        
        // 4.保存最新Label的下标值
        currentIndex = currentLabel.tag
        
        // 5.滚动条位置发生改变
        let scrollLineX = CGFloat(currentIndex) * scrollLine.frame.width
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.scrollLine.frame.origin.x = scrollLineX
        }) 
        
        // 6.回调
//        if (self.HomeTitlesViewWhenTitleSelect != nil) {
//            self.HomeTitlesViewWhenTitleSelect!(HomeTitlesView: self, selectedIndex: currentIndex)
//        }
        deledate?.HomeTitlesViewDidSetlected!(self, selectedIndex: currentIndex)
    }
}

// MARK:- 对外暴露的接口方法
extension HomeTitlesView {
    func setTitleWithProgress(_ progress : CGFloat, sourceIndex : Int, targetIndex : Int) {
        // 1.取出sourceLabel/targetLabel
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]
        
        // 2.处理滑块的逻辑
        let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveX = moveTotalX * progress
        scrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        
        // 3.颜色的渐变(复杂)
        // 3.1.取出变化的范围
        let colorDelta = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1, kSelectColor.2 - kNormalColor.2)
        
        // 3.2.变化sourceLabel
        sourceLabel.textColor = UIColor(r: CGFloat(kSelectColor.0 - colorDelta.0 * progress), g: CGFloat(kSelectColor.1 - colorDelta.1 * progress), b: CGFloat(kSelectColor.2 - colorDelta.2 * progress))
        
        // 3.2.变化targetLabel
        targetLabel.textColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        
        // 4.记录最新的index
        currentIndex = targetIndex
    }
}


