//
//  AuthService.swift
//  InstAK
//
//  Created by alon koren on 02/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseAuth

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
            
            StorageService.addProfileImage(uid: uid!, imageData : imageData, onSuccess: { (url : URL) in
                let profileImageUrl = url.absoluteString
                self.setUserInformation(profileImageUrl: profileImageUrl, username: username, email: email,uid: uid!, onSuccess: onSuccess)
                
            }) { (error) in
                return
            }
        }
    }
    
    static func signOut() throws -> Void{
        try Auth.auth().signOut()
    }
    
    static func getCurrentUserId() -> String?{
        return Auth.auth().currentUser?.uid
    }
    
    static func isSignIn() -> Bool{
        guard let _ = getCurrentUserId() else {
            return false
        }
        return true
    }
    
    static func setUserInformation(profileImageUrl: String, username: String, email:String,uid: String, onSuccess: @escaping () -> Void){
        Api.User.addUserToDatabase(profileImageUrl: profileImageUrl, username: username, email: email, uid: uid, onSuccess: { (user : User) in
            print("Document successfully written!")
            onSuccess()
        }) { (err) in
            print("Error writing document: \(err)")
        }
    }

}
