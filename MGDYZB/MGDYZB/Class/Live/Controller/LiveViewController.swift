//
//  LiveViewController.swift
//  MGDYZB
//
//  Created by i-Techsys.com on 17/2/25.
//  Copyright © 2017年 ming. All rights reserved.

//  简书：http://www.jianshu.com/users/57b58a39b70e/latest_articles
//  github:  https://github.com/LYM-mg


import UIKit

private let kTitlesViewH : CGFloat = 40

class LiveViewController: UIViewController {
    
    var isFirst: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        
        // 1.创建UI
        setUpMainView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - lazy
    fileprivate lazy var liveTitlesView: HomeTitlesView = { [weak self] in
        let titleFrame = CGRect(x: 0, y: 0, width: kScreenW, height: kTitlesViewH)
        let titles = ["全部","颜值", "体育频道","热门游戏","科技"]
        let tsView = HomeTitlesView(frame: titleFrame, titles: titles)
        tsView.deledate = self
        return tsView
        }()
    fileprivate lazy var liveContentView: HomeContentView = { [weak self] in
        // 1.确定内容的frame
        let contentH = kScreenH - kStatusBarH - kNavigationBarH
        let contentFrame = CGRect(x: 0, y: kStatusBarH + kNavigationBarH, width: kScreenW, height: contentH)
        
        // 2.确定所有的子控制器
        var childVcs = [UIViewController]()
        childVcs.append(AllListViewController())
        childVcs.append(AllListViewController())
        childVcs.append(AllListViewController())
        childVcs.append(AllListViewController())
        childVcs.append(AllListViewController())
        let contentView = HomeContentView(frame: contentFrame, childVcs: childVcs, parentViewController: self)
        contentView.delegate = self
        return contentView
    }()
}

// MARK: - 初始化UI
extension LiveViewController {
    fileprivate func setUpMainView() {
        setUpNavgationBar()
        view.addSubview(liveContentView)
    }
    fileprivate func setUpNavgationBar() {
        title = ""
        navigationController?.navigationBar.addSubview(liveTitlesView)
        liveTitlesView.backgroundColor = UIColor(r: 250, g: 250, b: 250, a: 0.6)
    }
}

// MARK:- 遵守 HomeTitlesViewDelegate 协议
extension LiveViewController : HomeTitlesViewDelegate {
    func HomeTitlesViewDidSetlected(_ homeTitlesView: HomeTitlesView, selectedIndex: Int) {
        liveContentView.setCurrentIndex(selectedIndex)
    }
}


// MARK:- 遵守 HomeContentViewDelegate 协议
extension LiveViewController : HomeContentViewDelegate {
    func HomeContentViewDidScroll(_ contentView: HomeContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        liveTitlesView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}