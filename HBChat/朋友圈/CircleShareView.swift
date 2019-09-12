//
//  CircleShareView.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/6.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit

class CircleShareView: UIView {

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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.96, alpha:1)
        
        layoutViews()
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
