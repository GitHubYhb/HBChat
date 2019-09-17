//
//  CircleCommentBtns.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/6.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit


/*
 *
 * 评论、点赞按钮
 * 默认隐藏
 */
class CircleCommentBtns: UIView {

    lazy var commentBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("  评论", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setImage(UIImage.init(named: "circle_comment"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    lazy var likeBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("  赞", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setImage(UIImage.init(named: "circle_like"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    var isShowing:Bool = false
    
    var oldIndexPath:IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = UIColor(red:0.28, green:0.32, blue:0.33, alpha:1)
        layer.cornerRadius = 7
        
        addSubview(likeBtn)
        addSubview(commentBtn)
        
        let line = UIView.init()
        line.backgroundColor = UIColor(red:0.25, green:0.29, blue:0.29, alpha:1)
        addSubview(line)
        
        likeBtn.snp.makeConstraints{
            $0.bottom.left.top.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        commentBtn.snp.makeConstraints{
            $0.bottom.right.top.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
        line.snp.makeConstraints{
            $0.top.equalTo(10)
            $0.bottom.equalTo(-10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1)
        }
        
        isHidden = true
    }

    
    func showOrHideInRect(rect:CGRect,indexPath:IndexPath) {
        
        if isShowing == false{
            //记录index
            oldIndexPath = indexPath
            showInRect(rect: rect)
        }else{
            if indexPath == oldIndexPath{
                dismiss(reshow: false,newRect: CGRect.zero)
            }else{
                oldIndexPath = indexPath
                dismiss(reshow: true,newRect: rect)
            }
            
        }
    }
    
    func showInRect(rect:CGRect){
        isHidden = false
        isShowing = true
        
        superview!.setNeedsUpdateConstraints()
        snp.updateConstraints{
            $0.centerY.equalTo(rect.midY)
            $0.right.equalTo(-rect.width-15)
        }
        superview!.layoutIfNeeded()
        
        //只有改变宽度的时候做动画，移动位置不做动画
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.snp.updateConstraints{
                $0.width.equalTo(200)
            }
            self.superview!.layoutIfNeeded()
        }, completion: nil)
    }
    
    func dismiss(reshow:Bool,newRect:CGRect) {
        superview!.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.snp.updateConstraints{
                $0.width.equalTo(0)
            }
            self.superview!.layoutIfNeeded()
        }) { competition in
            if reshow == false{
                self.isHidden = true
                self.isShowing = false
            }else{
                self.showInRect(rect: newRect)
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error")
    }

}
