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


class LoginViewController: UIViewController, FUIAuthDelegate {
    
    
    
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!
    
 
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    @IBAction func loginButton(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!
            ) { (authResult, error) in
                if let error = error as NSError? {
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
        else {
                self.showAlert(message: "Please fill email and password!")
                }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    
    


}
