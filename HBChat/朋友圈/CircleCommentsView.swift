//
//  CircleCommentsView.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/6.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import YYText
import RxSwift
/*
 * 评论 点赞 
 */
class CircleCommentsView: UIView {
    
    let toUser = PublishSubject<String>()
    let toComment = PublishSubject<String>()
    
    private var commentLabels = [YYLabel]()
    
    var comments:[CircleComment]?{
        didSet{
            guard let comments = self.comments else {
                return
            }
            /*
             * 移除所有之前创建的label 防止复用的情况
             * 可优化的地方：不需要所有都移除，可以通过个数判断，复用即可。
             */
            if commentLabels.count > 0 {
                for lb in commentLabels {
                    lb.removeFromSuperview()
                }
                commentLabels.removeAll()
            }
            
            var top:CGFloat = 0
            for index in 0..<comments.count {
                let lb = YYLabel.init()
                let item = comments[index]
                lb.numberOfLines = 0
                lb.highlightTapAction = {[weak self] (view, attr, range, rect) in
                    let high:YYTextHighlight = attr.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) as! YYTextHighlight
                    
                    if high.userInfo!["user_id"] != nil {
                        print(high.userInfo!["user_id"] as Any)
                        self!.toUser.onNext(high.userInfo!["user_id"] as! String)
                    }
                    if high.userInfo!["comment_id"] != nil {
                        print(high.userInfo!["comment_id"] as Any)
                        self!.toComment.onNext(high.userInfo!["comment_id"] as! String)
                    }
                }
                
                addSubview(lb)
                commentLabels.append(lb)
                
                let attrTuple = self.setAttrattrTuple(item: item)
                lb.attributedText = attrTuple.attr
                lb.snp.makeConstraints{
                    $0.left.equalToSuperview().offset(5)
                    $0.right.equalToSuperview().offset(-5)
                    if index == 0{
                        $0.top.equalTo(5).priority(998)
                    }else{
                        $0.top.equalTo(top + 5).priority(998)
                    }
                    $0.height.equalTo(attrTuple.height).priority(997)
                    
                    if index == comments.count-1{
                        $0.bottom.equalTo(-5)
                    }
                }
                //手动计算top
                top = top + attrTuple.height + 5
            }
            
        }
    }
    private let container = YYTextContainer.init(size: CGSize(width: kScreenWidth - 80, height: CGFloat(MAXFLOAT)))

    //设置富文本 并且 计算高度 一并用元组放回
    func setAttrattrTuple(item:CircleComment) -> (attr:NSMutableAttributedString,height:CGFloat) {
        
        let returnAttr = NSMutableAttributedString()
        
        let name = NSMutableAttributedString.init(string: item.comment_name!)
        name.yy_font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        name.yy_color = GrayBlueColor
        name.yy_lineSpacing = 5
        name.yy_setTextHighlight(name.yy_rangeOfAll(), color: GrayBlueColor, backgroundColor: UIColor.lightGray, userInfo: ["user_id":item.user_id ?? "110"])

        returnAttr.append(name)
        
        if item.have_reply == true {
            let hf = NSMutableAttributedString.init(string: "回复")
            hf.yy_font = UIFont.systemFont(ofSize: 14)
            hf.yy_color = UIColor.black
            hf.yy_lineSpacing = 2
            returnAttr.append(hf)
            
            let reply_name = NSMutableAttributedString.init(string: item.reply_name!)
            reply_name.yy_font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            reply_name.yy_color = GrayBlueColor
            reply_name.yy_lineSpacing = 2
            reply_name.yy_setTextHighlight(reply_name.yy_rangeOfAll(), color: GrayBlueColor, backgroundColor: UIColor.lightGray, userInfo: ["user_id":item.reply_user_id ?? "110"])

            returnAttr.append(reply_name)
        }
        
        
        let mh = NSMutableAttributedString.init(string: "：")
        mh.yy_font = UIFont.systemFont(ofSize: 14)
        mh.yy_color = UIColor.black
        mh.yy_lineSpacing = 2
        returnAttr.append(mh)
        
        let desc = NSMutableAttributedString.init(string: item.comment!)
        desc.yy_font = UIFont.systemFont(ofSize: 14)
        desc.yy_color = UIColor.black
        desc.yy_lineSpacing = 2
        
        let decs_highlight = YYTextHighlight()
        desc.yy_setTextHighlight(decs_highlight, range: desc.yy_rangeOfAll())
        desc.yy_setTextHighlight(desc.yy_rangeOfAll(), color: UIColor.black, backgroundColor: UIColor.lightGray, userInfo: ["comment_id":item.comment_id ?? "130"])
        returnAttr.append(desc)
        
        returnAttr.yy_lineSpacing = 5
        
        let layout = YYTextLayout.init(container: container, text: returnAttr)
        return (returnAttr,(layout?.textBoundingSize.height)!)
    }
    
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.96, alpha:1)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("comments view error")
    }
}
