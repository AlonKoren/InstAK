//
//  AuthService.swift
//  InstAK
//
//  Created by alon koren on 02/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class AuthService  {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        Auth.auth().signIn(withEmail: email,password: password) { (authResult, error ) in
        if error != nil {
            onError(error!.localizedDescription)
            return
            }
            onSuccess()
        }
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            let uid = authResult?.user.uid
            let storageRef = Storage.storage().reference().child("profile_image").child(uid!)

            
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if error != nil{
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            return
                        }
                        let profileImageUrl = url?.absoluteString
                        
                        self.setUserInformation(profileImageUrl: profileImageUrl!, username: username, email: email,uid: uid!, onSuccess: onSuccess)
                    })
                }
            }
        }
    
static func setUserInformation(profileImageUrl: String, username: String, email:String,uid: String, onSuccess: @escaping () -> Void){
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "uid": uid,
            "username": username,
            "email": email,
            "profileImage": profileImageUrl
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                onSuccess()
            }
        }
    }

}
