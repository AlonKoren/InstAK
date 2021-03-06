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
    
    var cellListeners = [Listener]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        cellListeners.forEach { (listener) in
            listener.disconnected()
        }
    }
    
    func fechUser() {
        guard let currentUserId = AuthService.getCurrentUserId() else {
            return
        }
        Api.User.getUser(withId: currentUserId, onCompletion: { (user:User) in
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
                self.posts.sort { (aPost, bPost) -> Bool in
                    return aPost.timestamp > bPost.timestamp
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "Profile_DetailSegue"{
            let detailViewController = segue.destination as! DetailViewController
            let postId = sender as! String
            detailViewController.postId = postId
            print("postId=\(postId)")
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
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderProfileCollectionReusableView", for: indexPath) as! HeaderProfileCollectionReusableView
        headerViewCell.delegate = self
        if let user = self.user{
            headerViewCell.user = user
            headerViewCell.delegateSetting = self
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

extension ProfileViewController : HeaderProfileCollectionReusableViewDelegate{
    
    func closeListeners(listeners: [Listener]) {
        cellListeners.append(contentsOf: listeners)
    }
    
}

extension ProfileViewController : HeaderProfileCollectionReusableViewDelegateSwitchSettingViewController{
    
    func goToSettingViewController() {
        self.performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
    
}
extension ProfileViewController : PhotoCollectionViewCellDelegate{
    func goToDetailViewController(postId: String) {
        self.performSegue(withIdentifier: "Profile_DetailSegue", sender: postId)
    }
}
