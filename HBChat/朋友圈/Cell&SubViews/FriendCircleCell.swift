//
//  FriendCircleCell.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/4.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class FriendCircleCell: UITableViewCell {
    
    //方形小图大小
    private let imageItemSize = 60
    
    var disposeBag = DisposeBag()
    
    /*
     * 防止重用！！！
     * 单元格重用时调用
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    //头像
    let headIconTap = UITapGestureRecognizer.init()
    lazy var headImageView: UIImageView = {
        let iv = UIImageView.init()
        iv.backgroundColor = UIColor.groupTableViewBackground
        iv.layer.cornerRadius = 3
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(headIconTap)
        return iv
    }()
    
    //名称
    let nameTap = UITapGestureRecognizer.init()
    lazy var nameLabel: UILabel = {
        let lb = UILabel.init()
        lb.textColor = GrayBlueColor
        lb.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lb.text = "name"
        lb.numberOfLines = 2
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(nameTap)

        return lb
    }()
    
    //文本
    lazy var contentLabel: UILabel = {
        let lb = UILabel.init()
        lb.textColor = UIColor.black
        lb.numberOfLines = 5
        lb.font = UIFont.systemFont(ofSize: 15)
        lb.text = "拉到附近阿卡丽"
        return lb
    }()
    
    lazy var allButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("全文", for: .normal)
        btn.setTitleColor(GrayBlueColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return btn
    }()
    
    //tableview对应下标
    var indexPath:IndexPath?

    
    //图片容器
    lazy var imageContainer: CircleImageContainView = {
        let ic = CircleImageContainView.init()
        return ic
    }()
    
    //分享容器
    lazy var sharedView: CircleShareView = {
        let sv = CircleShareView.init()
        return sv
    }()
    
    //时间+分享来源
    lazy var infoLabel: UILabel = {
        let lb = UILabel.init()
        lb.textColor = UIColor.lightGray
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.text = "1小时前"
        return lb
    }()
    
    //更多按钮 触发点赞评论
    lazy var moreButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "circle_more"), for: .normal)
        btn.backgroundColor = UIColor.init(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        btn.layer.cornerRadius = 7
        return btn
    }()
    
    lazy var topArrow: UIImageView = {
        let topArrow = UIImageView.init(image: UIImage.init(named: "circle_top_arrow"))
        return topArrow
    }()
    //点赞
    lazy var likeView: CircleLikeView = {
        let clv = CircleLikeView.init()
        return clv
    }()
    
    lazy var sepLine: UIView = {
        let v = UIView.init()
        v.backgroundColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1)
        return v
    }()
    
    //评论
    lazy var commentsView: CircleCommentsView = {
        let cv = CircleCommentsView.init()
        return cv
    }()
    
    
    
    var model: CircleItem? {
        
        didSet {
            guard let model = model else {return}
            nameLabel.text = model.name
            contentLabel.text = model.textContent
            allButton.isHidden = !(model.showAllBtn!)
            headImageView.kf.setImage(with: URL(string: model.imageUrl!))
            
            
            allButton.snp.updateConstraints{
                $0.height.equalTo(model.showAllBtn == true ? 20 : 0)
            }
            
            if model.isOpen == true {
                self.allButton.setTitle("收起", for: .normal)
                contentLabel.numberOfLines = 0
            }else{
                self.allButton.setTitle("全文", for: .normal)
                contentLabel.numberOfLines = 5
            }
            allButton.snp.updateConstraints{
                $0.height.equalTo(allButton.isHidden==true ? 0:20)
            }
            if model.isShare == false{
                imageContainer.images = model.imgs
                infoLabel.text = "1小时前"
            }else{
                imageContainer.images = []
                sharedView.shareInfo = model.shareInfo
                infoLabel.text = "1小时前  " + (model.shareInfo?.shareSource)!
            }
            sharedView.isHidden = !(model.isShare!)
            sharedView.snp.updateConstraints{
                $0.height.equalTo(model.sharedViewHeight)
            }
            
            likeView.likes = model.likeArr
            commentsView.comments = model.comments
            
            switch model.state {
            case .none:
                self.topArrow.isHidden = true
                self.sepLine.isHidden = true
                commentsView.snp.updateConstraints{
                    $0.top.equalTo(sepLine.snp.bottom).offset(0.5)
                }
                topArrow.snp.updateConstraints{
                    $0.top.equalTo(infoLabel.snp.bottom).offset(0)
                    $0.height.equalTo(1)
                }
            case .like:
                self.topArrow.isHidden = false
                self.sepLine.isHidden = true
                commentsView.snp.updateConstraints{
                    $0.top.equalTo(sepLine.snp.bottom).offset(0.5)
                }
                topArrow.snp.updateConstraints{
                    $0.top.equalTo(infoLabel.snp.bottom).offset(5)
                    $0.height.equalTo(8)
                }
            case .comment:
                self.topArrow.isHidden = false
                self.sepLine.isHidden = true
                commentsView.snp.updateConstraints{
                    $0.top.equalTo(sepLine.snp.bottom).offset(-0.5)
                }
                topArrow.snp.updateConstraints{
                    $0.top.equalTo(infoLabel.snp.bottom).offset(5)
                    $0.height.equalTo(8)
                }
            case .all:
                self.topArrow.isHidden = false
                self.sepLine.isHidden = false
                commentsView.snp.updateConstraints{
                    $0.top.equalTo(sepLine.snp.bottom).offset(0.5)
                }
                topArrow.snp.updateConstraints{
                    $0.top.equalTo(infoLabel.snp.bottom).offset(5)
                    $0.height.equalTo(8)
                }
            }
           
        }
       
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = .white
       
        layoutViews()
        


    }
    
    
    private func layoutViews(){
        contentView.addSubview(headImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(allButton)
        contentView.addSubview(imageContainer)
        contentView.addSubview(sharedView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(moreButton)
        contentView.addSubview(topArrow)
        contentView.addSubview(likeView)
        contentView.addSubview(sepLine)
        contentView.addSubview(commentsView)
        
        headImageView.snp.makeConstraints{
            $0.left.top.equalTo(10)
            $0.width.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints{
            $0.top.equalTo(12)
            $0.left.equalTo(headImageView.snp.right).offset(10)
            $0.right.equalTo(-10)
            
        }
        contentLabel.snp.makeConstraints{
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalTo(nameLabel.snp.right)
        }
        allButton.snp.makeConstraints{
            $0.left.equalTo(nameLabel.snp.left)
            $0.top.equalTo(contentLabel.snp.bottom).offset(5)
            $0.height.equalTo(20)
        }
        
        imageContainer.snp.makeConstraints{
            $0.top.equalTo(allButton.snp.bottom).offset(10)
            $0.left.equalTo(nameLabel.snp.left)
            $0.width.equalTo(250)
        }
        sharedView.snp.makeConstraints{
            $0.top.equalTo(imageContainer.snp.bottom)
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalTo(-10)
            $0.height.equalTo(60)
        }
        
        infoLabel.snp.makeConstraints{
            $0.top.equalTo(sharedView.snp.bottom).offset(10)
            $0.left.equalTo(nameLabel.snp.left)
        }
        moreButton.snp.makeConstraints{
            $0.centerY.equalTo(infoLabel)
            $0.right.equalTo(-10)
            $0.width.equalTo(30)
            $0.height.equalTo(23)
            
        }
        topArrow.snp.makeConstraints{
            $0.top.equalTo(infoLabel.snp.bottom).offset(5)
            $0.left.equalTo(nameLabel).offset(20)
            $0.height.equalTo(8)
            $0.width.equalTo(16)
        }

        likeView.snp.makeConstraints{
            $0.top.equalTo(topArrow.snp.bottom)
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalTo(-10)
            
        }
        sepLine.snp.makeConstraints{
            $0.top.equalTo(likeView.snp.bottom)
            $0.left.equalTo(nameLabel.snp.left)
            $0.right.equalTo(-10)
            $0.height.equalTo(0.5)
        }
        commentsView.snp.makeConstraints{
            $0.top.equalTo(sepLine.snp.bottom).offset(0.5)
            $0.left.right.equalTo(likeView)
            $0.bottom.equalTo(-10)
        }

    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
