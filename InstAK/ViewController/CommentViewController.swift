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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        empty()
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

   
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        let db = Firestore.firestore()
        let commentsCollection = db.collection("comments")
        let newCommentDocument = commentsCollection.document()
        //let newCommentId = newCommentDocument.documentID

        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        let comment: Comment = Comment(commentText: commentTextField.text!, uid: currentUserId)
        newCommentDocument.setData(try! DictionaryEncoder().encode(comment)){ err in
           if let err = err {
            ProgressHUD.showError(err.localizedDescription)
            return
           }
            self.empty()
        }
    }
    
    func empty() {
        self.commentTextField.text = ""
        textFieldDidChange()
    }
}

