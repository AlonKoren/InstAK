//
//  FeedApi.swift
//  
//
//  Created by alon koren on 14/01/2020.
//

import Foundation
import FirebaseFirestore

class FeedApi {
    
    
    private var COLLECTION_FEED = Firestore.firestore().collection("users")
    private let FEED = "feed"
    
    
    func addPostToFeed(userId: String, postId :String) {
        self.COLLECTION_FEED.document(userId).collection(self.FEED).document(postId).setData([postId:true])
    }
    
    func addPostsToFeed(userId: String, postsIds :[String]) {
        postsIds.forEach { (postId) in
            addPostToFeed(userId: userId, postId :postId)
        }
    }
    
    func removePostToFeed(userId: String, postId :String) {
        self.COLLECTION_FEED.document(userId).collection(self.FEED).document(postId).delete()
    }
    
    func removePostsToFeed(userId: String, postsIds :[String]) {
        postsIds.forEach { (postId) in
            removePostToFeed(userId: userId, postId :postId)
        }
    }
    
    func getPostsFromFeed(userId: String, onCompletion: @escaping ([String]) -> Void, onError : @escaping (Error)-> Void){
        self.COLLECTION_FEED.document(userId).collection(self.FEED).getDocuments { (querySnapshot, error) in
            if let err = error{
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
    
    func observePostsFromFeed(userId:String, onAdded: @escaping (String)-> Void , onModified: @escaping (String)-> Void , onRemoved: @escaping (String)-> Void , onFinish: @escaping ()-> Void, onError : @escaping (Error)-> Void) ->Listener{
        let listener:Listener = Listener()
        listener.firestoreListener = self.COLLECTION_FEED.document(userId).collection(self.FEED)
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
            onFinish()
        }
        return listener
    }
    
    
}
