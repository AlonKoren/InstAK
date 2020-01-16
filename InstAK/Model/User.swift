//
//  User.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class User : Codable{
    
    var email: String
    var prifileImage: String
    var username: String
    var uid: String
    var username_lowercase: String
    
    init(email: String, prifileImage: String, username: String, uid: String) {
        self.email = email
        self.prifileImage = prifileImage
        self.username = username
        self.uid = uid
        self.username_lowercase = username.lowercased()
    }
    
    func setData(user: User){
        self.email = user.email
        self.prifileImage = user.prifileImage
        self.username = user.username
        self.uid = user.uid
        self.username_lowercase = user.username_lowercase
    }
}
