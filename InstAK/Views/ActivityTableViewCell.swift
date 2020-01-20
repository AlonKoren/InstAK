//
//  ActivityTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 20/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descripitionLabel: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    
    var notification: Notification?{
        didSet{
            updateView()
        }
    }
    
    var user : User?{
        didSet{
            setUpUserInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateView(){
        
    }
    
    
    func setUpUserInfo() {
        if let user = user{
            nameLabel.text = user.username
            let profileImageUrlString = user.prifileImage
            let profileImageUrl = URL(string: profileImageUrlString)
            self.profileImage.kf.setImage(with: profileImageUrl, placeholder: #imageLiteral(resourceName: "placeholder-avatar-profile"), options: [])
        }
    }

}
