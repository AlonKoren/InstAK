//
//  Notification.swift
//  InstAK
//
//  Created by alon koren on 20/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class Notification : Codable{
    var userId : String?
    var fromId : String?
    var type : String?
    var objectId : String?
    var timestamp : Int?
    var notificationId : String
    
    init(notificationId : String, userId : String , fromId : String , type : String, objectId : String, timestamp : Int) {
        self.notificationId = notificationId
        self.userId = userId
        self.fromId = fromId
        self.type = type
        self.objectId = objectId
        self.timestamp = timestamp
    }
    
    func setData(notification: Notification){
        self.notificationId = notification.notificationId
        self.userId = notification.userId
        self.fromId = notification.fromId
        self.type = notification.type
        self.objectId = notification.objectId
        self.timestamp = notification.timestamp
    }
}
