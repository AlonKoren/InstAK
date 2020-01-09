//
//  StorageService.swift
//  InstAK
//
//  Created by alon koren on 09/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
    static let STORAGE_PROFILE_IMAGE_REF = Storage.storage().reference().child("profile_image")
    static let STORAGE_POST_REF = Storage.storage().reference().child("posts")
    
    static func addProfileImage(uid : String, imageData : Data , onSuccess: @escaping (URL) -> Void, onError : @escaping (Error)-> Void){
        let storageRef = STORAGE_PROFILE_IMAGE_REF.child(uid)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if error != nil{
                onError(error!)
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    onError(error!)
                    return
                }
                
                onSuccess(url!)
            })
        }
    }
    
    static func addPostImage(postId : String, imageData : Data , onSuccess: @escaping (URL) -> Void, onError : @escaping (Error)-> Void){
        let storageRef = STORAGE_POST_REF.child(postId)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if error != nil{
                onError(error!)
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    onError(error!)
                    return
                }
                
                onSuccess(url!)
            })
        }
    }
}
