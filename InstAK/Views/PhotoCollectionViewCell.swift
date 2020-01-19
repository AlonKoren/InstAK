//
//  PhotoCollectionViewCell.swift
//  InstAK
//
//  Created by alon koren on 13/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit


protocol PhotoCollectionViewCellDelegate {
    func goToDetailViewController(postId: String)
}

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
    var delegate : PhotoCollectionViewCellDelegate?
    
    func updateView(){
        print("updateView")
        if let photoUrlString = post!.photoUrl {
            print("photoUrlString")
           let photoUrl = URL(string: photoUrlString)
           photo.kf.setImage(with: photoUrl)
        }
        
        let tapGestureForLikeImage = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(tapGestureForLikeImage)
        photo.isUserInteractionEnabled = true
    }
    
    @objc func photo_TouchUpInside(){
        if let id = post?.postId{
            delegate?.goToDetailViewController(postId: id)
        }
    }
}
