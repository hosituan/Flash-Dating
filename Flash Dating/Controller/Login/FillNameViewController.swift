//
//  FillNameViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/9/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class FillNameViewController: ViewController {

    

    
    @IBOutlet var nameTextField: UITextField!

    @IBAction func confirmButton(_ sender: UIButton) {
        if nameTextField.text != "" {
            ERProgressHud.sharedInstance.show(withTitle: "Loading...")
            if Auth.auth().currentUser?.displayName == nil {
                ERProgressHud.sharedInstance.hide()
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = nameTextField.text!
                changeRequest?.photoURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/flash-dating-001.appspot.com/o/profile%2FhffGUjwyCNV2uAMnnrJh1Emdrwk1?alt=media&token=37363ae0-adb8-4e10-930f-e5918fd20b7c")
                changeRequest?.commitChanges { (error) in
                }
                let dict: Dictionary<String, Any>  = [
                    "uid": Auth.auth().currentUser!.uid,
                    "name": nameTextField.text!,

                ]
                Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).updateChildValues(dict, withCompletionBlock: {
                    (error, ref) in
                    if error == nil {
                        print("Done")
                    }
                })
                
                
                self.performSegue(withIdentifier: "loginDoneSegue", sender: nil)
            }
            else {
                ERProgressHud.sharedInstance.hide()
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = nameTextField.text!
                changeRequest?.commitChanges { (error) in
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "Message", message: "You have not fill name", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


