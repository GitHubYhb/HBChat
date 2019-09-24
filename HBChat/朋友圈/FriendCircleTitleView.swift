//
//  FriendCircleTitleView.swift
//  HBChat
//
//  Created by 尤鸿斌 on 2019/9/24.
//

import UIKit

class FriendCircleTitleView: UIView {

    
    // 屏幕宽 + 150 左右
    
    lazy var titleImageView: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "catelina"))
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var userHeadImage: UIImageView = {
        let iv = UIImageView.init()
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .gray
        iv.layer.cornerRadius = 10
//        iv.image = UIImage.init(named: "catelina")
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let lb = UILabel.init()
        lb.textColor = .white
        lb.text = "用户名 、"
        lb.textAlignment = .right
        lb.font = .systemFont(ofSize: 17, weight: .heavy)
        return lb
    }()
    
    lazy var loadingView: UIImageView = {
        let iv = UIImageView.init(image: UIImage.init(named: "circle_icon"))
        return iv
    }()
    
    var isLoading = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(titleImageView)
        addSubview(userHeadImage)
        addSubview(nameLabel)
        addSubview(loadingView)
        
        titleImageView.snp.makeConstraints{
            $0.top.left.equalToSuperview()
            $0.width.height.equalTo(kScreenWidth)
        }
        
        userHeadImage.snp.makeConstraints{
            $0.top.equalTo(kScreenWidth - 50)
            $0.right.equalTo(-15)
            $0.width.height.equalTo(75)
        }
        nameLabel.snp.makeConstraints{
            $0.top.equalTo(kScreenWidth-30)
            $0.right.equalTo(userHeadImage.snp.left).offset(-10)
            $0.left.equalTo(15)
        }
        
        loadingView.snp.makeConstraints{
            $0.top.equalTo(-200)
            $0.left.equalTo(30)
            $0.width.height.equalTo(30)
        }
    }
    
    func showLoading() {
        isLoading = true

        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingView.snp.updateConstraints{$0.top.equalTo(168)}
            self.layoutIfNeeded()
        })
        
        let rotate = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotate.toValue = NSNumber.init(value: Double.pi * 6)
        rotate.duration = 2
        rotate.isCumulative = true
        rotate.repeatCount = 1
        loadingView.layer.add(rotate, forKey: "rotationAnimation")
        
        self.perform(#selector(hideLoading), with: nil, afterDelay: 2)
    }
    @objc func hideLoading() {
        self.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingView.snp.updateConstraints{$0.top.equalTo(-100)}
            self.layoutIfNeeded()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("titleView error")
    }

}
