//
//  StartPageViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/9/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class StartPageViewController: ViewController, LoginButtonDelegate {
    let loginButton = FBLoginButton()
    @IBOutlet var fbLoginButton: FBLoginButton!
    @IBAction func fbLoginButton(_ sender: UIButton) {
        loginButton.sendActions(for: .touchUpInside)
    }
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
          print(error.localizedDescription)
          return
        }
        GraphRequest(graphPath: "me", parameters: ["fields":"id"]).start { (connection, result, error) in
        if let err = error { print(err.localizedDescription); return } else {
            if let fields = result as? [String:Any], let id = fields["id"] as? String {
                if id != "" {
                    self.signInWithFaceBook()
                }
            }
        }
        }

        
        
    }
    
    func signInWithFaceBook() {
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            
            print(error)
            return
          }
            self.performSegue(withIdentifier: "signInWithFBSegue", sender: nil)
        }
    }


    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout!")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        

    }

    // Swift

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.delegate = self
        loginButton.isHidden = true
        navigationController?.navigationBar.tintColor = .systemPink
        if let token = AccessToken.current,
            !token.isExpired {
            self.performSegue(withIdentifier: "signInWithFBSegue", sender: nil)
        }
    }
        

}
