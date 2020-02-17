//
//  HeaderProfileCollectionReusableView.swift
//  InstAK
//
//  Created by alon koren on 13/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit


protocol HeaderProfileCollectionReusableViewDelegate {
    func closeListeners(listeners : [Listener])
}

protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingViewController {
    func goToSettingViewController()
}

//Profile_SettingSeague
class HeaderProfileCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var myPostsCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
    var delegate : HeaderProfileCollectionReusableViewDelegate?
    var delegateSetting : HeaderProfileCollectionReusableViewDelegateSwitchSettingViewController?
    
    var user : User?{
        didSet{
            if user == nil {
                return
            }
            updateView()
        }
    }
    
    var isFollowing : BooleanObject?{
        didSet{
            if isFollowing == nil {
                return
            }
            updateViewFollowButton()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    func updateView() {
        self.nameLabel.text = user!.username
        let profileImageUrlString = user!.profileImage
        let profileImageUrl = URL(string: profileImageUrlString)
        let placeholder = #imageLiteral(resourceName: "placeholder-avatar-profile")
        self.profileImage.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [])
        
        var followingListener , followerListener, countListener :Listener
        
        countListener = Api.MyPosts.observeCountUserPosts(userId: user!.uid, onCompletion: { (numOfPosts) in
            self.myPostsCountLabel.text = "\(numOfPosts)"
        }) { (err) in
            print(err.localizedDescription)
        }
        
        followingListener = Api.Follow.getAllFollowingsCount(followerUserId: user!.uid, onCompletion: { (followingCount) in
            self.followingCountLabel.text = "\(followingCount)"
        }) { (err) in
            print(err.localizedDescription)
        }
        
        followerListener = Api.Follow.getAllFollowersCount(followingUserId: user!.uid, onCompletion: { (followersCount) in
            self.followersCountLabel.text = "\(followersCount)"
        }) { (err) in
            print(err.localizedDescription)
        }
        
        if user?.uid == AuthService.getCurrentUserId(){
            self.followButton.setTitle("Edit Profile", for: .normal)
            self.followButton.addTarget(self, action: #selector(self.goToSettingViewController), for: .touchUpInside)
        }
        
        delegate?.closeListeners(listeners: [followingListener , followerListener , countListener])
    }
    func clear(){
        self.nameLabel.text = ""
        self.myPostsCountLabel.text = ""
        self.followingCountLabel.text = ""
        self.followersCountLabel.text = ""
    }
    
    @objc func goToSettingViewController(){
        delegateSetting?.goToSettingViewController()
    }
    
    func updateViewFollowButton(){
        if user?.uid == AuthService.getCurrentUserId(){
            self.followButton.setTitle("Edit Profile", for: .normal)
        }else{
            updateStateFollowButton()
        }
    }
    
    func updateStateFollowButton(){
        
        
        self.followButton.layer.borderWidth = 1
        self.followButton.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.8941176471, blue: 0.9098039216, alpha: 1)
        self.followButton.layer.cornerRadius = 5
        self.followButton.clipsToBounds = true
        
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
                Api.Follow.followAction(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid , onCompletion: {
                    Api.MyPosts.getUserPosts(userId: self.user!.uid, onCompletion: { (postsIds) in
                        
                        Api.Feed.addPostsToFeed(userId: AuthService.getCurrentUserId()!, postsIds: postsIds)
                        
                    }) { (error) in
                        print(error.localizedDescription)
                        ProgressHUD.showError(error.localizedDescription)
                    }
                                        
                    self.isFollowing!.setBool(bool: true)
                    print("success follow")
                    self.configureUnFollowButton()
                }) { (error) in
                    print(error.localizedDescription)
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
        
        @objc func unfollowAction(){
            if !AuthService.isSignIn(){
                return
            }
            if self.isFollowing!.getBool() == true{
                Api.Follow.unFollowAction(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user!.uid , onCompletion: {
                    Api.MyPosts.getUserPosts(userId: self.user!.uid , onCompletion: { (postsIds) in
                        Api.Feed.removePostsToFeed(userId: AuthService.getCurrentUserId()!, postsIds: postsIds)
                    }) { (error) in
                        print(error.localizedDescription)
                        ProgressHUD.showError(error.localizedDescription)
                    }
                    
                    self.isFollowing!.setBool(bool: false)
                    print("success unfollow")
                    self.configureFollowButton()
                }) { (error) in
                    print(error.localizedDescription)
                    ProgressHUD.showError(error.localizedDescription)
                }
            }
        }
        
}
