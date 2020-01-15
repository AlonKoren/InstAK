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
    
    func queryUsers(withText text: String, onAdded: @escaping (User)-> Void , onModified: @escaping (User)-> Void , onRemoved: @escaping (User)-> Void, onError : @escaping (Error)-> Void) ->Listener {
        let text = text.lowercased()
        let listener:Listener = Listener()
        listener.firestoreListener = COLLECTION_USERS.order(by: "username_lowercase").start(at: [text]).end(at: [text+"\u{f8ff}"]).limit(to: 10).addSnapshotListener { (querySnapshot, error) in
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
}
