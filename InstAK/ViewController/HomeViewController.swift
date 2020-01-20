//
//  HomeViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var users = [String: User]()
    
    var listenersPosts :  [ String : Listener ] = [:]
    
    var Listener : Listener?

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 520
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Listener?.disconnected()
        posts.removeAll()
        users.removeAll()
    }
    
    func loadPosts() {
        activityIndicatorView.startAnimating()
        if !AuthService.isSignIn(){
            return
        }
        
        Listener = Api.Feed.observePostsFromFeed(userId: AuthService.getCurrentUserId()!, onAdded: { (addedPostId) in
            
            self.listenersPosts[addedPostId] = self.observePost(postId: addedPostId)
            
        }, onModified: { (modifiedPostId) in
            print("someway the post id change to \(modifiedPostId)")
            // support this anyway
            self.listenersPosts[modifiedPostId] = self.observePost(postId: modifiedPostId)
            
            
        }, onRemoved: { (removedPostId) in
            
            self.posts.removeAll { (oldPost) -> Bool in
                return oldPost.postId == removedPostId
            }
            self.users.removeValue(forKey: removedPostId)
            print(self.posts)
            self.tableView.reloadData()
            
            self.listenersPosts[removedPostId]?.disconnected()
            self.listenersPosts.removeValue(forKey: removedPostId)
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    
    
    func observePost(postId : String) -> Listener{
        return Api.Post.observePost(postId: postId, onAdded: { (addedPost) in
            
            Api.User.getUser(withId: addedPost.uid!, onCompletion: { (user:User) in
                self.posts.insert(addedPost, at: 0)
                self.users.updateValue(user, forKey: addedPost.postId!)
                print(self.posts)
                self.activityIndicatorView.stopAnimating()
                self.posts.sort { (aPost, bPost) -> Bool in
                    return aPost.timestamp ?? 0 > bPost.timestamp ?? 0
                }
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }, onModified: { (modifiedPost) in
            self.posts.forEach { (oldPost) in
                if oldPost.postId == modifiedPost.postId {
                    oldPost.setData(post: modifiedPost)
                }
            }
            print(self.posts)
            self.tableView.reloadData()
        }, onRemoved: { (removedPost) in
            self.posts.removeAll { (oldPost) -> Bool in
                return oldPost.postId == removedPost.postId
            }
                    
            self.users.removeValue(forKey: removedPost.postId!)
            
            print(self.posts)
            self.tableView.reloadData()
        }, onError: { (err) in
            ProgressHUD.showError(err.localizedDescription)
        })
    }
    
    @IBAction func button_TouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: "CommentSegue", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "CommentSegue"{
            let commentViewController = segue.destination as! CommentViewController
            let postId = sender as! String
            commentViewController.postId = postId
            print("postId=\(postId)")
        }
        
        if segue.identifier == "Feed_ProfileSegue"{
            let profileUserViewController = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserViewController.userId = userId
            print("userId=\(userId)")
        }
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[post.postId!]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: HomeTableViewCellDelegate{
    
    func goToCommentViewController(postId: String) {
        self.performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserViewController(userId: String) {
        self.performSegue(withIdentifier: "Feed_ProfileSegue", sender: userId)
    }
}
