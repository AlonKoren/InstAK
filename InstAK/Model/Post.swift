//
//  Post.swift
//  InstAK
//
//  Created by alon koren on 05/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class Post : Codable{
    
    var postId: String
    var caption: String?
    var photoUrl: String?
    var uid: String
    var likeCount: Int?
    var ratio : CGFloat?
    var videoUrl : String?
    var timestamp : Int?
    
    init(captionText: String, photoUrlString: String, uid: String,postId: String,ratio : CGFloat,videoUrl : String? , timestamp : Int) {
        self.caption = captionText
        self.photoUrl = photoUrlString
        self.uid = uid
        self.postId = postId
        self.likeCount = 0
        self.ratio = ratio
        self.videoUrl = videoUrl
        self.timestamp = timestamp
    }
    init(captionText: String, photoUrlString: String, uid: String,postId: String,likeCount: Int , ratio : CGFloat,videoUrl : String? , timestamp : Int) {
        self.caption = captionText
        self.photoUrl = photoUrlString
        self.uid = uid
        self.postId = postId
        self.likeCount = likeCount
        self.ratio = ratio
        self.videoUrl = videoUrl
        self.timestamp = timestamp
    }
    
    func setData(post: Post){
        self.caption = post.caption
        self.photoUrl = post.photoUrl
        self.uid = post.uid
        self.postId = post.postId
        self.likeCount = post.likeCount
        self.ratio = post.ratio
        self.videoUrl = post.videoUrl
        self.timestamp = post.timestamp
    }
}
