//
//  FriendCircleViewController.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/4.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard


class FriendCircleViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: view.bounds, style: .plain)
        tb.rowHeight = UITableView.automaticDimension
        tb.register(FriendCircleCell.self, forCellReuseIdentifier: "testCellID")
        tb.backgroundColor = UIColor.white
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    lazy var commentInputView: CircleCommentInputView = {
        let iv = CircleCommentInputView.init()
        return iv
    }()
    
    let viewModel = FriendCircleViewModel.init()
    
    var dataSource = Array<CircleItem>()
    
    var commentAndLike = CircleCommentBtns()
    
    var inputRecorder = Dictionary<IndexPath,String>()
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    var selectedCommentID = ""
    
    var currentRowInputedText = PublishSubject<String>()
    
    var keyboardHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        setupActions()
    }
    func setupViews(){
        
        title = "朋友圈"
        view.addSubview(tableView)
        view.addSubview(commentAndLike)
        view.addSubview(commentInputView)
        
      
        //MARK: tableView布局
        tableView.snp.makeConstraints{
            $0.top.left.right.bottom.equalToSuperview()
        }
        //MARK: 点赞、评论布局
        commentAndLike.snp.makeConstraints{
            $0.centerY.equalTo(120)
            $0.right.equalTo(-10)
            $0.width.equalTo(0)
            $0.height.equalTo(40)
        }
        
        //MARK: 评论输入布局
        commentInputView.snp.makeConstraints{
            $0.bottom.equalTo(0)
            $0.right.left.equalToSuperview()
        }
        
        currentRowInputedText.bind(to: commentInputView.textInputView.rx.text).disposed(by: disposeBag)
        
    }
    
    func setupActions(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "scroll", style: .done, target: self, action: #selector(scroll))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "reload", style: .done, target: self, action: #selector(reload))
        
        //MARK: 订阅列表数据
        viewModel.circleData.subscribe(onNext: { [unowned self](items) in
            self.dataSource = items
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        //MARK: 评论按钮点击
        commentAndLike.commentBtn.rx.tap.subscribe(onNext: {[unowned self] ob in
            self.commentAndLike.dismiss(reshow: false, newRect: CGRect.zero)
            self.commentInputView.textInputView.becomeFirstResponder()
            
            //发送输入记录
            self.currentRowInputedText.onNext(self.inputRecorder[self.selectedIndexPath] ?? "" )
            self.adjustOffset(indexPath: self.selectedIndexPath)

        }).disposed(by: disposeBag)
        
        //MARK: 点赞按钮点击
        commentAndLike.likeBtn.rx.tap.subscribe(onNext: { [unowned self] ob in
            self.commentAndLike.dismiss(reshow: false, newRect: CGRect.zero)
        }).disposed(by: disposeBag)
        
        
        //MARK: 输入框结束输入
        commentInputView.textInputView.rx.didEndEditing.subscribe(onNext: {[unowned self] ob in
            guard self.commentInputView.textInputView.text.count > 0 else {
                return
            }
            //记录输入内容
            self.inputRecorder[self.selectedIndexPath] = self.commentInputView.textInputView.text
            
        }).disposed(by: disposeBag)
        
        //MARK: 输入视图高度改变
        commentInputView.viewHeight.subscribe(onNext: {[unowned self] height in
            let currentOffset = self.tableView.contentOffset
            var newOffset = CGPoint.init(x: currentOffset.x, y: currentOffset.y - height.0)
            if self.commentInputView.textInputView.isFirstResponder{
                newOffset = CGPoint.init(x: currentOffset.x, y: currentOffset.y - height.1)
            }
            
            self.tableView.setContentOffset(newOffset, animated: true)
        }).disposed(by: disposeBag)

        //MARK:滑动隐藏键盘 和 按钮
        tableView.rx.willBeginDragging.subscribe(onNext: {[unowned self] bool in
            if self.commentAndLike.isShowing == true{
                self.commentAndLike.dismiss(reshow: false, newRect: CGRect.zero)
            }
            self.view.endEditing(true)
        }).disposed(by: disposeBag)
        
        
        
        //MARK:键盘高度监听
        RxKeyboard.instance.frame
            .drive(onNext: {[weak self] frame in
                let y = frame.origin.y
                var height = frame.size.height
                self?.keyboardHeight = height
                if y != kScreenHeight {
                    height = -height
                }
                //初始化的时候键盘高度是0
                if height == 0 {
                    height = 300
                }
                self!.view.setNeedsUpdateConstraints()
                UIView.animate(withDuration: 0.2, animations: {
                    self!.commentInputView.snp.updateConstraints{ $0.bottom.equalTo(height) }
                    self!.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
        
    }
    
    
    //MARK:点击隐藏键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func scroll(){
        tableView.scrollToRow(at: IndexPath(row: dataSource.count-1, section: 0), at: .none, animated: true)
    }
    @objc func reload(){
        viewModel.getCircleData()
    }
    func adjustOffset(indexPath:IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let viewHeight = self.tableView.frame.size.height
        
        let rect = cell!.convert(cell!.bounds, to: self.view!)
        
        let offset = viewHeight - rect.maxY - keyboardHeight - 56
        let currentOffset = tableView.contentOffset
        let newOffset = CGPoint.init(x: currentOffset.x, y: currentOffset.y - offset)
        tableView.setContentOffset(newOffset, animated: true)
        
    }
    
    
    //MARK:界面跳转
    func toFriend(user_id:String) {
        let friend = FriendViewController()
        friend.user_id = user_id
        self.navigationController?.pushViewController(friend, animated: true)
    }
    
    func toWeb(url:String) {
        let web = ShareWebViewController()
        web.url = url
        self.navigationController?.pushViewController(web, animated: true)
        
    }
    
   
}


//MARK:UITableViewDelegate,UITableViewDataSource
extension FriendCircleViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identity = "testCellID"
        let cell:FriendCircleCell = tableView.dequeueReusableCell(withIdentifier: identity) as! FriendCircleCell
        cell.model = self.dataSource[indexPath.row]
        cell.indexPath = indexPath
        
        //MARK: 全文、收起事件
        cell.allButton.rx.tap.subscribe(onNext: {[weak self]  _ in
            cell.model?.isOpen = !cell.model!.isOpen
            //交换数据
            self?.dataSource[indexPath.row]  = cell.model ?? CircleItem()
            UIView.performWithoutAnimation {//取消刷新动画
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }).disposed(by: cell.disposeBag)
        
        //MARK: 点赞、评论事件
        cell.moreButton.rx.tap.subscribe(onNext: {[unowned self]  _ in
            self.view.endEditing(true)
            //标记要评论或者点赞的 indexPath
            self.selectedIndexPath = indexPath
            //            let window = UIApplication.shared.delegate?.window
            let rect = cell.moreButton.convert(cell.moreButton.bounds, to: self.view)
            self.commentAndLike.showOrHideInRect(rect: rect, indexPath: indexPath)
        }).disposed(by: cell.disposeBag)
        
        //MARK: 分享链接跳转事件
        cell.sharedView.tap.rx.event.subscribe(onNext: {[weak self] tap in
    
            print("分享连接跳转 == " + (cell.model?.shareInfo!.shareUrl)!)
        
            self?.toWeb(url: (cell.model?.shareInfo!.shareUrl)!)
        }).disposed(by: cell.disposeBag)
        
        //MARK:跳转点赞用户
        cell.likeView.toUser.subscribe(onNext: {[weak self] user_id in
            
            print("点赞用户ID == " + user_id)
            self?.toFriend(user_id: user_id)
            
        }).disposed(by: cell.disposeBag)
        
        //MARK:跳转评论用户
        cell.commentsView.toUser.subscribe(onNext: {[weak self] user_id in
            
            print("评论用户ID == " + user_id)
            self?.toFriend(user_id: user_id)
            
        }).disposed(by: cell.disposeBag)
        
        //MARK:回复评论
        cell.commentsView.toComment.subscribe(onNext: { [weak self] comment_id in
            print("评论ID == " + comment_id)
            //记录选中的评论的ID
            self?.selectedCommentID = comment_id
            
            self?.commentInputView.textInputView.becomeFirstResponder()
        }).disposed(by: cell.disposeBag)
        
        //单张图刷新
        cell.imageContainer.needReloadRow.subscribe(onNext: { bool in
            
            UIView.performWithoutAnimation {//取消刷新动画
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }).disposed(by: cell.disposeBag)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
}
