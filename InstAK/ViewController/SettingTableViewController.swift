//
//  SettingTableViewController.swift
//  InstAK
//
//  Created by alon koren on 16/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

protocol SettingTableViewControllerDelegate {
    func updateUserInfo()
}


class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    private var currentUser : User?{
        didSet{
            if currentUser == nil{
                return
            }
            showUserInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        
        navigationItem.title = "Edit Profile"
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUser()
    }
    
    func getCurrentUser(){
        guard let userId = AuthService.getCurrentUserId() else{
            return
        }
        
        Api.User.getUser(withId: userId, onCompletion: { (currentUser) in
            self.currentUser = currentUser
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }
    
    func showUserInfo(){
        guard let currentUser = currentUser else{
            return
        }
        self.usernameTextField.text = currentUser.username
        self.emailTextField.text = currentUser.email
        
        if let photoUrl = URL(string: currentUser.prifileImage){
            self.profileImageView.kf.setImage(with: photoUrl)
        }
        self.navigationController?.navigationBar.backItem?.title = currentUser.username
    }

    @IBAction func saveBtn_TouchUpInside(_ sender: Any) {
        ProgressHUD.show("Waiting...", interaction: false)
        guard let _ = AuthService.getCurrentUserId() else{
            return
        }
        let user: User = User(user : currentUser!)
        
        if let imageData = self.profileImageView.image!.jpegData(compressionQuality: 0.9){
            StorageService.addProfileImage(uid: user.uid, imageData : imageData, onSuccess: { (url : URL) in
                let profileImageUrl = url.absoluteString
                user.setData(email: self.emailTextField.text!, prifileImage: profileImageUrl, username: self.usernameTextField.text!)
                
                AuthService.updateEmail(newEmail: user.email, onCompletion: {
                    
                    Api.User.updateUserInformation(user: user, onCompletion: {
                        self.view.endEditing(true)
                        ProgressHUD.showSuccess("Success")
                        self.currentUser = user
                        
                    }) { (error) in
                        ProgressHUD.showError(error.localizedDescription)
                    }
                }) { (error) in
                    ProgressHUD.showError(error.localizedDescription)
                }

            }) { (error) in
                ProgressHUD.showError(error.localizedDescription)
            }
        }
        
    }
    
    @IBAction func logoutBtn_TouchUpInside(_ sender: Any) {
        AuthService.signOut(onSuccess: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            signInVC.modalPresentationStyle = .fullScreen
            self.present(signInVC, animated: true, completion: nil)
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
            print(error)
        }
    }
    
    @IBAction func changeProfileBtn_TouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
}


extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("tap")
        if let image = info[UIImagePickerController.InfoKey.originalImage.self] as? UIImage{
            profileImageView.image = image
        };
        dismiss(animated: true, completion: nil)
    }
}

extension SettingTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
