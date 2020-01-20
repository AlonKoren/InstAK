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
    private var COLLECTION_NOTIFICATION = Firestore.firestore().collection("users")
    
    func addNewNotification(notification : Notification){
        COLLECTION_NOTIFICATION.document(notification.userId!).collection("notification").addDocument(data: try! DictionaryEncoder().encode(notification))
    }
    
}
