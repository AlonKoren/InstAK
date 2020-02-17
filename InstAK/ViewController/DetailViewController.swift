//
//  DetailViewController.swift
//  InstAK
//
//  Created by alon koren on 19/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var postId : String?
    
    var post : Post?
    var user : User?
    var lisener : Listener?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 520
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPost()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lisener?.disconnected()
    }
    
    func loadPost(){
        guard let postId = postId else {
            ProgressHUD.showError("Post not selected correctly")
            return
        }
        
        
        lisener = Api.Post.observePost(postId: postId, onCompletion: { (post : Post) in
            Api.User.getUser(withId: post.uid, onCompletion: { (user:User) in
                self.post = post
                self.user = user
                
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }, onError: { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }, onNotExist: {
            self.navigationController?.popToRootViewController(animated: true)
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        if segue.identifier == "Detail_CommentSegue"{
            let commentViewController = segue.destination as! CommentViewController
            let postId = sender as! String
            commentViewController.postId = postId
            print("postId=\(postId)")
        }
        
        if segue.identifier == "Detail_ProfileSegue"{
            let profileUserViewController = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserViewController.userId = userId
            print("userId=\(userId)")
        }
    }
}

extension DetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        cell.post = self.post
        cell.user = self.user
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension DetailViewController: HomeTableViewCellDelegate{
    func onDelete() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func goToCommentViewController(postId: String) {
        self.performSegue(withIdentifier: "Detail_CommentSegue", sender: postId)
    }
    
    func goToProfileUserViewController(userId: String) {
        self.performSegue(withIdentifier: "Detail_ProfileSegue", sender: userId)
    }
}
