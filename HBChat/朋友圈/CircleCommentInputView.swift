//
//  CircleCommentInputView.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/12.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import RxSwift

/*
 * 评论输入框
 */
class CircleCommentInputView: UIView {

    lazy var faceButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_input_face"), for: .normal)
        return btn
    }()
    
    lazy var inputBackgroundView: UIView = {
        let v = UIView.init()
        v.backgroundColor = .white
        v.layer.cornerRadius = 3
        return v
    }()
    
    lazy var textInputView: UITextView = {
        let tv = UITextView.init()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: -15, right: 0)
        tv.returnKeyType = .send
        tv.delegate = self
        return tv
    }()
    
    let viewHeight = PublishSubject<(CGFloat,CGFloat)>()
    
    let sendSubject = PublishSubject<String>()
    
    var oldHeight:CGFloat = 56
    
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.98, green:0.98, blue:0.99, alpha:1)
        addSubview(faceButton)
        addSubview(inputBackgroundView)
        
        faceButton.snp.makeConstraints{
            $0.right.equalTo(-10)
            $0.bottom.equalTo(-10)
            $0.width.height.equalTo(40)
        }
        
        inputBackgroundView.addSubview(textInputView)
        
        inputBackgroundView.snp.makeConstraints{
            $0.left.equalTo(10)
            $0.right.equalTo(faceButton.snp.left).offset(-10)
            $0.top.equalTo(10)
            $0.bottom.equalTo(-10)
        }
        
        textInputView.snp.makeConstraints{
            $0.left.equalTo(5)
            $0.right.equalTo(-5)
            $0.top.equalTo(0)
            $0.height.equalTo(40).priority(990)
            $0.bottom.equalTo(0)
        }

        //监听输入框内容高度
        textInputView.rx.observe(CGSize.self, "contentSize").subscribe(onNext: {[unowned self] size in
            var height = size?.height ?? 0
            if height > 0{
                //最高300
                if height > 300{
                    height = 300
                }
                self.textInputView.snp.updateConstraints{
                    $0.height.equalTo(size!.height).priority(990)
                }
                self.viewHeight.onNext((height+20,self.oldHeight-height))
                self.oldHeight = height
            }
            
        }).disposed(by: disposeBag)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("input view error")
    }

}

extension CircleCommentInputView : UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textInputView.resignFirstResponder()
            sendSubject.onNext(textView.text)
            return false
        }
        return true
    }
}
