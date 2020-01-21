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
    var profileImage: String
    var username: String
    var uid: String
    var username_lowercase: String
    
    init(email: String, profileImage: String, username: String, uid: String) {
        self.email = email
        self.profileImage = profileImage
        self.username = username
        self.uid = uid
        self.username_lowercase = username.lowercased()
    }
    
    init(user: User) {
        self.email = user.email
        self.profileImage = user.profileImage
        self.username = user.username
        self.uid = user.uid
        self.username_lowercase = user.username_lowercase
    }
    
    func setData(user: User){
        self.email = user.email
        self.profileImage = user.profileImage
        self.username = user.username
        self.uid = user.uid
        self.username_lowercase = user.username_lowercase
    }
    func setData(email: String, profileImage: String, username: String) {
        self.email = email
        self.profileImage = profileImage
        self.username = username
        self.username_lowercase =  username.lowercased()
    }
}
