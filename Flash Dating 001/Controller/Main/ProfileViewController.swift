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
    }
    // MARK: - Configure
    func loadData() {
        let userInfo = Auth.auth().currentUser
        nameLabel.text = userInfo?.displayName
        emailLabel.text = userInfo?.email
        
    }
    func update() {
        nameLabel.text = "abc"
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("appear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        print("disappear")
    }
    

}
