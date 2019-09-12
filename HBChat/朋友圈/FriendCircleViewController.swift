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
    
    var currentRowInputedText = PublishSubject<String>()
    
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
        //        viewModel.circleData.bind(to: tableView.rx.items){(tableView,index,item) in
        //            let identity = "testCellID"
        //            let cell:FriendCircleCell = tableView.dequeueReusableCell(withIdentifier: identity) as! FriendCircleCell
        //            cell.index = index
        //            cell.model = item
        //            cell.returnIndex = { index in
        //                print(index)
        //                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        //            }
        //            return cell
        //        }.disposed(by: disposeBag)
        
        //MARK: 评论输入布局
        commentInputView.snp.makeConstraints{
            $0.bottom.equalTo(50)
            $0.right.left.equalToSuperview()
        }
        
        currentRowInputedText.bind(to: commentInputView.textInputView.rx.text).disposed(by: disposeBag)

        
    }
    
    func setupActions(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "scroll", style: .done, target: self, action: #selector(scroll))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "reload", style: .done, target: self, action: #selector(reload))
        
        //MARK: 订阅列表数据
        viewModel.circleData.subscribe(onNext: { [weak self](items) in
            self?.dataSource = items
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        //MARK: 评论按钮点击
        commentAndLike.commentBtn.rx.tap.subscribe(onNext: {[weak self] ob in
            self?.commentAndLike.dismiss(reshow: false, newRect: CGRect.zero)
            self?.commentInputView.textInputView.becomeFirstResponder()
            
            //发送输入记录
            self?.currentRowInputedText.onNext(self?.inputRecorder[self!.selectedIndexPath] ?? "" )
            
        }).disposed(by: disposeBag)
        
        //MARK: 点赞按钮点击
        commentAndLike.likeBtn.rx.tap.subscribe(onNext: { [weak self] ob in
            self?.commentAndLike.dismiss(reshow: false, newRect: CGRect.zero)
        }).disposed(by: disposeBag)
        
        //MARK: 输入框结束输入
        commentInputView.textInputView.rx.didEndEditing.subscribe(onNext: {[weak self] ob in
            guard (self?.commentInputView.textInputView.text.count)! > 0 else {
                return
            }
            //记录输入内容
            self?.inputRecorder[self!.selectedIndexPath] = self?.commentInputView.textInputView.text
            
        }).disposed(by: disposeBag)
        
        //MARK:滑动隐藏键盘 和 按钮
        tableView.rx.willBeginDragging.subscribe(onNext: {[weak self] bool in
            if self?.commentAndLike.isShowing == true{
                self?.commentAndLike.dismiss(reshow: false, newRect: CGRect.zero)
            }
            self!.view.endEditing(true)
        }).disposed(by: disposeBag)
        
        //MARK:键盘高度监听
        RxKeyboard.instance.frame
            .drive(onNext: {[weak self] frame in
                print(frame)
                let y = frame.origin.y
                var height = frame.size.height
                if y != kScreenHeight {
                    height = -height
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
    
}


//MARK:UITableViewDelegate,UITableViewDataSource
extension FriendCircleViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identity = "testCellID"
        let cell:FriendCircleCell = tableView.dequeueReusableCell(withIdentifier: identity) as! FriendCircleCell
        cell.model = self.dataSource[indexPath.row]
        cell.indexPath = indexPath
        cell.allButtonClickBlock = { [weak self] index in
            //交换数据
            self?.dataSource[index.row]  = cell.model ?? CircleItem()
            UIView.performWithoutAnimation {//取消刷新动画
                tableView.reloadRows(at: [index], with: .none)
            }
        }
        cell.moreButtonClickBlock = { [weak self] index in
            //标记要评论或者点赞的 indexPath
            self?.selectedIndexPath = index
            let window = UIApplication.shared.delegate?.window
            let rect = cell.moreButton.convert(cell.moreButton.bounds, to: window!)
            self?.commentAndLike.showOrHideInRect(rect: rect, indexPath: indexPath)
        }
        
        //单张图刷新
        cell.imageContainer.needReloadRow.subscribe(onNext: { bool in
            UIView.performWithoutAnimation {//取消刷新动画
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }).disposed(by: disposeBag)
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
}
