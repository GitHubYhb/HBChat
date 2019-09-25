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
    
    //MARK: 头部视图
    lazy var titleView: FriendCircleTitleView = {
        let tv = FriendCircleTitleView.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth+50))
        return tv
    }()
    
    lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: view.bounds, style: .plain)
        tb.rowHeight = UITableView.automaticDimension
        tb.register(FriendCircleCell.self, forCellReuseIdentifier: "testCellID")
        tb.backgroundColor = UIColor.white
        tb.delegate = self
        tb.dataSource = self
        tb.tableHeaderView = titleView
        return tb
    }()
    
    //MARK: 评论输入框
    lazy var commentInputView: CircleCommentInputView = {
        let iv = CircleCommentInputView.init()
        return iv
    }()
    
    //MARK: 图片预览
    lazy var imageViewer: HBImageViewer = {
        let iv = HBImageViewer.init(frame: UIScreen.main.bounds)
        iv.isHidden = true
        return iv
    }()
    
    let viewModel = FriendCircleViewModel.init()
    
    var dataSource = Array<CircleItem>()
    
    var commentAndLike = CircleCommentBtns()
    
    var inputRecorder = Dictionary<IndexPath,String>()
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    var selectedComment = CircleComment()
    
    var currentRowInputedText = PublishSubject<String>()
    
    var keyboardHeight:CGFloat = 0
    
    var isReply = false
    
    var isReload = false
    
    var isLoadMore = false
    
    var barImageView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = NavColor
        self.barImageView = self.navigationController?.navigationBar.subviews.first
        
        setupViews()
        
        setupActions()
        
        tableView.addRefresh(headerBlock: { [weak self] in
            self?.viewModel.getCircleData()
        }, footerBlock: {  [weak self] in
            self?.isLoadMore = true
            self?.viewModel.getCircleData()
        })
//        tableView.addRefresh {
//            self?.viewModel.getCircleData()
//        }
//        
    }
    
    func setupViews(){
        
        view.addSubview(tableView)
        view.addSubview(commentAndLike)
        view.addSubview(commentInputView)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(imageViewer)
      
        //MARK: tableView布局
        tableView.snp.makeConstraints{
            $0.top.equalTo(-148)
            $0.left.right.bottom.equalToSuperview()
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
            $0.bottom.equalTo(100)
            $0.right.left.equalToSuperview()
        }
        
        
        
        //MARK: 当前输入框文本绑定
        currentRowInputedText.bind(to: commentInputView.textInputView.rx.text).disposed(by: disposeBag)
        
    }
    
    func setupActions(){
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "circle_camera_white"), style: .done, target: self, action: #selector(scroll))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "circle_back"), style: .done, target: self, action: #selector(reload))
        
        //MARK: 订阅列表数据
        viewModel.circleData.subscribe(onNext: { [unowned self](items) in
            if self.titleView.isLoading == true {
                self.titleView.hideLoading()
            }
            
            if self.isLoadMore == true {
                var indexPaths = [IndexPath]()
                for index in 0..<items.count {
                    let item = items[index]
                    self.dataSource.append(item)
                    
                    let row = self.dataSource.count-1
                    let newIndexPath = IndexPath(row: row, section: 0)
                    indexPaths.append(newIndexPath)
                }
                self.tableView.insertRows(at: indexPaths, with: .none)
            }else{
                self.dataSource = items
                self.tableView.reloadData()
            }
            self.isLoadMore = false
            
        }).disposed(by: disposeBag)
        
        //MARK: 评论按钮点击
        commentAndLike.commentBtn.rx.tap.subscribe(onNext: {[unowned self] ob in
            self.isReply = false
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

        //MARK: 输入框点击发送
        commentInputView.sendSubject.subscribe(onNext: {[weak self] str in
            if str.count > 0 {
                //清空记录
                self?.commentInputView.textInputView.text = ""
                self?.inputRecorder.removeValue(forKey: self!.selectedIndexPath)
                let cell:FriendCircleCell = self!.tableView.cellForRow(at: self!.selectedIndexPath) as! FriendCircleCell
                var model = cell.model
                // 模拟数据
                var newComment = CircleComment()
                newComment.comment_name = "评论人"
                newComment.comment_id = "999"
                newComment.user_id = "233"
                newComment.comment = str
                if self!.isReply == true {
                    newComment.reply_name = self!.selectedComment.comment_name
                    newComment.reply_user_id = self!.selectedComment.user_id
                    newComment.have_reply = true
                }
                model?.comments?.append(newComment)
                self!.dataSource[self!.selectedIndexPath.row] = model!
                self!.tableView.reloadRows(at: [self!.selectedIndexPath], with: .none)
                
            }
        }).disposed(by: disposeBag)
        
        //MARK: 输入视图高度改变
        commentInputView.viewHeight.subscribe(onNext: {[unowned self] height in
            let currentOffset = self.tableView.contentOffset
            var newOffset = CGPoint.init(x: currentOffset.x, y: currentOffset.y - height.0)
            if self.commentInputView.textInputView.isFirstResponder{
                let offset = self.getOffset(indexPath: self.selectedIndexPath)
                if offset < 0 {
                    newOffset = CGPoint.init(x: currentOffset.x, y: currentOffset.y - height.1)
                }else{
                    newOffset = currentOffset
                }
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
                if height != 0 {
                    self!.view.setNeedsUpdateConstraints()
                    UIView.animate(withDuration: 0.2, animations: {
                        self!.commentInputView.snp.updateConstraints{ $0.bottom.equalTo(height) }
                        self!.view.layoutIfNeeded()
                    })
                }
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
        inputRecorder.removeAll()
        viewModel.getCircleData()
    }
    
    //MARK: 调整offset
    func adjustOffset(indexPath:IndexPath) {
        //偏差值
        let offset = getOffset(indexPath: indexPath)
        if offset<0 || indexPath.row != 0 {//大于0的时候，cell高度+键盘都没有屏幕高 
            let currentOffset = tableView.contentOffset
            let newOffset = CGPoint.init(x: currentOffset.x, y: currentOffset.y - offset)
            tableView.setContentOffset(newOffset, animated: true)
        }
    }
    func getOffset(indexPath:IndexPath) -> CGFloat {
        let cell = tableView.cellForRow(at: indexPath)
        //tableview高度
        let viewHeight = self.tableView.frame.size.height
        print(viewHeight)
        //当前cell 的 位置
        let rect = cell!.convert(cell!.bounds, to: self.view!)
        //输入框高度
        let inputHeight = self.commentInputView.frame.size.height
        //偏差值
        let offset = viewHeight - rect.maxY - keyboardHeight - inputHeight - 148
        
        return offset
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
        //MARK: 头像点击
        cell.headIconTap.rx.event.subscribe(onNext: {[weak self] tap in
            print(cell.model?.name as Any)
            self?.toFriend(user_id: "110")
        }).disposed(by: cell.disposeBag)
        
        //MARK: 人名点击
        cell.nameTap.rx.event.subscribe(onNext: {[weak self] tap in
            print(cell.model?.name as Any)
            self?.toFriend(user_id: "110")
        }).disposed(by: cell.disposeBag)
        
        
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
        cell.commentsView.toComment.subscribe(onNext: { [weak self] commentItem in
            print("评论ID == " + commentItem.comment_id!)
            self?.isReply = true
            self?.selectedIndexPath = indexPath
            //记录选中的评论的ID
            self?.selectedComment = commentItem
            
            self?.commentInputView.textInputView.becomeFirstResponder()
            
            self?.adjustOffset(indexPath: indexPath)
        }).disposed(by: cell.disposeBag)
        
        //MARK:图片点击
        cell.imageContainer.imageTapObserver.subscribe(onNext: {[unowned self] tap in
            let imgV:UIImageView = tap.view as! UIImageView
            self.imageViewer.showWithView(imageV: imgV)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < -160 {
            titleView.showLoading()
        }
        
        var delta = scrollView.contentOffset.y / CGFloat(150)
        delta = CGFloat.maximum(delta, 0)
        self.barImageView?.alpha = CGFloat.minimum(delta, 1)
        
        if delta > 1 {
            self.navigationController?.navigationBar.tintColor = .black
            self.title = "朋友圈"
        }else{
            self.navigationController?.navigationBar.tintColor = .white
            self.title = ""
        }
    }
}
