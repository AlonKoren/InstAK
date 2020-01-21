//
//  ModelNotification.swift
//  InstAK
//
//  Created by alon koren on 21/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
class ModelNotification {
    
    static let PostListNotification = MyNotification<[Post]>("com.instAK.FeedList")

    class MyNotification<T> {
        let name:String
        var count = 0;
        
        init(_ _name:String) {
            name = _name
        }
        func observe(cb:@escaping (T)->Void)-> NSObjectProtocol{
            count += 1
            return NotificationCenter.default.addObserver(forName: NSNotification.Name(name),
                                                          object: nil, queue: nil) { (data) in
                                                            if let data = data.userInfo?["data"] as? T {
                                                                cb(data)
                                                            }
            }
        }
        
        func notify(data:T){
            NotificationCenter.default.post(name: NSNotification.Name(name),
                                            object: self,
                                            userInfo: ["data":data])
        }
        
        func remove(observer: NSObjectProtocol){
            count -= 1
            NotificationCenter.default.removeObserver(observer, name: nil, object: nil)
        }
    }
}
