//
//  Post.swift
//  InstAK
//
//  Created by alon koren on 05/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class Post : Codable{
    
    var caption: String
    var photoUrl: String
    
//    enum CodingKeys: String, CodingKey {
//        case caption
//        case photoUrl
//    }
    
    init(captionText: String, photoUrlString: String) {
        caption = captionText
        photoUrl = photoUrlString
    }
}
