//
//  FillNameViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/9/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase

class FillNameViewController: ViewController {

    

    
    @IBOutlet var nameTextField: UITextField!

    @IBAction func confirmButton(_ sender: UIButton) {
        if nameTextField.text != "" {
            ERProgressHud.sharedInstance.show(withTitle: "Loading...")
            
            // This is create name
            if Auth.auth().currentUser?.displayName == nil {
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = nameTextField.text!
                //this is default image
                changeRequest?.photoURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/flash-dating-001.appspot.com/o/profile%2FhffGUjwyCNV2uAMnnrJh1Emdrwk1?alt=media&token=37363ae0-adb8-4e10-930f-e5918fd20b7c")
                changeRequest?.commitChanges { (error) in
                }
                
                //update name in database
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(["name": nameTextField.text!], withCompletionBlock: {
                    (error, ref) in
                    if error == nil {
                        print("Done Update Name")
                    }
                })
                //hide loading
                ERProgressHud.sharedInstance.hide()
                self.performSegue(withIdentifier: "loginDoneSegue", sender: nil)
            }
            // This is change Name
            else {
                //Update name in Authentication
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = nameTextField.text!
                changeRequest?.commitChanges { (error) in
                }
                //Update name in database
                Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(["name": nameTextField.text!], withCompletionBlock: {
                    (error, ref) in
                    if error == nil {
                        print("Done Update Name")
                    }
                })
                //hide loading
                ERProgressHud.sharedInstance.hide()
                self.dismiss(animated: true, completion: nil)
            }
        }
        //show alert 
        else {
            let alert = UIAlertController(title: "Message", message: "You haven't enter your name!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


