//
//  ProfileUserViewController.swift
//  InstAK
//
//  Created by alon koren on 16/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var posts = [Post]()
    var lisener :Listener?

    var userId : String = ""
    var isFollowing : Bool = false
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("user id= \(userId)")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fechUser()
        fechMyPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lisener?.disconnected()
    }

    func fechUser() {

        
        Api.User.getUser(withId: userId, onCompletion: { (user:User) in
            Api.Follow.isFollowingAfterUser(followerUserId: AuthService.getCurrentUserId()!, followingUserId: user.uid, onCompletion: { (isFollowing) in
                self.user = user
                self.isFollowing = isFollowing
                self.navigationItem.title = user.username
                self.collectionView.reloadData()
            }) { (err) in
                print(err)
            }
            
        }) { (err) in
            print(err)
        }
    }
    
    func fechMyPosts(){
        
        Api.MyPosts.getUserPosts(userId: userId, onCompletion: { (postIds : [String]) in
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


extension ProfileUserViewController:UICollectionViewDataSource{
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
            headerViewCell.isFollowing = BooleanObject.init(bool: isFollowing)
        }
        return headerViewCell
    }
    
    
}

extension ProfileUserViewController: UICollectionViewDelegateFlowLayout{
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

