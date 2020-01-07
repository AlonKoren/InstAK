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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true

    }
    
    @objc func commentImageView_TouchUpInside(){
        if let postId = post?.postId{
            delegate?.goToCommentViewController(postId: postId)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = #imageLiteral(resourceName: "placeholder-avatar-profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
