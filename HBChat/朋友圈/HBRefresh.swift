//
//  HBRefresh.swift
//  HBChat
//
//  Created by 尤鸿斌 on 2019/9/25.
//

import Foundation
import UIKit
import RxSwift

class HBRefresh {

    enum RefreshState {
        case none
        case refresh
        case loadmore
    }
    var refreshState:RefreshState = .none
    var loadmoreState:RefreshState = .none


     let disposeBag = DisposeBag()

    func refresh()  {
        if refreshState == .refresh {
            return
        }
        refreshState = .refresh
        
        let feedback = UIImpactFeedbackGenerator.init(style: .medium)
        feedback.impactOccurred()
    }
    func loadmore()  {
        if loadmoreState == .loadmore {
            return
        }
        self.footerBlock!()
        
        loadmoreState = .loadmore
        
        let feedback = UIImpactFeedbackGenerator.init(style: .medium)
        feedback.impactOccurred()
    }
    func reset(){
        loadmoreState = .none
    }


    typealias RefreshBlock = ()->Void
    fileprivate var headerBlock:RefreshBlock?
    fileprivate var footerBlock:RefreshBlock?


}

fileprivate enum RefreshState {
    case none
    case refresh
    case loadmore
    
}


extension UIScrollView{
    func addRefresh(headerBlock:@escaping ()->Void,footerBlock:@escaping ()->Void) {
        
        let refresh = HBRefresh()
        
        self.rx.observe(CGPoint.self, "contentOffset")
        .subscribe(onNext: { offset in
            let contentSize = self.contentSize
            
            let offsetY = offset!.y
            if offsetY < -160 {
                refresh.refresh()
            }else{
                refresh.refreshState = .none
            }
            
            
            let bottomOffset = contentSize.height - offsetY - kScreenHeight - 148
            if offsetY > 0 && bottomOffset < -64 {
                  refresh.loadmore()
            }
        }).disposed(by: refresh.disposeBag)
        
        self.rx.willBeginDragging.subscribe(onNext: { _ in
            refresh.refreshState = .none
        }).disposed(by: refresh.disposeBag)
        
        self.rx.didEndDragging.subscribe(onNext: { _ in
            
            if refresh.refreshState == .refresh{
                refresh.headerBlock!()
            }
            if refresh.loadmoreState == .loadmore{
                
            }
            refresh.loadmoreState = .none
        }).disposed(by: refresh.disposeBag)
        
        
        
        self.rx.didEndScrollingAnimation.subscribe(onNext: { _ in
            //停止动画的时候 重置刷新状态
            refresh.refreshState = .none
            
        }).disposed(by: refresh.disposeBag)
        
        refresh.headerBlock = headerBlock
        refresh.footerBlock = footerBlock
        
    }
    
   
}
