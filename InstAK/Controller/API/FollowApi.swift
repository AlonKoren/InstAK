//
//  FollowApi.swift
//  InstAK
//
//  Created by alon koren on 14/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FollowApi {
    private var COLLECTION_FOLLOWS = Firestore.firestore().collection("users")
    
    private let FOLLOWINGS  = "followings"
    private let FOLLOWERS   = "followers"
    
    func followAction(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void){
        self.followerAfterUser(followerUserId: followerUserId, followingUserId: followingUserId, onCompletion: {
            self.followingAfterUser(followerUserId: followerUserId, followingUserId: followingUserId, onCompletion: {
                onCompletion()
            }) { (error) in
                onError(error)
            }
            let timestamp = Int(Date().timeIntervalSince1970)
            Api.Notifiaction.addNewNotification(userId: followingUserId, fromId: followerUserId, type: "follow", objectId: followerUserId, timestamp: timestamp)
        }) { (error) in
            onError(error)
        }
    }
    
    func unFollowAction(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void){
        self.unFollowerAfterUser(followerUserId: followerUserId, followingUserId: followingUserId, onCompletion: {
            self.unFollowingAfterUser(followerUserId: followerUserId, followingUserId: followingUserId, onCompletion: {
                onCompletion()
            }) { (error) in
                onError(error)
            }
            Api.Notifiaction.removeNotification(userId: followingUserId, fromId: followerUserId, type: "follow", objectId: followerUserId)
        }) { (error) in
            onError(error)
        }
    }
    
    // followerUserId want to follow after followingUserId
    func followingAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followingsCollection = COLLECTION_FOLLOWS.document(followerUserId).collection(FOLLOWINGS)
        followingsCollection.document(followingUserId).setData([followingUserId : true]){
           (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            
            onCompletion()
        }
    }
    
    // followingUserId want to follow by followerUserId
    func followerAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followersCollection = COLLECTION_FOLLOWS.document(followingUserId).collection(FOLLOWERS)
        followersCollection.document(followerUserId).setData([followerUserId : true]){
           (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            onCompletion()
        }
    }
    
    // followerUserId don't want to follow after followingUserId
    func unFollowingAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followingsCollection = COLLECTION_FOLLOWS.document(followerUserId).collection(FOLLOWINGS)
        followingsCollection.document(followingUserId).delete(){
           (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            
            onCompletion()
        }
    }
    
    // followingUserId don't want to follow by followerUserId
    func unFollowerAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followersCollection = COLLECTION_FOLLOWS.document(followingUserId).collection(FOLLOWERS)
        followersCollection.document(followerUserId).delete(){
           (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            onCompletion()
        }
    }
    
    // is followerUserId follow after followingUserId
    func isFollowingAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping (Bool) -> Void, onError : @escaping (Error)-> Void) {
        let followingsCollection = COLLECTION_FOLLOWS.document(followerUserId).collection(FOLLOWINGS)
        followingsCollection.document(followingUserId).getDocument(completion: { (documentSnapshot, error) in
            if let err = error {
                onError(err)
                return
            }
            let isFollowing = documentSnapshot!.exists
            onCompletion(isFollowing)
        })
    }
    
    // is followerUserId follow after followingUserId
    func isFollowerAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping (Bool) -> Void, onError : @escaping (Error)-> Void) {
        let followingsCollection = COLLECTION_FOLLOWS.document(followingUserId).collection(FOLLOWERS)
        followingsCollection.document(followerUserId).getDocument(completion: { (documentSnapshot, error) in
            if let err = error {
                onError(err)
                return
            }
            let isFollower = documentSnapshot!.exists
            onCompletion(isFollower)
        })
    }
    
    
    // get all Followings user that the followerUserId follow
    func getAllFollowings(followerUserId: String,onCompletion: @escaping ([String]) -> Void, onError : @escaping (Error)-> Void) {
        
        COLLECTION_FOLLOWS.document(followerUserId).collection(FOLLOWINGS)
            .getDocuments { (querySnapshot, error) in
                if let err = error {
                    onError(err)
                    return
                }
                
                var userIds = [String]()
                for document in querySnapshot!.documents {
                    let userId = document.documentID
                    
                    userIds.append(userId)
                }
                onCompletion(userIds)
            }
    }
    
    // get all Followers user that the follow followingUserId
    func getAllFollowers(followingUserId: String,onCompletion: @escaping ([String]) -> Void, onError : @escaping (Error)-> Void){
        COLLECTION_FOLLOWS.document(followingUserId).collection(FOLLOWERS)
            .getDocuments { (querySnapshot, error) in
                if let err = error {
                    onError(err)
                    return
                }
                
                var userIds = [String]()
                for document in querySnapshot!.documents {
                    let userId = document.documentID
                    userIds.append(userId)
                }
                onCompletion(userIds)
            }
    }
    
    // get Count of all Followings user that the followerUserId follow
    func getAllFollowingsCount(followerUserId: String,onCompletion: @escaping (Int) -> Void, onError : @escaping (Error)-> Void) -> Listener{
        
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_FOLLOWS.document(followerUserId).collection(FOLLOWINGS)
            .addSnapshotListener({ (querySnapshot, error) in
                if let err = error {
                    onError(err)
                    return
                }
                
                onCompletion(querySnapshot!.documents.count)
            })
        return listener
    }
    
    // get Count of all Followers user that the follow followingUserId
    func getAllFollowersCount(followingUserId: String,onCompletion: @escaping (Int) -> Void, onError : @escaping (Error)-> Void) -> Listener{
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_FOLLOWS.document(followingUserId).collection(FOLLOWERS).addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                onError(err)
                return
            }
            
            onCompletion(querySnapshot!.documents.count)
        })
        return listener
    }
}
