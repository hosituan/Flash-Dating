//
//  RegisterViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/9/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseDatabase
import CoreLocation

class RegisterViewController: ViewController {

    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var repasswordTextField: UITextField!
    @IBAction func signUpButton(_ sender: UIButton) {
        if (passwordTextField.text == repasswordTextField.text) {
            ERProgressHud.sharedInstance.show(withTitle: "Loading...")
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!)
            { (authResult, error) in
                if let error = error as NSError? {
                    ERProgressHud.sharedInstance.hide()
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        break
                    case .emailAlreadyInUse:
                        self.showAlert(message: "Email already in use.")
                        break
                      
                    case .invalidEmail:
                        self.showAlert(message: "Invalid Email.")
                        break
                    case .weakPassword:
                        self.showAlert(message: "The password must be 6 characters long or more.")
                        break
                    default:
                        print("Error: \(error.localizedDescription)")
                    }
              }
              else {
                    
                    ERProgressHud.sharedInstance.hide()
                    if let authUser = authResult {
                        let dict: Dictionary<String, Any>  = [
                            "uid": authUser.user.uid,
                            "email": authUser.user.email!,
                            "name": "",
                            "profileImageUrl": "",
                            "status": "",
                            "location":"",
                            
                        ]
                        Database.database().reference().child("user").child(authUser.user.uid).updateChildValues(dict, withCompletionBlock: {
                            (error, ref) in
                            if error == nil {
                                print("Done")
                            }
                        })
                        
                    }
                    
                    
                self.performSegue(withIdentifier: "openFillNameSegue", sender: nil)
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    


    


}



