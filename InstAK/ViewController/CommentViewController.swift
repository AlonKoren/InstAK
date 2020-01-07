//
//  CommentViewController.swift
//  InstAK
//
//  Created by alon koren on 06/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    
    let postId = "QOB9d5G3w1mqpQ22R1Uw"
    var comments = [Comment]()
    var users = [String : User]()
    var listener : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CommentViewController viewDidLoad")
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("CommentViewController viewDidAppear")
        empty()
        loadComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("CommentViewController viewWillDisappear")
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("CommentViewController viewDidDisappear")
        if let listener = listener{
            listener.remove()
        }
        comments.removeAll()
    }
    
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
        let db = Firestore.firestore()
        listener = db.collection("post-comments").document(postId).collection("comments").addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else{
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                let comment: Comment = try! DictionaryDecoder().decode(Comment.self,from: diff.document.data())
                
                    
                if (diff.type == .added) {
                    print("New comment: \(comment)")
                    self.comments.append(comment)
                    self.fetchUser(uid: comment.uid!){user in
                        self.users.updateValue(user, forKey: comment.commnetId!)
                        self.tableView.reloadData()
                    }
                }
                if (diff.type == .modified) {
                    print("Modified comment: \(comment)")
                    self.comments.removeAll(where: { (oldComment) -> Bool in
                        return oldComment.commnetId == comment.commnetId
                    })
                    self.comments.append(comment)
                }
                if (diff.type == .removed) {
                    print("Removed comment: \(comment)")
                    self.comments.removeAll(where: { (oldComment) -> Bool in
                        return oldComment.commnetId == comment.commnetId
                    })
                    self.users.removeValue(forKey: comment.commnetId!)
                }
            }
            print(self.comments)
            self.tableView.reloadData()
        }
    }
    
    func fetchUser(uid: String, completed: @escaping (User) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
            if let userDocument = document, userDocument.exists{
                let user: User = try! DictionaryDecoder().decode(User.self, from: userDocument.data()!)
                completed(user)
                }else{
                print("document does not exist")
            }
        }
    }
    
    

   // add comment to DB
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        let db = Firestore.firestore()
        let commentsCollection = db.collection("post-comments").document(postId).collection("comments")
        let commentsDocument = commentsCollection.document()
        let newCommentId =  commentsDocument.documentID

        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        let comment: Comment = Comment(commentText: commentTextField.text!, uid: currentUserId,commnetId: newCommentId)
        commentsDocument.setData(try! DictionaryEncoder().encode(comment)){ err in
           if let err = err {
            ProgressHUD.showError(err.localizedDescription)
            return
           }
            self.empty()
            self.hideKeyboard()
        }
    }
    
    func empty() {
        self.commentTextField.text = ""
        textFieldDidChange()
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
        return cell
    }
}
