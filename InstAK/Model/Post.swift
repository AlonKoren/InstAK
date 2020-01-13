//
//  Post.swift
//  InstAK
//
//  Created by alon koren on 05/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class Post : Codable{
    
    var postId: String?
    var caption: String?
    var photoUrl: String?
    var uid: String?
    var likeCount: Int?
    
    init(captionText: String, photoUrlString: String, uid: String,postId: String) {
        self.caption = captionText
        self.photoUrl = photoUrlString
        self.uid = uid
        self.postId = postId
        self.likeCount = 0
    }
    
    func setData(post: Post){
        self.caption = post.caption
        self.photoUrl = post.photoUrl
        self.uid = post.uid
        self.postId = post.postId
        self.likeCount = post.likeCount
    }
}
