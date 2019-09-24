//
//  CircleImageContainView.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/5.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import Kingfisher

class CircleImageContainView: UIView {

    private let imageItemSize = 80
    
    private var imageViews = [UIImageView]()
    
    let needReloadRow = PublishSubject<Bool>()
    
    let imageTapObserver = PublishSubject<UITapGestureRecognizer>()
    
    var images:[CircleImage]? {
        didSet{
            guard let imgs = images else {
                return
            }
            guard imgs.count>0 else {
                singleImageView.isHidden = true
                for index in 0..<9 {
                    let imgV = imageViews[index]
                    imgV.isHidden = true
                }
                sepView.snp.updateConstraints{
                    $0.top.equalTo(0).priority(999)
                }
                return
            }
            let imgCount = imgs.count
            let imgVCount = imageViews.count
            
            
            //区分 1张与多张
            if imgCount != 1{
                singleImageView.isHidden = true
                //加载图片
                for index in 0..<imgCount {
                    let imgV = imageViews[index]
                    
                    //临时图片
                    let icon_index:Int = Int(arc4random() % 9)
                    let url = URL(string: BaiduImages[icon_index])
                    imgV.kf.setImage(with: url)
                    imgV.isHidden = false
                }
                //隐藏多余的imageview
                for index in imgCount..<imgVCount {
                    let imgV = imageViews[index]
                    imgV.isHidden = true
                }
                
                if imgCount>1{
                    var height = 250
                    if imgCount>1 && imgCount<=3{
                        height = 80
                    }else if imgCount>3 && imgCount<=6{
                        height = 170
                    }else if imgCount>6 && imgCount<=9{
                        height = 250
                    }
                    sepView.snp.updateConstraints{
                        $0.top.equalTo(height).priority(999)
                    }
                }
            }else{
                singleImageView.isHidden = false
                //隐藏所有方形图
                for index in 0..<9 {
                    let imgV = imageViews[index]
                    imgV.isHidden = true
                }
                
                //临时图片
                let urlStr = BaiduImages[0]
                let url = URL(string: urlStr)
                
                let kfManager = KingfisherManager.shared
                // 通过manager 获取cache
                let cache = kfManager.cache
                
                //下载完图片后，必有缓存
                if cache.isCached(forKey: urlStr) {
                    var img = cache.retrieveImageInMemoryCache(forKey: urlStr, options: nil)
                    if img == nil {
                        // 虽弃用但可用，如果放到block 里面会因为线程回调导致UI错误
                        img = cache.retrieveImageInDiskCache(forKey: urlStr)
                    }
                    let newSize = self.resizeImage(size: img?.size ?? CGSize(width: 0, height: 0 ),maxWidth: 250)
                    self.singleImageView.image = img
                    
                    self.singleImageView.snp.updateConstraints{
                        $0.width.equalTo(newSize.width)
                        $0.height.equalTo(newSize.height)
                    }
                    self.sepView.snp.updateConstraints{
                        $0.top.equalTo(newSize.height).priority(999)
                    }
                }else{
                    kfManager.downloader.downloadImage(with: url!, options: nil) { result in
                        
                        self.needReloadRow.onNext(true)
                    }
                }
            }
        }
    }
    lazy var singleImageView: UIImageView = {
        let iv = UIImageView.init()
        iv.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imageTap(tap:)))
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    lazy var sepView: UIView = {
        let v = UIView.init()
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //先把view都创建出来，用隐藏的方式，比每次都创建好很多
        for index in 0..<9 {
            
            let keyView =  UIImageView.init()
            keyView.contentMode = .scaleAspectFit
            keyView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(imageTap(tap:)))
            keyView.addGestureRecognizer(tap)
            self.addSubview(keyView)
            imageViews.append(keyView)
            keyView.snp.makeConstraints{ make in
                if index < 3{
                    make.top.equalTo(0)
                }else if index >= 3 && index < 6{
                    make.top.equalTo(5+imageItemSize)
                }else{
                    make.top.equalTo(10+imageItemSize*2)
                }
                if index%3 == 0 {
                    make.left.equalTo(0)
                }else if index%3 == 1 {
                    make.left.equalTo(5+imageItemSize)
                }else{
                    make.left.equalTo(10+imageItemSize * 2)
                }
                make.width.height.equalTo(imageItemSize)
            }
        }
        
        addSubview(singleImageView)
        singleImageView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.width.equalTo(250)
            $0.height.equalTo(250)
        }
        
        addSubview(sepView)
        sepView.snp.makeConstraints{
            $0.top.equalTo(0).priority(999)
            $0.width.equalTo(100)
            $0.height.equalTo(1)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

    }
    @objc func imageTap(tap:UITapGestureRecognizer) {
        imageTapObserver.onNext(tap)
    }
    
    func resizeImage(size:CGSize,maxWidth:CGFloat)->CGSize{
        
        var scale:CGFloat = 1
        var newWidth:CGFloat = maxWidth
        var newHeight:CGFloat = maxWidth
        
        if size.width != size.height{
            if size.width > size.height{
                scale = size.width/maxWidth
                newHeight = size.height/scale
            }
            if size.width < size.height{
                scale = size.height/maxWidth
                newWidth = size.width/scale
            }
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
