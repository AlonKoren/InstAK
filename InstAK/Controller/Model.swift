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



    func getAllPosts() -> Listener{
        print("getAllPosts")
        
        //1. read local users last update date
        var lastUpdated = PostSQL.getLastUpdateDate(database: modelSql.database)
        lastUpdated += 1;
        
        //2. get updates from firebase and observe
        let lisener : Listener =  Api.Post.observePosts(onAdded: { (addedPost) in
            
            PostSQL.addNew(database: self.modelSql.database, data: addedPost)
            if (addedPost.timestamp != nil && Double(addedPost.timestamp!) > lastUpdated){
                lastUpdated = Double(addedPost.timestamp!)
                //4. update the local users last update date
                PostSQL.setLastUpdateDate(database: self.modelSql.database, date: lastUpdated)
            }
            //5. get the full data
            let stFullData = PostSQL.getAll(database: self.modelSql.database)

            ModelNotification.PostListNotification.notify(data: stFullData)
            
        }, onModified: { (modifedPost) in
            PostSQL.delete(database: self.modelSql.database, byId: modifedPost.postId)
            PostSQL.addNew(database: self.modelSql.database, data: modifedPost)
            if (modifedPost.timestamp != nil && Double(modifedPost.timestamp!) > lastUpdated){
                lastUpdated = Double(modifedPost.timestamp!)
                //4. update the local users last update date
                PostSQL.setLastUpdateDate(database: self.modelSql.database, date: lastUpdated)
            }
            
            //5. get the full data
            let stFullData = PostSQL.getAll(database: self.modelSql.database)

            ModelNotification.PostListNotification.notify(data: stFullData)
            
        }, onRemoved: { (removedPost) in
            
            PostSQL.delete(database: self.modelSql.database, byId: removedPost.postId)
            //5. get the full data
            let stFullData = PostSQL.getAll(database: self.modelSql.database)

            ModelNotification.PostListNotification.notify(data: stFullData)
            
        }, onCompletion: {() in
            let stFullData = PostSQL.getAll(database: self.modelSql.database)
            ModelNotification.PostListNotification.notify(data: stFullData)
        } ) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
        
        
        return lisener
        
    }
}
