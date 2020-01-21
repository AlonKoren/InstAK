//
//  Model.swift
//  InstAK
//
//  Created by alon koren on 21/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import UIKit

class Model {
    static let instance:Model = Model()


    var modelSql = ModelSql();
    //var modelFirebase = ModelFirebase();

    private init(){
    }



    func getAllPosts() {
        print("getAllPosts")
        
        //1. read local users last update date
        var lastUpdated = PostSQL.getLastUpdateDate(database: modelSql.database)
        lastUpdated += 1;
        
        //2. get updates from firebase and observe
        Api.Post.getAllPosts(onCompletion: { (posts) in
            //3. write new records to the local DB
            print("posts \(posts)")
            for post in posts {
                PostSQL.addNew(database: self.modelSql.database, data: post)
                if (post.timestamp != nil && Double(post.timestamp!) > lastUpdated){
                    lastUpdated = Double(post.timestamp!)
                }
            }
            
            //4. update the local users last update date
            PostSQL.setLastUpdateDate(database: self.modelSql.database, date: lastUpdated)
            
            //5. get the full data
            let stFullData = PostSQL.getAll(database: self.modelSql.database)

            ModelNotification.PostListNotification.notify(data: stFullData)
        }) { (error) in
            
        }
    }
}
