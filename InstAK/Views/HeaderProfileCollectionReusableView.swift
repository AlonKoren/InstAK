//
//  HeaderProfileCollectionReusableView.swift
//  InstAK
//
//  Created by alon koren on 13/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var myPostsCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    
    var user : User?{
        didSet{
            if user == nil {
                return
            }
            updateView()
        }
    }
    
    func updateView() {
        self.nameLabel.text = user!.username
        if let profileImageUrlString = user!.prifileImage {
            let profileImageUrl = URL(string: profileImageUrlString)
            let placeholder = #imageLiteral(resourceName: "placeholder-avatar-profile")
            self.profileImage.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [])
        }else{
            print("profileImageUrlString does not exist")
        }
    }
        
}
