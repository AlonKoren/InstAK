//
//  ActivityTableViewCell.swift
//  InstAK
//
//  Created by alon koren on 20/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit
protocol ActivityTableViewCellDelegate {
    func goToDetailViewController(postId: String)
//    func goToProfileViewController(userId : String)
}
class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descripitionLabel: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    
    var delegate : ActivityTableViewCellDelegate?
    
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
        switch notification!.type! {
        case "feed":
            descripitionLabel.text = "added a new post"
            Api.Post.getpost(postId: notification!.objectId!, onCompletion: { (post) in
                let postImageUrl = URL(string: post.photoUrl!)
                self.photo.kf.setImage(with: postImageUrl, placeholder: #imageLiteral(resourceName: "placeholder-avatar-profile") ,options: [])
            }) { (error) in
                print(error.localizedDescription)
            }
        default:
            print("")
        }
        if let timestamp = notification?.timestamp{
            showTimestamp(timestamp: timestamp)
        }
        
        let tapGestureForLikeImage = UITapGestureRecognizer(target: self, action: #selector(self.cell_TouchUpInside))
        addGestureRecognizer(tapGestureForLikeImage)
        isUserInteractionEnabled = true
    }
    
    @objc func cell_TouchUpInside(){
        if let id = notification?.objectId{
            delegate?.goToDetailViewController(postId: id)
        }
    }
    
    
    func setUpUserInfo() {
        if let user = user{
            nameLabel.text = user.username
            let profileImageUrlString = user.prifileImage
            let profileImageUrl = URL(string: profileImageUrlString)
            self.profileImage.kf.setImage(with: profileImageUrl, placeholder: #imageLiteral(resourceName: "placeholder-avatar-profile"), options: [])
        }
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
            timeText = "\(diff.second!)s"
        } else if diff.minute! > 0 && diff.hour! == 0{
            timeText = "\(diff.minute!)m"
        }else if diff.hour! > 0 && diff.day! == 0{
            timeText = "\(diff.hour!)h"
        }else if diff.day! > 0 && diff.weekOfMonth! == 0{
            timeText = "\(diff.day!)d"
        }else if diff.weekOfMonth! > 0{
            timeText = "\(diff.weekOfMonth!)w"
        }
        
        timeLabel.text = timeText
    }

}
