//
//  UserApi.swift
//  InstAK
//
//  Created by alon koren on 07/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserApi {
    private var COLLECTION_USERS = Firestore.firestore().collection("users")
    
    func observeUser(withId uid: String ,onCompletion: @escaping (User)-> Void , onError : @escaping (Error)-> Void){
        COLLECTION_USERS.document(uid).getDocument { (document, error) in
            if let userDocument = document, userDocument.exists{
                let user: User = try! DictionaryDecoder().decode(User.self, from: userDocument.data()!)
                onCompletion(user)
            }else{
                onError(error!)
            }
        }
    }
    
    func addUserToDatabase(profileImageUrl: String, username: String, email:String,uid: String, onSuccess: @escaping (User) -> Void, onError : @escaping (Error)-> Void){
        let user: User = User(email: email, prifileImage: profileImageUrl, username: username, uid: uid)
        COLLECTION_USERS.document(uid).setData(try! DictionaryEncoder().encode(user)) { err in
            if let err = err {
                onError(err)
            } else {
                onSuccess(user)
            }
        }
    }
    
    func observeAllUsers(onAdded: @escaping (User)-> Void , onModified: @escaping (User)-> Void , onRemoved: @escaping (User)-> Void, onError : @escaping (Error)-> Void) ->Listener{
        
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_USERS.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            for diff in snapshot.documentChanges{
                let user: User = try! DictionaryDecoder().decode(User.self, from: diff.document.data())
                if (diff.type == .added) {
                    print("New User : \(user)")
                    onAdded(user)
                }
                if (diff.type == .modified) {
                    print("Modified User : \(user)")
                    onModified(user)
                }
                if (diff.type == .removed) {
                    print("Removed User : \(user)")
                    onRemoved(user)
                }
            }
        }
        return listener
    }
    
    func observeSpecificUsers(usersIds : [String] ,onAdded: @escaping (User)-> Void , onModified: @escaping (User)-> Void , onRemoved: @escaping (User)-> Void, onError : @escaping (Error)-> Void) ->Listener{
        
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_USERS.whereField("uid", in: usersIds).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            for diff in snapshot.documentChanges{
                let user: User = try! DictionaryDecoder().decode(User.self, from: diff.document.data())
                if (diff.type == .added) {
                    print("New User : \(user)")
                    onAdded(user)
                }
                if (diff.type == .modified) {
                    print("Modified User : \(user)")
                    onModified(user)
                }
                if (diff.type == .removed) {
                    print("Removed User : \(user)")
                    onRemoved(user)
                }
            }
        }
        return listener
    }
    
    
    // followerUserId want to follow after followingUserId
    func followingAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followingsCollection = COLLECTION_USERS.document(followerUserId).collection("followings")
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
        let followersCollection = COLLECTION_USERS.document(followingUserId).collection("followers")
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
    func unfollowingAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followingsCollection = COLLECTION_USERS.document(followerUserId).collection("followings")
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
    func unfollowerAfterUser(followerUserId: String, followingUserId: String, onCompletion: @escaping () -> Void, onError : @escaping (Error)-> Void) {
        let followersCollection = COLLECTION_USERS.document(followingUserId).collection("followers")
        followersCollection.document(followerUserId).delete(){
           (error : Error?) in
            if let err = error{
                onError(err)
                return
            }
            onCompletion()
        }
    }
    

    
}
