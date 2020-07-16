//
//  LoginViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import FirebaseUI
import SkyFloatingLabelTextField


class LoginViewController: ViewController, FUIAuthDelegate {
    
    
    //MARK: -- Declare
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet var forgotPasswordLabel: UILabel!
    @IBOutlet var signUpLabel: UILabel!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    
    //MARK: --Login Action
    @IBAction func loginButton(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            ERProgressHud.sharedInstance.show(withTitle: "Loading...")
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!
            ) { (authResult, error) in
                if let error = error as NSError? {
                    ERProgressHud.sharedInstance.hide()
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        break
                    case .userDisabled:
                        self.showAlert(message: "Your account has been disabled!")
                        break
                    case .wrongPassword:
                        self.showAlert(message: "Your email or password is incorrect!")
                        break
                    case .invalidEmail:
                        self.showAlert(message: "Invalid email!")
                        break
                    
                    default:
                        self.showAlert(message: "No user match with this email!")
                        print("Error: \(error.localizedDescription)")
                    }
              }
            else {
                
                let userInfo = Auth.auth().currentUser
                if (userInfo?.displayName == nil) {
                    self.performSegue(withIdentifier: "openFillNameSegue", sender: nil)
                }
                else {
                    self.performSegue(withIdentifier: "loginDoneSegue", sender: nil)
                }
              }
            }
        }
        else {
                self.showAlert(message: "Please fill email and password!")
            }
    }
    
    //MARK: -- Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()

    }
       
    
    //MARK: --Set Up
    func setUp() {
        let signUpLabelTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapSignUpLabel))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(signUpLabelTap)
        let forgotPasswordLabelTap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.forgotPasswordTap))
        forgotPasswordLabel.isUserInteractionEnabled = true
        forgotPasswordLabel.addGestureRecognizer(forgotPasswordLabelTap)
    }
    
    //set up action for label
    @objc func tapSignUpLabel() {
        self.performSegue(withIdentifier: "openSignUpSegue", sender: nil)
    }
    @objc func forgotPasswordTap() {
        if (emailTextField.text != "") {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
          // ...
        }
        showAlert(message: "Sent Email reset password to \(emailTextField.text!). Please check your mail box!")
        }
        else {
            showAlert(message: "You have to fill your email!")
        }
    }
    
    
    
    //MARK: -- Show alert
    func showAlert(message: String) {
           let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(okAction)
           self.present(alert, animated: true, completion: nil)
       }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
