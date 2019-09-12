//
//  API.swift
//  SwiftLearning
//
//  Created by 尤鸿斌 on 2019/8/21.
//  Copyright © 2019 尤鸿斌. All rights reserved.
//

import UIKit
import Moya
import HandyJSON
import RxSwift


import SVProgressHUD

let LoadingPlugin = NetworkActivityPlugin { (type, target) in
    switch type {
    case .began:
        SVProgressHUD.dismiss()
        SVProgressHUD.show()
    case .ended:
        SVProgressHUD.dismiss()
    }
}

enum API {
    case getUserData(u_id : String)
    case getFriendList
    case jsonTest
    case getFriendsCircle
}

let timeoutClosure = {(endpoint : Endpoint , closure:MoyaProvider<API>.RequestResultClosure) -> Void in
    if var urlRequest = try? endpoint.urlRequest() {
        urlRequest.timeoutInterval = 20
        closure(.success(urlRequest))
    } else {
        closure(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}

let APIProvider = MoyaProvider<API>(requestClosure : timeoutClosure)
let APILoadingProvider = MoyaProvider<API>(requestClosure: timeoutClosure, plugins: [LoadingPlugin])

extension API:TargetType{
    
    var baseURL: URL {return URL(string: "http://rap2api.taobao.org/app/mock/224529/api/")!}
    
    var path: String {
        switch self {
        case .getUserData:
            return "post"
        case .getFriendList:
            return "friends"
        case .getFriendsCircle:
            return "friends_circle"
        case .jsonTest:
            return "jsonTest"
        }
        
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserData:
            return .post
        case .getFriendList:
            return .get
        default:
            return .get
        }
        
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        var param : [String:String] = [:]
        switch self {
        case .getUserData(let uid):
            param["u_id"] = uid
        default:
            break
        }
        
        return .requestParameters(parameters: param, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}


extension MoyaProvider {
    @discardableResult
    open func request<T: HandyJSON>(_ target: Target,
                                    model: T.Type,
                                    completion: ((_ returnData: T?) -> Void)?) -> Cancellable? {
        
        return request(target, completion: { (result) in
            
            guard let completion = completion else { return }
           
            let jsonString = String(data: result.value!.data, encoding: .utf8)
            
            guard let returnData = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
                //throw MoyaError.jsonMapping(self)
                return
            }
            completion(returnData)
        })
    }
}

struct ResponseData<T: HandyJSON>: HandyJSON {
    var code: Int = 0
    var msg:String?
    var data: T?
}


extension ObservableType where E == Response {
    public func mapModel<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(response.mapModel(T.self))
        }
    }
}
extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) -> T {
        let jsonString = String.init(data: data, encoding: .utf8)
        return JSONDeserializer<T>.deserializeFrom(json: jsonString)!
    }
}

