//
//  FriendCircleViewModel.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/9/4.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import RxSwift

class FriendCircleViewModel: NSObject {

    let disposeBag = DisposeBag()
    
    var circleData = PublishSubject<[CircleItem]>()
    override init() {
        super.init()
        getCircleData()
    }
    
    func getCircleData()  {
        APILoadingProvider.rx.request(.getFriendsCircle).asObservable().mapModel(FriendsCircleData.self).subscribe(onNext: {[weak self] FriendsCircleData in
            self?.circleData.onNext(FriendsCircleData.data!)
        }).disposed(by: disposeBag)
    }
    
}
