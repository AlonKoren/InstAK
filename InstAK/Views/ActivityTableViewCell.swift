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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
