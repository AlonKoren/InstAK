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
            
            onCompletion(notifications)
        }
    }
    
}
