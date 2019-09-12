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

    private let oneImageSize = PublishSubject<CGSize>()
    
    let needReloadRow = PublishSubject<Bool>()
    
    var images:[String]? {
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
//                let kfManager = KingfisherManager.shared
//                // 通过manager 获取cache
//                let cache = kfManager.cache'
                
                //临时图片
                let icon_index:Int = Int(arc4random() % 9)
                let url = URL(string: BaiduImages[icon_index])
                
                
                singleImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: {result in
                    _ = result.map({[weak self] imageResult in
                        
                        self!.oneImageSize.onNext(CGSize(width: imageResult.image.size.width, height: imageResult.image.size.height))
                        
                        //更新完图片大小之后，发送需要刷新的信号
                        self!.needReloadRow.onNext(true)
                    })
                })
            }
            
            
        }
    }
    lazy var singleImageView: UIImageView = {
        let iv = UIImageView.init()
        return iv
    }()
    
    lazy var sepView: UIView = {
        let v = UIView.init()
//        v.backgroundColor = UIColor.red
        return v
    }()
    
    
    
    let dis = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //先把view都创建出来，用隐藏的方式，比每次都创建好很多
        for index in 0..<9 {
            
            let keyView =  UIImageView.init()
            keyView.contentMode = .scaleToFill
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
            $0.width.height.equalTo(250)
        }
        
        self.addSubview(sepView)
        sepView.snp.makeConstraints{
            $0.top.equalTo(0).priority(999)
            $0.width.equalTo(100)
            $0.height.equalTo(1)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        oneImageSize.subscribe(onNext: {[weak self] size in
            let newSize = self!.resizeImage(size: size)
            let imgV = self?.singleImageView
            imgV?.snp.updateConstraints{
                $0.width.equalTo(newSize.width)
                $0.height.equalTo(newSize.height)
            }
            self!.sepView.snp.updateConstraints{
                $0.top.equalTo(newSize.height).priority(999)
            }
        }).disposed(by: dis)
    }
    
    func resizeImage(size:CGSize)->CGSize{
        let maxWidth:CGFloat = 250
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
