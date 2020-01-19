//
//  CameraViewController.swift
//  InstAK
//
//  Created by alon koren on 21/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var selectedImage: UIImage?
    var videoUrl : URL?
    
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
        pickerController.mediaTypes = ["public.image", "public.movie"]
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
        if let profileImg = self.selectedImage, let imageData = profileImg.jpegData(compressionQuality: 0.9) {
            let ratio = profileImg.size.width / profileImg.size.height
            let photoIdString = NSUUID().uuidString
            StorageService.addPostImage(postId: photoIdString, imageData: imageData, onSuccess: { (url : URL) in
                let photoUrl = url.absoluteString
                self.sendDataToDatabase(photoUrl: photoUrl, ratio : ratio)
                
            }) { (error) in
                ProgressHUD.showError(error.localizedDescription)
            }
        }
    }
    
    func sendDataToDatabase(photoUrl : String , ratio : CGFloat) {
        
        
        var caption : String = ""
        if (!isCaptionTextViewEmpty()){
            caption = captionTextView.text!
        }

        guard let currentUserId = AuthService.getCurrentUserId() else {
            return
        }
        
        
        Api.Post.addPostToDatabase(caption: caption, photoUrl: photoUrl, uid: currentUserId, ratio : ratio ,onCompletion: { (post : Post) in
            Api.MyPosts.connectUserToPost(userId: currentUserId, postId: post.postId!, onCompletion: { () in

                Api.Feed.addPostToFeed(userId: currentUserId, postId: post.postId!)
                
                
                Api.Follow.getAllFollowers(followingUserId: currentUserId, onCompletion: { (usersIds) in
                    
                    usersIds.forEach { (userId) in
                        Api.Feed.addPostToFeed(userId: userId, postId: post.postId!)
                    }
                    
                    ProgressHUD.showSuccess("Success")
                    self.tabBarController?.selectedIndex = 0
                }) { (e) in
                    ProgressHUD.showError(e.localizedDescription)
                }
                  
                
            }) { (err) in
                ProgressHUD.showError(err.localizedDescription)
            }
            
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
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
        }
        else if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL.self] as? URL{
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl){
                self.videoUrl = videoUrl
                selectedImage = thumbnailImage
                photo.image = thumbnailImage
                postDidChange()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func thumbnailImageForFileUrl(_ fileUrl : URL) -> UIImage?{
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do{
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 10), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err{
            print(err)
        }
        
        return nil
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

