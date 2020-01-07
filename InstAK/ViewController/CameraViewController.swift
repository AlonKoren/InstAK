//
//  CameraViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class CameraViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
        captionTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetView()
    }
    
    @IBAction func cancel_TouchUpInside(_ sender: Any) {
        resetView()
    }
    
    func resetView(){
        view.endEditing(true)
        self.initPlaceHolder()
        self.photo.image = UIImage(named: "uploadPic_logo")
        self.selectedImage = nil
        postDidChange()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func handleSelectPhoto()   {
        view.endEditing(true)
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func postDidChange() {
        if self.selectedImage != nil{
            self.shareButton.setTitleColor(UIColor.white, for: .normal)
            self.shareButton.isEnabled = true
        }
        else{
            self.shareButton.setTitleColor(UIColor.lightText, for: .normal)
            self.shareButton.isEnabled = false
        }
        isCancelEnabled()
    }
    
    
    func isCancelEnabled(){
        if self.selectedImage == nil && self.isCaptionTextViewEmpty(){
            self.cancelButton.isEnabled = false
        }else{
            self.cancelButton.isEnabled = true
        }
    }
    
    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        if let imageData = self.selectedImage!.jpegData(compressionQuality: 0.9) {
            let photoIdString = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("posts").child(photoIdString)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    let photoUrl = url?.absoluteString
                    self.sendDataToDatabase(photoUrl: photoUrl!)
                })
            }
        }
    }
    
    func sendDataToDatabase(photoUrl : String) {
        let db = Firestore.firestore()
        let postsCollection = db.collection("posts")
        let newPostDocument = postsCollection.document()
        let newPostId = newPostDocument.documentID
        var caption : String = ""
        if (!isCaptionTextViewEmpty()){
            caption = captionTextView.text!
        }
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        let post:Post = Post(captionText: caption, photoUrlString: photoUrl, uid: currentUserId)
        newPostDocument.setData(try! DictionaryEncoder().encode(post)){ err in
           if let err = err {
            ProgressHUD.showError(err.localizedDescription)
           } else {
            db.collection("post-comments").document(newPostId).setData(["comments" : []])
                { err in
                   if let err = err {
                    ProgressHUD.showError(err.localizedDescription)
                   } else {
                    ProgressHUD.showSuccess("Success")
                    self.tabBarController?.selectedIndex = 0
                   }
                }
           }
        }
    }
}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("tap")
        if let image = info[UIImagePickerController.InfoKey.originalImage.self] as? UIImage{
            selectedImage = image
            photo.image = image
            postDidChange()
        };
        dismiss(animated: true, completion: nil)
    }
}

extension CameraViewController: UITextViewDelegate{
    
    func initPlaceHolder(){
        captionTextView.text = "Description"
        captionTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if captionTextView.textColor == UIColor.lightGray{
            captionTextView.text = nil
            captionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.isCancelEnabled()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if captionTextView.text.isEmpty{
            initPlaceHolder()
        }
    }
    
    func isCaptionTextViewEmpty() -> Bool{
        return captionTextView.text.isEmpty || captionTextView.text == "Description" && captionTextView.textColor == UIColor.lightGray
    }
}
