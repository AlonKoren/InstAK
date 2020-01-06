//
//  Post.swift
//  InstAK
//
//  Created by alon koren on 05/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation

class Post : Codable{
    
    var caption: String?
    var photoUrl: String?
    
    init(captionText: String, photoUrlString: String) {
        caption = captionText
        photoUrl = photoUrlString
    }
}
