//
//  PhotoCollectionViewCell.swift
//  InstAK
//
//  Created by alon koren on 13/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var photo: UIImageView!
    
    var post: Post?{
        didSet{
            if post == nil{
                return
            }
            updateView()
        }
    }
    
    func updateView(){
        print("updateView")
        if let photoUrlString = post!.photoUrl {
            print("photoUrlString")
           let photoUrl = URL(string: photoUrlString)
           photo.kf.setImage(with: photoUrl)
        }
    }
}
