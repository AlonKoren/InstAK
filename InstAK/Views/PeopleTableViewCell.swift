//
//  PeopleTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 14/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
    var user:User?{
        didSet{
            if user==nil{
                return
            }
            updateView()
        }
    }
    
    
    
    func updateView(){
        self.nameLabel.text = user!.username
        if let profileImageUrlString = user!.prifileImage {
            let profileImageUrl = URL(string: profileImageUrlString)
            let placeholder = #imageLiteral(resourceName: "placeholder-avatar-profile")
            self.profileImage.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [])
        }else{
            print("profileImageUrlString does not exist")
        }
        
        
        followButton.addTarget(self, action: #selector(self.followAction), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(self.unfollowAction), for: .touchUpInside)
    }
    
    
    @objc func followAction(){
        
        if !AuthService.isSignIn(){
            return
        }
        
        Api.Follow.followerAfterUser(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid!, onCompletion: {
            
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
        Api.Follow.followingAfterUser(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid!, onCompletion: {
            
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    
    @objc func unfollowAction(){
        if !AuthService.isSignIn(){
            return
        }
        
        Api.Follow.unfollowerAfterUser(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid!, onCompletion: {
            
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
        Api.Follow.unfollowingAfterUser(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid!, onCompletion: {
            
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
        
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
