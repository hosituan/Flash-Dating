//
//  ProfileViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    //MARK: -- Declare
    
    
    @IBOutlet var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl!
    
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
            ERProgressHud.sharedInstance.show(withTitle: "Loading...")
            try Auth.auth().signOut()
            AccessToken.current = nil
            ERProgressHud.sharedInstance.hide()
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
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        loadData()
        loadImage()
        ERProgressHud.sharedInstance.hide()
    }
    @IBAction func tapChangeImg(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "openEditImageSegue", sender: nil)

    }
    @IBAction func tapLogout(sender: UITapGestureRecognizer) {

        do {
            ERProgressHud.sharedInstance.show(withTitle: "Loading...")
            try Auth.auth().signOut()
            AccessToken.current = nil
            ERProgressHud.sharedInstance.hide()
        } catch {
          print("Sign out error")
        }
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)

    }
    
    
    // MARK: - Configure
    @objc func loadData() {
        //ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        let userInfo = Auth.auth().currentUser
        nameLabel.text = userInfo?.displayName
        emailLabel.text = userInfo?.email
    }
     @objc func loadImage() {
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        let userInfo = Auth.auth().currentUser
        if (userInfo?.photoURL != nil) {
            print("loading")
            let data = NSData(contentsOf : (userInfo?.photoURL!)!)
            profileImage.image = UIImage(data: data! as Data)
            profileImage.layer.masksToBounds = false
            profileImage.layer.cornerRadius = profileImage.frame.size.width/2
            profileImage.clipsToBounds = true
            print("loaded")
            ERProgressHud.sharedInstance.hide()
        }
        else {
            ERProgressHud.sharedInstance.hide()
            print("No photo")
        }
    }
    
    //MARK: -- Setup
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
        let tapLogout = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapLogout))
        logoutBigView.addGestureRecognizer(tapLogout)
        
        addressBigView.layer.cornerRadius = 10
        languageBigView.layer.cornerRadius = 10
        logoutBigView.layer.cornerRadius = 10
        self.scrollView.contentSize.height = 1.0
        
        
    }
    @objc func didPullToRefresh() {


        
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        refreshControl?.endRefreshing()
        loadData()
       _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadImage), userInfo: nil, repeats: false)
    
     }


    //MARK: -- Start
    override func viewDidLoad() {
        super.viewDidLoad()
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        setup()
        loadData()
        scrollView.alwaysBounceVertical = true
        scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)

        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadImage), userInfo: nil, repeats: false)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewDidDisappear(_ animated: Bool) {
    }
    

}
