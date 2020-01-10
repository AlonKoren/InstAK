//
//  PostApi.swift
//  InstAK
//
//  Created by alon koren on 07/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class PostApi {
    var COLLECTION_POSTS = Firestore.firestore().collection("posts")
    
    func observePosts(onAdded: @escaping (Post)-> Void , onModified: @escaping (Post)-> Void , onRemoved: @escaping (Post)-> Void, onError : @escaping (Error)-> Void){
        COLLECTION_POSTS.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            for diff in snapshot.documentChanges{
                let post:Post = try! DictionaryDecoder().decode(Post.self, from: diff.document.data())
                if (diff.type == .added) {
                    print("New Post : \(post)")
                    onAdded(post)
                }
                if (diff.type == .modified) {
                    print("Modified Post : \(post)")
                    onModified(post)
                }
                if (diff.type == .removed) {
                    print("Removed Post : \(post)")
                    onRemoved(post)
                }
            }
        }
    }
    
    func addPostToDatabase(caption: String, photoUrl: String, uid: String , onCompletion: @escaping (Post)-> Void, onError : @escaping (Error)-> Void){
        let postsCollection = COLLECTION_POSTS
        let newPostDocument = postsCollection.document()
        let newPostId =  newPostDocument.documentID
        
        let post:Post = Post(captionText: caption, photoUrlString: photoUrl, uid: uid, postId: newPostId)
        
        newPostDocument.setData(try! DictionaryEncoder().encode(post)){ err in
           if let err = err {
                onError(err)
                return
           }
            onCompletion(post)
        }
    }
}
