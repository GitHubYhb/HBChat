//
//  CircleLikeView.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/11.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import YYText

class CircleLikeView: UIView {

    private lazy var likeLabel: YYLabel = {
        let lb = YYLabel.init()
        lb.numberOfLines = 0
        lb.highlightTapAction = { (view, attr, range, rect) in
            let high:YYTextHighlight = attr.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) as! YYTextHighlight
            //self.jumpToUser.onNext(high.userInfo!["user_id"] as! String)
            
            print(high.userInfo!["user_id"]!)
        }
        return lb
    }()
    
    
    var likes:[CircleLike]?{
        didSet{
            guard let likeArr = self.likes else {return}
            guard likeArr.count > 0 else {
//                self.isHidden = true
                likeLabel.snp.updateConstraints{
                    $0.top.equalTo(0)
                    $0.height.equalTo(0)
                }
                return
            }

            
            
            
            let attr = self.appendLikeStr(arr: likeArr)
            
            //插入 ❤ 前缀
            let likeIcon = UIImageView.init(image: UIImage.init(named: "circle_like_head"))
            likeIcon.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
            let iconAttr = NSMutableAttributedString.yy_attachmentString(withContent: likeIcon, contentMode: .scaleAspectFit, attachmentSize: CGSize.init(width: 20, height: 16), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
            attr.insert(iconAttr, at: 0)

            likeLabel.attributedText = attr
            
            
            let container = YYTextContainer.init(size: CGSize(width: kScreenWidth - 80, height: kScreenHeight))
            let layout = YYTextLayout.init(container: container, text: attr)
            
            likeLabel.snp.updateConstraints{
                $0.top.equalTo(5)
                $0.height.equalTo((layout?.textBoundingSize.height)!)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.96, alpha:1)
        
        addSubview(likeLabel)
        
        likeLabel.snp.makeConstraints{
            $0.top.equalTo(5)
            $0.left.equalTo(5)
            $0.right.equalTo(-5)
            $0.height.equalTo(0)
            $0.bottom.equalTo(0)
        }
        
        
    }
    
    func appendLikeStr(arr:[CircleLike]) -> NSMutableAttributedString {
        let returnAttr = NSMutableAttributedString()
        
        for like in arr {
            let attr = NSMutableAttributedString.init(string: like.name!)
            attr.yy_font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            attr.yy_color = GrayBlueColor
            attr.yy_setTextHighlight(attr.yy_rangeOfAll(), color: GrayBlueColor, backgroundColor: UIColor.lightGray, userInfo: ["user_id":like.user_id ?? "110"])
            
            let dian = NSMutableAttributedString.init(string: "、")
            dian.yy_font = UIFont.systemFont(ofSize: 14, weight: .heavy)
            dian.yy_color = UIColor.black
            
            returnAttr.append(attr)
            returnAttr.append(dian)
            
            
        }
        return returnAttr
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
