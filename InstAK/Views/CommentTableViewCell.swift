//
//  CommentTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
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
                self.profileImageView.kf.setImage(with: profileImageUrl, placeholder: placeholder, options: [.forceRefresh])
            }else{
                print("profileImageUrlString does not exist")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        commentLabel.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = #imageLiteral(resourceName: "placeholder-avatar-profile")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
