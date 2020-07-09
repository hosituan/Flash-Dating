//
//  ProfileViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var emailLabel: UILabel!
    
    
    //MARK: -- This is Main Action
    
    @IBAction func changeAddressButton(_ sender: UIButton) {
    }
    

    @IBAction func logoutButton(_ sender: UIButton) {
        do {
          try Auth.auth().signOut()
        } catch {
          print("Sign out error")
        }
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    //MARK: - Edit Action
    
    @IBOutlet var changeProfilePicture: UILabel!
    @IBAction func editNameButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openFillNameSegue", sender: nil)
    }
    @IBAction func refreshData(_ sender: UIButton) {
        loadData()
        let userInfo = Auth.auth().currentUser
        let data = try? Data(contentsOf: (userInfo?.photoURL!)!)
        print(data)
        //profileImage.image = UIImage(data: data!)
    }
    @IBAction func tapChangeLabel(sender: UITapGestureRecognizer) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = URL(fileURLWithPath: "https://firebase.google.com/downloads/brand-guidelines/PNG/logo-vertical.png?")
        changeRequest?.commitChanges { (error) in
        }

    }
    // MARK: - Configure
    func loadData() {
        let userInfo = Auth.auth().currentUser
        nameLabel.text = userInfo?.displayName
        emailLabel.text = userInfo?.email

        
    }
    func configure() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapChangeLabel))
        changeProfilePicture.isUserInteractionEnabled = true
        changeProfilePicture.addGestureRecognizer(tap)
    }

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configure()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("appear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("disappear")
    }
    

}
