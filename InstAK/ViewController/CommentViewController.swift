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
    
    let postId = "hzTqqO50h6BFae0hc8lm"
    var comments = [Comment]()
    var listener : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CommentViewController viewDidLoad")
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
        
        listener = db.collection("post-comments").document(postId).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("error geting document: \(error)")
                return
            }else {
                
                let commentsPosts = querySnapshot!.data()!["comments"] as! [String]
                for commentId in commentsPosts{
                    let isExist = self.comments.contains { (comment) -> Bool in
                        return comment.commnetId == commentId
                    }
                    if isExist {
                        continue
                    }
                    db.collection("comments").document(commentId).getDocument { (documentSnapshot, err) in
                        if let err = err {
                            print("error geting document: \(err)")
                            return
                        }
                        let comment: Comment = try! DictionaryDecoder().decode(Comment.self,from: documentSnapshot!.data()!)
                        self.comments.append(comment)
                        print(self.comments)
                    }
                }
                print("success get post-comments")
            }
        }
    }
    
    
    

   // add comment to DB
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        let db = Firestore.firestore()
        let commentsCollection = db.collection("comments")
        let newCommentDocument = commentsCollection.document()
        let newCommentId = newCommentDocument.documentID

        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        let comment: Comment = Comment(commentText: commentTextField.text!, uid: currentUserId,commnetId: newCommentId)
        newCommentDocument.setData(try! DictionaryEncoder().encode(comment)){ err in
           if let err = err {
            ProgressHUD.showError(err.localizedDescription)
            return
           }
            db.collection("post-comments").document(self.postId).updateData(["comments" : FieldValue.arrayUnion([newCommentId])]){
                err in
                if let err = err {
                    print("error updating document: \(err)")
                }else {
                    print("success upload comment")
                }
            }
            self.empty()
        }
    }
    
    func empty() {
        self.commentTextField.text = ""
        textFieldDidChange()
    }
}

