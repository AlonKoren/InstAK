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
    
    var isFollowing:BooleanObject? {
        didSet{
            if isFollowing==nil{
                return
            }
            updateFollowView()
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
    }
    
    
    func updateFollowView(){
        
        self.followButton.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8941176471, blue: 0.9098039216, alpha: 1)
        
        if isFollowing!.getBool(){
            self.configureUnFollowButton()
        }else{
            self.configureFollowButton()
        }
        
        
    }
    
    func configureFollowButton(){
//        self.followButton.layer.borderWidth = 1
//        self.followButton.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8941176471, blue: 0.9098039216, alpha: 1)
//        self.followButton.layer.cornerRadius = 5
//        self.followButton.clipsToBounds = true
        
        self.followButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        self.followButton.backgroundColor = #colorLiteral(red: 0.2705882353, green: 0.5568627451, blue: 1, alpha: 1)
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.addTarget(self, action: #selector(self.followAction), for: .touchUpInside)
    }

    func configureUnFollowButton(){
//        self.followButton.layer.borderWidth = 1
//        self.followButton.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8941176471, blue: 0.9098039216, alpha: 1)
//        self.followButton.layer.cornerRadius = 5
//        self.followButton.clipsToBounds = true
        
        self.followButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        self.followButton.backgroundColor = UIColor.clear
        self.followButton.setTitle("Following", for: .normal)
        self.followButton.addTarget(self, action: #selector(self.unfollowAction), for: .touchUpInside)
    }
    
    @objc func followAction(){
        
        if !AuthService.isSignIn(){
            return
        }
        if self.isFollowing!.getBool() == false{
            Api.Follow.followAction(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid!, onCompletion: {
                self.isFollowing!.setBool(bool: true)
                print("success follow")
                self.configureUnFollowButton()
            }) { (error) in
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }
    
    @objc func unfollowAction(){
        if !AuthService.isSignIn(){
            return
        }
        if self.isFollowing!.getBool() == true{
            Api.Follow.unFollowAction(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid!, onCompletion: {
                self.isFollowing!.setBool(bool: false)
                print("success unfollow")
                self.configureFollowButton()
            }) { (error) in
                ProgressHUD.showError(error.localizedDescription)
            }
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
