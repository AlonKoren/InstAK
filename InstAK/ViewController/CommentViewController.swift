//
//  CommentViewController.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    
    var postId : String!
    var comments = [Comment]()
    var users = [String : User]()
    var listener : Listener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CommentViewController viewDidLoad")
        title = "Comment"
        commentTextField.delegate = self
        tableView.estimatedRowHeight = 77
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView.dataSource = self
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("CommentViewController viewWillAppear")
        self.tabBarController?.tabBar.isHidden = true
        
        empty()
        loadComments()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("CommentViewController viewDidAppear")
//
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("CommentViewController viewWillDisappear")
        self.tabBarController?.tabBar.isHidden = false
        
        listener?.disconnected()
        comments.removeAll()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("CommentViewController viewDidDisappear")
//        
//    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
    }
    @objc func keyboardWillShow(_ notification : NSNotification){
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = -keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification : NSNotification){
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func textFieldDidChange() {
        guard let commentText = commentTextField.text, !commentText.isEmpty
            else{
                sendButton.setTitleColor(UIColor.lightGray, for: .normal)
                sendButton.isEnabled = false
                return
        }
        sendButton.setTitleColor(UIColor.black, for: .normal)
        sendButton.isEnabled = true
    }
    
    // load all comments from DB in realtime
    func loadComments(){
        
        listener = Api.Comment.observeComments(postId: postId, onAdded: { (addComment) in
            self.comments.append(addComment)
            
            Api.User.getUser(withId: addComment.uid! , onCompletion: { (user) in
                self.users.updateValue(user, forKey: addComment.commnetId!)
                self.tableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }, onModified: { (modifiedComment) in
            
            self.comments.removeAll(where: { (oldComment) -> Bool in
                return oldComment.commnetId == modifiedComment.commnetId
            })
            self.comments.append(modifiedComment)
            
            self.tableView.reloadData()
        }, onRemoved: { (removedComment) in
            
            self.comments.removeAll(where: { (oldComment) -> Bool in
                return oldComment.commnetId == removedComment.commnetId
            })
            self.users.removeValue(forKey: removedComment.commnetId!)
            
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

   // add comment to DB
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        
        
        guard let currentUserId = AuthService.getCurrentUserId() else {
           return
       }
        
        Api.Comment.addComment(postId: postId, commentText: commentTextField.text!, userId: currentUserId, onCompletion: { (comment) in
            self.empty()
            self.hideKeyboard()
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    
    func empty() {
        self.commentTextField.text = ""
        textFieldDidChange()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue.identifier =\(String(describing: segue.identifier))")
        
        if segue.identifier == "Comment_ProfileSegue"{
            let profileUserViewController = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileUserViewController.userId = userId
            print("userId=\(userId)")
        }
    }
}

extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment: Comment = self.comments[indexPath.row]
        cell.comment = comment
        cell.user = users[comment.commnetId!]
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate{
    func goToProfileUserViewController(userId: String) {
        self.performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
}
extension CommentViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
