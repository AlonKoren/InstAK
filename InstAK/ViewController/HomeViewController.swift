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
    
    var isFromComment = false
    var isFromProfile = false
//    var Listener : Listener?
    let refreshControl = UIRefreshControl()


    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 520
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action:#selector(refresh),for: .valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromComment && !isFromProfile{
            loadPosts()
        }else{
            isFromComment = false
            isFromProfile = false
        }
    }
    
    @IBAction func refresh_TouchUpInside(_ sender: Any) {
        loadPosts()
    }
    
    @objc func refresh() {
        loadPosts()
    }
    
    func loadPosts() {
        ProgressHUD.show("Loading...", interaction: false)
        listenersPosts.forEach { (key: String, value: Listener) in
            value.disconnected()
        }
        listenersPosts.removeAll()
//        Listener?.disconnected()
        posts.removeAll()
        users.removeAll()
        self.tableView.reloadData()
//        activityIndicatorView.startAnimating()
        if !AuthService.isSignIn(){
            return
        }
        Api.Feed.getPostsFromFeed(userId: AuthService.getCurrentUserId()!, onCompletion: { (postsIds) in
            for postId in postsIds{
                self.listenersPosts[postId] = self.observePost(postId: postId)
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            ProgressHUD.dismiss()
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    
    
    func observePost(postId : String) -> Listener{
        return Api.Post.observePost(postId: postId, onAdded: { (addedPost) in
            
            Api.User.getUser(withId: addedPost.uid, onCompletion: { (user:User) in
                self.posts.append(addedPost)
                self.users.updateValue(user, forKey: addedPost.postId)
                print(self.posts)
//                self.activityIndicatorView.stopAnimating()
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
                    
            self.users.removeValue(forKey: removedPost.postId)
            
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
            isFromComment = true
        }
        
        if segue.identifier == "Feed_ProfileSegue"{
            let profileUserViewController = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserViewController.userId = userId
            print("userId=\(userId)")
            isFromProfile = true
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
        let user = users[post.postId]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: HomeTableViewCellDelegate{
    func onDelete() {
        refresh()
    }
    
    func goToCommentViewController(postId: String) {
        self.performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserViewController(userId: String) {
        self.performSegue(withIdentifier: "Feed_ProfileSegue", sender: userId)
    }
}
