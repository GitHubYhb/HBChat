//
//  CircleShareView.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/6.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import RxSwift

class CircleShareView: UIView {

    var shareInfo:CircleShareInfo? {
        didSet{
            guard let info = self.shareInfo else {
                return
            }
            sharedIcon.kf.setImage(with: URL(string: info.shareIcon!))
            sharedLabel.text = info.shareContent
        }
    }
    
    lazy var sharedIcon: UIImageView = {
        let iv = UIImageView.init()
        iv.backgroundColor = UIColor.gray
        iv.contentMode = UIView.ContentMode.scaleAspectFit
        return iv
    }()
    
    lazy var sharedLabel: UILabel = {
        let lb = UILabel.init()
        lb.textColor = UIColor.darkGray
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.text = "这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容这是分享内容"
        lb.numberOfLines = 2
        return lb
    }()
    
    let toUrl = PublishSubject<String>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.96, alpha:1)
        
        layoutViews()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapShare))
        self.addGestureRecognizer(tap)
    }
    @objc func tapShare(){
        self.toUrl.onNext(self.shareInfo!.shareUrl!)
    }
    func layoutViews(){
        addSubview(sharedIcon)
        addSubview(sharedLabel)
        
        sharedIcon.snp.makeConstraints{
            $0.top.left.equalTo(7)
            $0.width.height.equalTo(46)
        }
        
        sharedLabel.snp.makeConstraints{
            $0.centerY.equalTo(sharedIcon)
            $0.left.equalTo(sharedIcon.snp.right).offset(10)
            $0.right.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("CircleShareView erro")
    }

}
