//
//  LoginViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import FirebaseUI


class LoginViewController: UIViewController, FUIAuthDelegate {
    
    
    
    @IBOutlet weak var usernameTextFeidl: UITextField!
    @IBOutlet weak var passwordTextfeild: UITextField!
    @IBAction func loginButton(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: usernameTextFeidl.text!, password: passwordTextfeild.text!
        ) { (authResult, error) in
          if let error = error as? NSError {
            switch AuthErrorCode(rawValue: error.code) {
            case .operationNotAllowed: break
              // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
            case .userDisabled: break
              // Error: The user account has been disabled by an administrator.
            case .wrongPassword: break
              // Error: The password is invalid or the user does not have a password.
            case .invalidEmail: break
              // Error: Indicates the email address is malformed.
            default:
                print("Error: \(error.localizedDescription)")
            }
          } else {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    


}
