//
//  HomeTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit
import Kingfisher

import FirebaseFirestore

protocol HomeTableViewCellDelegate {
    func goToCommentViewController(postId : String)
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
    
    var delegate : HomeTableViewCellDelegate?
    
    var post: Post? {
        didSet{
            updateView()
        }
    }
    
    var user: User? {
          didSet{
              setupUserInfo()
          }
      }
      
    
    func updateView() {
        captionLabel.text = post?.caption
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.kf.setImage(with: photoUrl)
        }
        
        if let postId = post?.postId, let userId = AuthService.getCurrentUserId(){
            Api.Post.COLLECTION_POSTS.document(postId).collection("likes").document(userId).getDocument { (documentSnapshot, error) in
                if let err = error {
                    print("error: \(err)")
                    return
                }
                let isLiked = documentSnapshot!.exists
                if isLiked{
                    self.likeImageView.image = #imageLiteral(resourceName: "likeSelected")
                    print("like")
                }else{
                    self.likeImageView.image = #imageLiteral(resourceName: "like")
                    print("unlike")
                }
            }
        }
        
        likeCountButton.titleLabel?.text = "\(post?.likeCount ?? 0) likes"
    }
    
    func setupUserInfo() {
        if let user = user{
            self.nameLabel.text = user.username
            if let profileImageUrlString = user.prifileImage {
                let profileImageUrl = URL(string: profileImageUrlString)
                let placeholder = #imageLiteral(resourceName: "placeholder-avatar-profile")
                self.profileImageView.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [.forceRefresh])
            }else{
                print("profileImageUrlString does not exist")
            }
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
        let db = Firestore.firestore()

        guard let postid = post?.postId, let userId = AuthService.getCurrentUserId() else{
            return
        }
        let postReference = Api.Post.COLLECTION_POSTS.document(postid)
        let likeUsereReference = postReference.collection("likes").document(userId)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument , likeUserPostDocument : DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(postReference)
                try likeUserPostDocument = transaction.getDocument(likeUsereReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var oldLikeCount = postDocument.data()?["likeCount"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve likeCount from snapshot \(postDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            var isIncrement:Bool
            if likeUserPostDocument.exists{ // unlike the post
                oldLikeCount -= 1
                transaction.deleteDocument(likeUsereReference)
                isIncrement = false
            } else {                        // like the post
                oldLikeCount += 1
                transaction.setData([userId:true], forDocument: likeUsereReference)
                isIncrement = true
            }

            transaction.updateData(["likeCount": oldLikeCount], forDocument: postReference)
            return isIncrement
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                let isLiked:Bool = object as! Bool
                
                if isLiked{
                    self.likeImageView.image = #imageLiteral(resourceName: "likeSelected")
                    print("like")
                }else{
                    self.likeImageView.image = #imageLiteral(resourceName: "like")
                    print("unlike")
                }
            }
        }
    }

}
