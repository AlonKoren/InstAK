//
//  UserApi.swift
//  InstAK
//
//  Created by alon koren on 07/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserApi {
    private var COLLECTION_USERS = Firestore.firestore().collection("users")
    
    func observeUser(withId uid: String ,onCompletion: @escaping (User)-> Void , onError : @escaping (Error)-> Void){
        COLLECTION_USERS.document(uid).getDocument { (document, error) in
            if let userDocument = document, userDocument.exists{
                let user: User = try! DictionaryDecoder().decode(User.self, from: userDocument.data()!)
                onCompletion(user)
            }else{
                onError(error!)
            }
        }
    }
}
