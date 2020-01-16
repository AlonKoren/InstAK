//
//  CommentTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func goToProfileUserViewController(userId: String)
}

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    var delegate: CommentTableViewCellDelegate?
    
    var comment: Comment? {
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
        commentLabel.text = comment?.commentText
    }
    
    func setupUserInfo() {
        if let user = user{
            self.nameLabel.text = user.username
            if let profileImageUrlString = user.prifileImage {
                let profileImageUrl = URL(string: profileImageUrlString)
                let placeholder = #imageLiteral(resourceName: "placeholder-avatar-profile")
                self.profileImageView.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [])
            }else{
                print("profileImageUrlString does not exist")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        commentLabel.text = ""
        
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
        let tapGestureForProfileImage = UITapGestureRecognizer(target: self, action: #selector(self.profileImage_TouchUpInside))
        profileImageView.addGestureRecognizer(tapGestureForProfileImage)
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = #imageLiteral(resourceName: "placeholder-avatar-profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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

}
