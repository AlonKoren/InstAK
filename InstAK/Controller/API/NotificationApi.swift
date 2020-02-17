//
//  NotificationApi.swift
//  InstAK
//
//  Created by alon koren on 20/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class NotificationApi  {
    private let COLLECTION_NOTIFICATION = Firestore.firestore().collection("users")
    private let NOTIFICATION = "notification"
    
    func addNewNotification(userId : String , fromId : String , type : String, objectId : String, timestamp : Int){
        let doc_notification = COLLECTION_NOTIFICATION.document(userId).collection(NOTIFICATION).document()
        let doc_id = doc_notification.documentID
        let notification :Notification = Notification(notificationId: doc_id, userId: userId, fromId: fromId, type: type, objectId: objectId, timestamp: timestamp)
        doc_notification.setData(try! DictionaryEncoder().encode(notification))
    }
    
    func removeNotification(userId : String , fromId : String , type : String, objectId : String){
        COLLECTION_NOTIFICATION.document(userId).collection(NOTIFICATION)
            .whereField("userId", isEqualTo: userId).whereField("fromId", isEqualTo: fromId)
            .whereField("type", isEqualTo: type).whereField("objectId", isEqualTo: objectId).getDocuments { (querySnapshot, error) in
                querySnapshot?.documents.forEach({ (queryDocumentSnapshot) in
                    self.COLLECTION_NOTIFICATION.document(userId).collection(self.NOTIFICATION).document(queryDocumentSnapshot.documentID).delete()
                })
        }
    }
    
    func removeAllNotification(userId : String , objectId : String){
        COLLECTION_NOTIFICATION.document(userId).collection(NOTIFICATION)
            .whereField("objectId", isEqualTo: objectId)
            .getDocuments { (querySnapshot, error) in
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
                querySnapshot!.documents.forEach({ (queryDocumentSnapshot) in
                    self.COLLECTION_NOTIFICATION.document(userId).collection(self.NOTIFICATION).document(queryDocumentSnapshot.documentID).delete()
                })
        }
    }
    
    func getNotifications(userId: String, onCompletion: @escaping ([Notification]) -> Void, onError : @escaping (Error)-> Void){
        self.COLLECTION_NOTIFICATION.document(userId).collection(NOTIFICATION).getDocuments { (querySnapshot, error) in
            if let err = error{
                onError(err)
                return
            }
            var notifications = [Notification]()
            for document in querySnapshot!.documents {
                let notification : Notification = try! DictionaryDecoder().decode(Notification.self, from: document.data())
                notifications.append(notification)
            }
            print("notifications: \(notifications)")
            onCompletion(notifications)
        }
    }
    
    func observeNotifications(userId:String, onAdded: @escaping (Notification)-> Void , onModified: @escaping (Notification)-> Void , onRemoved: @escaping (Notification)-> Void , onFinish: @escaping ()-> Void, onError : @escaping (Error)-> Void) ->Listener{
        let listener:Listener = Listener()
        listener.firestoreListener = self.COLLECTION_NOTIFICATION.document(userId).collection(NOTIFICATION)
            .addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            for diff in snapshot.documentChanges{
                let notification : Notification = try! DictionaryDecoder().decode(Notification.self, from: diff.document.data())
                
                if (diff.type == .added) {
                    onAdded(notification)
                }
                if (diff.type == .modified) {
                    onModified(notification)
                }
                if (diff.type == .removed) {
                    onRemoved(notification)
                }
            }
            onFinish()
        }
        return listener
    }
    
}
