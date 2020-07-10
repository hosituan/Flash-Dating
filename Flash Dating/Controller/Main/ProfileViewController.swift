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
    
    
    //Top view
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var emailLabel: UILabel!
    //Second view
    @IBOutlet var matchView: UIView!
    @IBOutlet var totalLoveView: UIView!
    //Third View
    
    @IBOutlet var addressView: UIView!
    
    @IBOutlet var languageView: UIView!
    @IBOutlet var logoutView: UIView!
    @IBOutlet var addressBigView: UIView!
    @IBOutlet var languageBigView: UIView!
    @IBOutlet var logoutBigView: UIView!
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
    

    @IBAction func editNameButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openFillNameSegue", sender: nil)
    }
    @IBAction func refreshData(_ sender: UIButton) {
        loadData()
        loadImage()
    }
    @IBAction func tapChangeImg(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "openEditImageSegue", sender: nil)

    }
    
    // MARK: - Configure
    func loadData() {
        let userInfo = Auth.auth().currentUser
        nameLabel.text = userInfo?.displayName
        emailLabel.text = userInfo?.email
    }
     @objc func loadImage() {
        let userInfo = Auth.auth().currentUser
        if (userInfo?.photoURL != nil) {
            print("loading")
            let data = NSData(contentsOf : (userInfo?.photoURL!)!)
            profileImage.image = UIImage(data: data! as Data)
            profileImage.layer.masksToBounds = false
            profileImage.layer.cornerRadius = profileImage.frame.size.width/2
            profileImage.clipsToBounds = true
            print("loaded")
        }
        else {
            print("No photo")
        }
    }
    func setup() {
        //set image action
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapChangeImg))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tap)
        //set view
        matchView.layer.cornerRadius = 10
        totalLoveView.layer.cornerRadius = 10
        addressView.layer.cornerRadius = addressView.layer.frame.size.width/2
        languageView.layer.cornerRadius = languageView.layer.frame.size.width/2
        logoutView.layer.cornerRadius = logoutView.layer.frame.size.width/2
        addressBigView.layer.cornerRadius = 10
        languageBigView.layer.cornerRadius = 10
        logoutBigView.layer.cornerRadius = 10
        
        
    }

    //MARK: -- Start
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadData()
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadImage), userInfo: nil, repeats: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewDidDisappear(_ animated: Bool) {
    }
    

}
