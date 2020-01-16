//
//  SettingTableViewController.swift
//  InstAK
//
//  Created by alon koren on 16/01/2020.
//  Copyright © 2020 Alon Koren. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Profile"
        
        fechCurrentUser()
    }
    
    func fechCurrentUser(){
        guard let userId = AuthService.getCurrentUserId() else{
            return
        }
        
        Api.User.getUser(withId: userId, onCompletion: { (currentUser) in
            self.usernameTextField.text = currentUser.username
            self.emailTextField.text = currentUser.email
            
            if let photoUrl = URL(string: currentUser.prifileImage){
                self.profileImageView.kf.setImage(with: photoUrl)
            }
            
        }) { (error) in
            ProgressHUD.showError(error.localizedDescription)
        }
    }

    @IBAction func saveBtn_TouchUpInside(_ sender: Any) {
    }
    
    @IBAction func logoutBtn_TouchUpInside(_ sender: Any) {
    }
    
    
}
