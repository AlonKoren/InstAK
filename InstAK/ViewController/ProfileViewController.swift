//
//  ProfileViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var posts = [Post]()
    
    var lisener :Listener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        fechUser()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fechMyPosts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lisener?.disconnected()
    }
    
    func fechUser() {
        guard let currentUserId = AuthService.getCurrentUserId() else {
            return
        }
        Api.User.observeUser(withId: currentUserId, onCompletion: { (user:User) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }) { (err) in
            print(err)
        }
    }
    
    func fechMyPosts(){
        guard let currentUserId = AuthService.getCurrentUserId() else {
            return
        }
        
        Api.MyPosts.getUserPosts(userId: currentUserId, onCompletion: { (postIds : [String]) in
            self.lisener?.disconnected()
            self.posts.removeAll()
            if postIds.isEmpty{
                return
            }
            self.lisener = Api.Post.observeSpecificPosts(postsIds: postIds, onAdded: { (addedPost) in
                self.posts.append(addedPost)
                self.collectionView.reloadData()
            }, onModified: { (modifiedpost) in
                self.posts.forEach { (oldPost) in
                    if oldPost.postId == modifiedpost.postId {
                        oldPost.setData(post: modifiedpost)
                    }
                }
                self.collectionView.reloadData()
            }, onRemoved: { (removedPost) in
                self.posts.removeAll { (oldPost) -> Bool in
                    return oldPost.postId == removedPost.postId
                }
                self.collectionView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
}

extension ProfileViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        if let user = self.user{
            headerViewCell.user = user
        }
        return headerViewCell
    }
    
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.size.width / 3 - 1 , height: collectionView.bounds.size.width / 3 - 1 )
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

