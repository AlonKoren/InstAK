//
//  HomeTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation


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
    
    @IBOutlet weak var volumeView: UIView!
    
    @IBOutlet weak var volumeButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    

    var delegate : HomeTableViewCellDelegate?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    var isMuted: Bool = true
    
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
        if let ratio = post?.ratio {
            self.heightConstraintPhoto.constant = UIScreen.main.bounds.size.width / ratio
            layoutIfNeeded()
        }
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.kf.setImage(with: photoUrl)
        }
        if let videoUrlString = post?.videoUrl , let videoUrl = URL(string: videoUrlString){
            self.volumeView.isHidden = false
            player = AVPlayer(url: videoUrl)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = postImageView.frame
            playerLayer?.frame.size.width = UIScreen.main.bounds.width
            if let ratio = post?.ratio {
                playerLayer?.frame.size.height = UIScreen.main.bounds.size.width / ratio
            }
            self.contentView.layer.addSublayer(playerLayer!)
            self.volumeView.layer.zPosition = 1
            player?.play()
            player?.isMuted = isMuted
        }

        if let timestamp = post?.timestamp{
            showTimestamp(timestamp: timestamp)
        }
        
        
        updateLike(post: post!)
    }
    
    func showTimestamp(timestamp : Int){
        let timetampDate = Date(timeIntervalSince1970: Double(timestamp))
        let now = Date()
        let componets = Set<Calendar.Component>([.second,.minute,.hour,.day,.weekOfMonth])
        let diff = Calendar.current.dateComponents(componets, from: timetampDate,to: now)
        var timeText = ""
        if diff.second! <= 0{
            timeText = "Now"
        }else if diff.second! > 0 && diff.minute! == 0{
            timeText = (diff.second! == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
        } else if diff.minute! > 0 && diff.hour! == 0{
            timeText = (diff.minute! == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
        }else if diff.hour! > 0 && diff.day! == 0{
            timeText = (diff.hour! == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
        }else if diff.day! > 0 && diff.weekOfMonth! == 0{
            timeText = (diff.day! == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
        }else if diff.weekOfMonth! > 0{
            timeText = (diff.weekOfMonth! == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
        }
        
        timeLabel.text = timeText
    }
    
    
    @IBAction func volumeButton_TochUpInside(_ sender: Any) {
        if isMuted{
            self.isMuted = !isMuted
            self.volumeButton.setImage(#imageLiteral(resourceName: "Icon_Volume"), for: .normal)
        }else{
            self.isMuted = !isMuted
            self.volumeButton.setImage(#imageLiteral(resourceName: "Icon_Mute"), for: .normal)
        }
        player?.isMuted = isMuted
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
        self.volumeView.isHidden = true
        profileImageView.image = #imageLiteral(resourceName: "placeholder-avatar-profile")
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        
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
