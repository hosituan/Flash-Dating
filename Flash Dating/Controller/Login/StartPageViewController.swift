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
import FirebaseDatabase

class StartPageViewController: ViewController, LoginButtonDelegate {
    
//MARK: --Declare
    let loginButton = FBLoginButton()
    @IBOutlet var fbLoginButton: FBLoginButton! //create fb login button then hide it
    @IBAction func fbLoginButton(_ sender: UIButton) {
        loginButton.sendActions(for: .touchUpInside) //send tap action to loginButton
    }
    
//MARK: -- action
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
          print(error.localizedDescription)
          return
        }
        GraphRequest(graphPath: "me", parameters: ["fields":"id"]).start { (connection, result, error) in
        if let err = error { print(err.localizedDescription); return } else {
            if let fields = result as? [String:Any], let id = fields["id"] as? String {
                if id != "" {
                    self.signInWithFaceBook {
                        self.performSegue(withIdentifier: "signInWithFBSegue", sender: nil)
                    }
                }
            }
        }
        }

    }
    func signInWithFaceBook(completionHandler: @escaping() -> Void) {
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            print(error)
            return
          }
            
        //create database in the first time
        if let authUser = authResult {
            Database.database().reference().child("users").child(authUser.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if (value == nil) {
                    print("creating user table")
                    //define field in users table
                    let dict: Dictionary<String, Any>  = [
                        "uid": authUser.user.uid,
                        "email": authUser.user.email!,
                        "name": authUser.user.displayName!,
                        "profileImageUrl": authUser.user.photoURL!.absoluteString,
                        "location":"37.785834,-122.406417",
                    ]
                    //define field in matchDetail
                    let matchDetail: Dictionary<String, Any>  = [
                        "uid": authUser.user.uid,
                        "totalLike": 0,
                        "totalMatched": 0,
                        "likedID": "",
                        "dislikedID": "",
                        "matchedID": "",
                    ]
                     //create child in users table
                    Database.database().reference().child("users").child(authUser.user.uid).updateChildValues(dict, withCompletionBlock: {
                        (error, ref) in
                        if error == nil {
                            print("Done create child in users table")
                        }
                    })

                    //create child in matchDetails table
                    Database.database().reference().child("matchDetails").child(authUser.user.uid).updateChildValues(matchDetail, withCompletionBlock: {
                         (error, ref) in
                         if error == nil {
                             print("Done create child in matchDetails table")
                         }
                     })
                    completionHandler()
                }
                else {
                    completionHandler()
                    print("user not nil")
                }
                  }) { (error) in
                    print("Error at get users")
                    print(error.localizedDescription)
                }
            

            }
        }
    }


    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logout!")
    }
    

    


//MARK: -- Load
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.delegate = self
        loginButton.isHidden = true //hide fblogin button
        navigationController?.navigationBar.tintColor = .systemPink //set color navigation bar
        //check token is expired
        if let token = AccessToken.current,
            !token.isExpired {
            self.performSegue(withIdentifier: "signInWithFBSegue", sender: nil)
        }
    }
        

}
