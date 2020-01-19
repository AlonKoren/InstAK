//
//  HomeTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit
import Kingfisher


protocol HomeTableViewCellDelegate {
    func goToCommentViewController(postId : String)
    func goToProfileUserViewController(userId: String)
}

class HomeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var commentImageView: UIImageView!
    
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var likeCountButton: UIButton!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var heightConstraintPhoto: NSLayoutConstraint!
    
    
    var delegate : HomeTableViewCellDelegate?
    
    var post: Post? {
        didSet{
            if post == nil{
                print("post is nil")
                return
            }
            updateView()
        }
    }
    
    var user: User? {
          didSet{
            if user == nil{
                print("user is nil")
                return
            }
              setupUserInfo()
          }
      }
      
    
    func updateView() {
        captionLabel.text = post?.caption
        print("ratio: \(post?.ratio)")
        if let ratio = post?.ratio {
            print(self.heightConstraintPhoto.constant)
            self.heightConstraintPhoto.constant = UIScreen.main.bounds.size.width / ratio
            print(self.heightConstraintPhoto.constant)
            
        }
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.kf.setImage(with: photoUrl)
        }
        
        
        updateLike(post: post!)
    }
    
    func updateLike(post : Post) {
        
        if let postId = post.postId, let userId = AuthService.getCurrentUserId(){
            Api.Post.isLiked(postId: postId, userId: userId, onCompletion: { (isLiked : Bool) in
                if isLiked{
                    self.likeImageView.image = #imageLiteral(resourceName: "likeSelected")
                }else{
                    self.likeImageView.image = #imageLiteral(resourceName: "like")
                }
            }) { (err) in
                print("error: \(err)")
            }
        }
        if let count = post.likeCount{
            if count != 0{
                likeCountButton.setTitle("\(count) likes!", for: UIControl.State.normal)
            }else{
                likeCountButton.setTitle("Be the first like this", for: UIControl.State.normal)
            }
        }
    }
    
    func setupUserInfo() {
        if let user = user{
            self.nameLabel.text = user.username
            let profileImageUrlString = user.prifileImage
            let profileImageUrl = URL(string: profileImageUrlString)
            let placeholder = #imageLiteral(resourceName: "placeholder-avatar-profile")
            self.profileImageView.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [])
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        captionLabel.text = ""
        
        let tapGestureForComment = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGestureForComment)
        commentImageView.isUserInteractionEnabled = true
        
        let tapGestureForLikeImage = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImage)
        likeImageView.isUserInteractionEnabled = true
        
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
        let tapGestureForProfileImage = UITapGestureRecognizer(target: self, action: #selector(self.profileImage_TouchUpInside))
        profileImageView.addGestureRecognizer(tapGestureForProfileImage)
        profileImageView.isUserInteractionEnabled = true
        
        
    }
    
    
    @objc func nameLabel_TouchUpInside(){
        goToProfileUserViewController()
    }
    
    @objc func profileImage_TouchUpInside(){
        goToProfileUserViewController()
    }
    
    func goToProfileUserViewController(){
        if let userId = user?.uid{
            delegate?.goToProfileUserViewController(userId: userId)
        }
    }
    
    @objc func commentImageView_TouchUpInside(){
        if let postId = post?.postId{
            delegate?.goToCommentViewController(postId: postId)
        }
    }
    
    @objc func likeImageView_TouchUpInside(){
        incrementLikes()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = #imageLiteral(resourceName: "placeholder-avatar-profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func incrementLikes() {
        
        guard let postid = post?.postId, let userId = AuthService.getCurrentUserId() else{
            return
        }
        Api.Post.incrementLike(postId: postid, userId: userId, onCompletion: { (isLiked) in
            if isLiked{
                self.likeImageView.image = #imageLiteral(resourceName: "likeSelected")
            }else{
                self.likeImageView.image = #imageLiteral(resourceName: "like")
            }
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }

    }

}
