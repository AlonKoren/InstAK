//
//  MyPostsApi.swift
//  InstAK
//
//  Created by alon koren on 13/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class MyPostsApi {
    private var COLLECTION_MY_POSTS = Firestore.firestore().collection("users") // myPosts
    
    
    func connectUserToPost(userId: String, postId: String, onCompletion: @escaping ()-> Void, onError : @escaping (Error)-> Void){
        let postsCollection = COLLECTION_MY_POSTS.document(userId).collection("posts")
        postsCollection.document(postId).setData([postId : true]){
            (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            onCompletion()
        }
    }
    
    func disconnectUserFromPost(userId: String, postId: String, onCompletion: @escaping ()-> Void, onError : @escaping (Error)-> Void){
        let postsCollection = COLLECTION_MY_POSTS.document(userId).collection("posts")
        postsCollection.document(postId).delete(){
            (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            onCompletion()
        }
    }
    
    func getUserPosts(userId: String, onCompletion: @escaping ([String])-> Void, onError : @escaping (Error)-> Void){
        let postsCollection = COLLECTION_MY_POSTS.document(userId).collection("posts")
        postsCollection.getDocuments { (querySnapshot, error) in
            if let err = error {
                onError(err)
                return
            }
            
            var postIds = [String]()
            for document in querySnapshot!.documents {
                let postId = document.documentID
                
                postIds.append(postId)
            }
            onCompletion(postIds)
        }
    }
    
    func observeUserPosts(userId:String, onAdded: @escaping (String)-> Void , onModified: @escaping (String)-> Void , onRemoved: @escaping (String)-> Void, onError : @escaping (Error)-> Void) ->Listener{
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_MY_POSTS.document(userId).collection("posts")
                .addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            for diff in snapshot.documentChanges{
                let postId = diff.document.documentID
                
                if (diff.type == .added) {
                    onAdded(postId)
                }
                if (diff.type == .modified) {
                    onModified(postId)
                }
                if (diff.type == .removed) {
                    onRemoved(postId)
                }
            }
        }
        return listener
    }
    
}
