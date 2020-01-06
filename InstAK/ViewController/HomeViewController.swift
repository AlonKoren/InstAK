//
//  HomeViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Kingfisher


class HomeViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var users = [User]()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 520
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        loadPosts()
//        var post = Post(captionText: "George", photoUrlString: "url1")
//        print(post.caption)
//        print(post.photoUrl)
    }
    
    func loadPosts() {
        activityIndicatorView.startAnimating()
        Firestore.firestore().collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print(error!.localizedDescription)
                return
            }
            for diff in snapshot.documentChanges{
                if (diff.type == .added) {
                    print("New Post : \(diff.document.data())")
                    let post:Post = try! DictionaryDecoder().decode(Post.self, from: diff.document.data())
                    self.fetchUser(uid: post.uid!, completed: {
                        self.posts.append(post)
                        print(self.posts)
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.reloadData()
                    })
                    
                }
                if (diff.type == .modified) {
                    print("Modified Post : \(diff.document.data())")
                }
                if (diff.type == .removed) {
                    print("Removed Post : \(diff.document.data())")
                }
            }
            
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
            if let userDocument = document, userDocument.exists{
                let user: User = try! DictionaryDecoder().decode(User.self, from: userDocument.data()!)
                self.users.append(user)
                completed()
                }else{
                print("document does not exist")
            }
        }
    }
    
    @IBAction func logout_TouchUpInside(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }catch let logoutError{
            print(logoutError)
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
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        return cell
    }
}
