//
//  Api.swift
//  InstAK
//
//  Created by alon koren on 07/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

struct Api{
    static let User = UserApi()
    static let Post = PostApi()
    static let Comment = CommentApi()
    static let MyPosts = MyPostsApi()
    static let Follow = FollowApi()
}
