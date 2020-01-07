//
//  CommentApi.swift
//  InstAK
//
//  Created by alon koren on 07/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import Foundation
import FirebaseFirestore

class CommentApi {
    private var COLLECTION_POST_COMMENTS = Firestore.firestore().collection("post-comments")
  
    func observeComments(postId:String, onAdded: @escaping (Comment)-> Void , onModified: @escaping (Comment)-> Void , onRemoved: @escaping (Comment)-> Void, onError : @escaping (Error)-> Void){
            COLLECTION_POST_COMMENTS.document(postId).collection("comments")
                .addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                onError(error!)
                return
            }
            for diff in snapshot.documentChanges{
                let comment: Comment = try! DictionaryDecoder().decode(Comment.self,from: diff.document.data())
                if (diff.type == .added) {
                    print("New comment: \(comment)")
                    onAdded(comment)
                }
                if (diff.type == .modified) {
                    print("Modified comment: \(comment)")
                    onModified(comment)
                }
                if (diff.type == .removed) {
                    print("Removed comment: \(comment)")
                    onRemoved(comment)
                }
            }
        }
    }
    
    func addComment(postId: String, commentText: String, userId: String , onCompletion: @escaping (Comment)-> Void, onError : @escaping (Error)-> Void){
        let commentsCollection = COLLECTION_POST_COMMENTS.document(postId).collection("comments")
        let commentsDocument = commentsCollection.document()
        let newCommentId =  commentsDocument.documentID
        
        let comment: Comment = Comment(commentText: commentText, uid: userId,commnetId: newCommentId)
        
        commentsDocument.setData(try! DictionaryEncoder().encode(comment)){ err in
           if let err = err {
            onError(err)
            return
           }
            onCompletion(comment)
        }
    }
}
