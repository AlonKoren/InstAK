//
//  SignInViewController.swift
//  InstAK
//
//  Created by alon koren on 17/12/2019.
//  Copyright © 2019 Alon Koren. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        textFieldDidChange()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AuthService.isSignIn() {
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        }
    }

    @IBAction func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty ,
            let password = passwordTextField.text, !password.isEmpty
            else{
                signInButton.setTitleColor(UIColor.lightText, for: .normal)
                signInButton.isEnabled = false
                return
               }
            signInButton.setTitleColor(UIColor.white, for: .normal)
            signInButton.isEnabled = true
    }
    
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting...", interaction: false)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        }, onError: { error in
            ProgressHUD.showError(error!)
        })
    
    }
    

}
extension SignInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
