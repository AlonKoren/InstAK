//
//  HomeViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit
import Kingfisher


class HomeViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var users = [String: User]()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 520
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        loadPosts()
    }
    
    func loadPosts() {
        activityIndicatorView.startAnimating()
        
        Api.Post.observePosts(onAdded: { (addedPost) in
            Api.User.observeUser(withId: addedPost.uid!, onCompletion: { (user:User) in
                self.posts.append(addedPost)
                self.users.updateValue(user, forKey: addedPost.postId!)
                print(self.posts)
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }, onModified: { (modifiedpost) in
            
            self.posts.removeAll { (oldPost) -> Bool in
                return oldPost.postId == modifiedpost.postId
            }
            self.posts.append(modifiedpost)
            print(self.posts)
            self.tableView.reloadData()
        }, onRemoved: { (removedPost) in
            
            self.posts.removeAll { (oldPost) -> Bool in
                return oldPost.postId == removedPost.postId
            }
            self.users.removeValue(forKey: removedPost.postId!)
            print(self.posts)
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func button_TouchUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: "CommentSegue", sender: nil)
    }
    
    
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do{
            try AuthService.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }catch let logoutError{
            print(logoutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "CommentSegue"{
            let commentViewController = segue.destination as! CommentViewController
            let postId = sender as! String
            commentViewController.postId = postId
            print("postId=\(postId)")
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
}
