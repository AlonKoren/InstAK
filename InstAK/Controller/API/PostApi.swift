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
    private var COLLECTION_POSTS = Firestore.firestore().collection("posts")
    
    func observePosts(onAdded: @escaping (Post)-> Void , onModified: @escaping (Post)-> Void , onRemoved: @escaping (Post)-> Void,onCompletion: @escaping ()-> Void, onError : @escaping (Error)-> Void) ->Listener{
        
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_POSTS.addSnapshotListener { (querySnapshot, error) in
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
            onCompletion()
        }
        return listener
    }
    
    func getAllPosts(onCompletion: @escaping ([Post])-> Void, onError : @escaping (Error)-> Void){
        COLLECTION_POSTS.getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            var posts = [Post]()
            for diff in snapshot.documentChanges{
                let post:Post = try! DictionaryDecoder().decode(Post.self, from: diff.document.data())
                posts.append(post)
            }
            onCompletion(posts)
        }
    }
    
    func observePost(postId : String, onCompletion: @escaping (Post)-> Void , onError : @escaping (Error)-> Void , onNotExist : @escaping ()->Void) ->Listener{
        
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_POSTS.document(postId).addSnapshotListener({ (documentSnapshot, error) in
            guard let snapshot = documentSnapshot else {
                onError(error!)
                return
            }
            if(!snapshot.exists) {
                onNotExist();
                return
            }
            let post:Post = try! DictionaryDecoder().decode(Post.self, from: snapshot.data()!)
            onCompletion(post)
        })
        return listener
    }
    
    func isExistPost(postId : String,onCompletion: @escaping (Bool)-> Void , onError : @escaping (Error)-> Void){
        COLLECTION_POSTS.document(postId).getDocument { (documentSnapshot, error) in
            guard let snapshot = documentSnapshot else {
                onError(error!)
                return
            }
            onCompletion(snapshot.exists)
        }
    }
    
    func getpost(postId : String ,onCompletion: @escaping (Post)-> Void, onError : @escaping (Error)-> Void){
        COLLECTION_POSTS.document(postId).getDocument { (documentSnapshot, error) in
            guard let snapshot = documentSnapshot else {
                onError(error!)
                return
            }
            if(!snapshot.exists){
                return
            }
            do{
                let post:Post = try DictionaryDecoder().decode(Post.self, from: snapshot.data()!)
                onCompletion(post)
            }catch _{}
            
            
        }
    }
    
    func observePost(postId : String, onAdded: @escaping (Post)-> Void , onModified: @escaping (Post)-> Void , onRemoved: @escaping (Post)-> Void , onError : @escaping (Error)-> Void) ->Listener{
        
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_POSTS.whereField("postId", isEqualTo: postId).addSnapshotListener { (querySnapshot, error) in
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
        return listener
    }
    
    func addPostToDatabase(caption: String, photoUrl: String, uid: String , ratio : CGFloat, videoUrl:String?, timestamp : Int ,onCompletion: @escaping (Post)-> Void, onError : @escaping (Error)-> Void){
        let postsCollection = COLLECTION_POSTS
        let newPostDocument = postsCollection.document()
        let newPostId =  newPostDocument.documentID
        
        
        let post:Post = Post(captionText: caption, photoUrlString: photoUrl, uid: uid, postId: newPostId, ratio: ratio,videoUrl: videoUrl,timestamp: timestamp)
        
        newPostDocument.setData(try! DictionaryEncoder().encode(post)){ err in
           if let err = err {
                onError(err)
                return
           }
            onCompletion(post)
        }
    }
    
    
    func isLiked(postId : String, userId : String, onCompletion: @escaping (Bool)-> Void, onError : @escaping (Error)-> Void) {
        Api.Post.COLLECTION_POSTS.document(postId).collection("likes")
                    .document(userId).getDocument { (documentSnapshot, error) in
                if let err = error {
                    onError(err)
                    return
                }
                if(documentSnapshot!.exists){
                    if let data = documentSnapshot!.data() {
                        if let bool = data[userId] as! Bool?{
                            onCompletion(bool)
                            return
                        }
                    }
                }
                onCompletion(false)
        }
    }
    
    
    func incrementLike(postId : String, userId : String, onCompletion: @escaping (Bool)-> Void, onError : @escaping (Error)-> Void){
        
        let db = Firestore.firestore()
        let postReference = Api.Post.COLLECTION_POSTS.document(postId)
        let likeUsereReference = postReference.collection("likes").document(userId)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument , likeUserPostDocument : DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(postReference)
                try likeUserPostDocument = transaction.getDocument(likeUsereReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var oldLikeCount = postDocument.data()?["likeCount"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve likeCount from snapshot \(postDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            var isIncrement:Bool
            if likeUserPostDocument.exists{ // unlike the post
                oldLikeCount -= 1
                transaction.deleteDocument(likeUsereReference)
                isIncrement = false
            } else {                        // like the post
                oldLikeCount += 1
                transaction.setData([userId:true], forDocument: likeUsereReference)
                isIncrement = true
            }

            transaction.updateData(["likeCount": oldLikeCount], forDocument: postReference)
            return (isIncrement)
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                onError(error)
            } else {
                print("Transaction successfully committed!")
                
                let isLiked:Bool = object! as! Bool
                onCompletion(isLiked)
            }
        }
    }
    
    func observeSpecificPosts(postsIds : [String] ,onAdded: @escaping (Post)-> Void , onModified: @escaping (Post)-> Void , onRemoved: @escaping (Post)-> Void, onError : @escaping (Error)-> Void) ->Listener{
        	
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_POSTS.whereField("postId", in: postsIds).addSnapshotListener { (querySnapshot, error) in
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
        return listener
    }
    
    func getTopPosts(onCompletion: @escaping ([Post])-> Void, onError : @escaping (Error)-> Void){
        COLLECTION_POSTS.order(by: "likeCount", descending: true).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            var posts = [Post]()
            for diff in snapshot.documentChanges{
                let post:Post = try! DictionaryDecoder().decode(Post.self, from: diff.document.data())
                posts.append(post)
            }
            onCompletion(posts)
        }
    }
    
    func removePost(postId : String,onCompletion: @escaping ()-> Void, onError : @escaping (Error)-> Void){
        COLLECTION_POSTS.document(postId).delete { (error) in
            if let err = error{
                onError(err);
            }else{
                self.COLLECTION_POSTS.document(postId).collection("likes").getDocuments { (querySnapshot, error) in
                    if let err = error {
                        onError(err)
                        return
                    }
                    for document in querySnapshot!.documents{
                        self.COLLECTION_POSTS.document(postId).collection("likes").document(document.documentID).delete()
                    }
                    onCompletion();
                }
                
            }
        }
    }
    
}
