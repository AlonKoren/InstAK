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
    var ratio : CGFloat?
    var videoUrl : String?
    
    init(captionText: String, photoUrlString: String, uid: String,postId: String,ratio : CGFloat,videoUrl : String?) {
        self.caption = captionText
        self.photoUrl = photoUrlString
        self.uid = uid
        self.postId = postId
        self.likeCount = 0
        self.ratio = ratio
        self.videoUrl = videoUrl
    }
    
    func setData(post: Post){
        self.caption = post.caption
        self.photoUrl = post.photoUrl
        self.uid = post.uid
        self.postId = post.postId
        self.likeCount = post.likeCount
        self.ratio = post.ratio
        self.videoUrl = post.videoUrl
    }
}
