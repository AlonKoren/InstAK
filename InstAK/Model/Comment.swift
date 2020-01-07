//
//  Comment.swift
//  InstAK
//
//  Created by alon koren on 07/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class Comment : Codable{
    
    var commentText: String?
    var uid: String?
    var commnetId: String?
    
    
    init(commentText: String, uid: String, commnetId: String) {
        self.commentText = commentText
        self.uid = uid
        self.commnetId = commnetId
    }
}
