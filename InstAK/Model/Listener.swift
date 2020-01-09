//
//  Listener.swift
//  InstAK
//
//  Created by alon koren on 09/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Listener {
    var firestoreListener : ListenerRegistration?
    
    func disconnected() {
        firestoreListener?.remove()
    }
}
