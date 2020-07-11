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
            if Auth.auth().currentUser?.displayName == nil {
                ERProgressHud.sharedInstance.hide()
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = nameTextField.text!
                changeRequest?.commitChanges { (error) in
                }
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

        // Do any additional setup after loading the view.
    }
}
