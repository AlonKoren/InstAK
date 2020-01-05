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

class CameraViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    @objc func handleSelectPhoto()   {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton_TouchUpInside(_ sender: Any) {
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
        //let newPostId = newPostDocument.documentID
        newPostDocument.setData([
            "photoUrl" : photoUrl
        ]){ err in
           if let err = err {
                ProgressHUD.showError(err.localizedDescription)
           } else {
            ProgressHUD.showSuccess("Success")
           }
   }
//        postsCollection.document(uid).setData([
//               "uid": uid,
//               "username": username,
//               "email": email,
//               "profileImage": profileImageUrl
//           ]) { err in
//               if let err = err {
//                   print("Error writing document: \(err)")
//               } else {
//                   print("Document successfully written!")
//                   onSuccess()
//               }
//           }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("tap")
        if let image = info[UIImagePickerController.InfoKey.originalImage.self] as? UIImage{
            selectedImage = image
            photo.image = image
            //textFieldDidChange()
        };
        dismiss(animated: true, completion: nil)
    }
}
