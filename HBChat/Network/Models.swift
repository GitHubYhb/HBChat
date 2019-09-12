//
//  Models.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/8/22.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import Foundation
import HandyJSON
import RxSwift

struct FriendsData:HandyJSON {
    var code: Int = 0
    var msg:String?
    var friends:[Friend]?
}
struct Friend :HandyJSON {
 
    var name:String?
    var photo:String?
    var decs:String?
    
}
struct FriendsCircleData:HandyJSON {
    var code: Int = 0
    var msg:String?
    var data:[CircleItem]?
}
struct CircleItem :HandyJSON {
    
    var name:String?
    var imageUrl:String?
    var textContent:String?
    var imgs:[String]?
    var comments:[CircleComment]?
    var isShare:Bool?
    var shareIcon:String?
    var shareContent:String?
    var shareSource:String?
    var likeArr:[CircleLike]?
    var showAllBtn:Bool?{
        get{
            let height:CGFloat = (textContent?.heightWithFont(font: UIFont.systemFont(ofSize: 15), fixedWidth: UIScreen.main.bounds.size.width - 70))!
            return height > 90
        }
    }
    var isOpen:Bool = false
    
    var imgRow:Int{
        get{
            let imgCount = imgs!.count
            var row = 0
            if imgCount>0 && imgCount<=3{
                row = 1
            }else if imgCount>3 && imgCount<=6{
                row = 2
            }else if imgCount>6 && imgCount<=9 {
                row = 3
            }else{
                row = 0
            }
            return row
        }
    }
    var imgContainerHeight:Int{
        get{
            var height:Int = 0
            if imgRow > 0 {
                height = imgRow*80 + (imgRow-1)*5
            }else{
                height = 0
            }
            if isShare == true {
                height = 0
            }
            
            return height
        }
    }
    var sharedViewHeight:Int{
        get{
            var height:Int = 0
            if isShare == true {
                height = 60
            }else{
                height = 0
            }
            return height
        }
    }
    
    enum LikeCommentState {
        case none
        case like
        case comment
        case all
    }
    var state:LikeCommentState{
        get {
            let likeCount = likeArr?.count ?? 0
            let commentCount = comments?.count ?? 0
            if likeCount == 0 && commentCount == 0{
                return .none
            }else if likeCount > 0 && commentCount == 0{
                return .like
            }else if likeCount == 0 && commentCount > 0{
                return .comment
            }else{
                return .all
            }
            
        }
    }
}
struct CircleComment:HandyJSON {
    var comment:String?
    var comment_id:String?
    var comment_name:String?
    var have_reply:Bool?
    var reply_name:String?
    var reply_user_id:String?
    var user_id:String?
}
struct CircleLike:HandyJSON {
   var name:String?
   var user_id:String?
}



struct jsonTest:HandyJSON {
    var data:cat?
}
struct cat:HandyJSON {
    var name:String?
    var age:String?
    var color:String?
}
