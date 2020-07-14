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
import CoreLocation

class ProfileViewController: UIViewController {
    
    //MARK: -- Declare
    
    let userInfo = Auth.auth().currentUser //current user info from Authenticator
    var currentUser: User? //current user info from database
    var matchDetailsCurrentUser: UserMatchDetail? //current user match detail info from database
    let locationManager = CLLocationManager()
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl!
    
    //Top view
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var emailLabel: UILabel!
    //Second view
    @IBOutlet var matchView: UIView!
    @IBOutlet var matchedLabel: UILabel!
    @IBOutlet var totalLoveView: UIView!
    @IBOutlet var totalLoveLabel: UILabel!
    //Third View
    
    //Button
    @IBOutlet var addressButton: UIButton!
    
    @IBOutlet var languageButton: UIButton!
    
    @IBOutlet var logoutButton: UIButton!
    //--
    @IBOutlet var addressView: UIView!
    
    @IBOutlet var languageView: UIView!
    @IBOutlet var logoutView: UIView!
    
    @IBOutlet var addressBigView: UIView!
    @IBOutlet var languageBigView: UIView!
    @IBOutlet var logoutBigView: UIView!
    //MARK: -- This is Main Action

    //Logout button
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
    //tap logout View action
    @IBAction func tapLogout(sender: UITapGestureRecognizer) {
        logoutButton.sendActions(for: .touchUpInside)
    }
    
    //Edit name Button
    @IBAction func editNameButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openFillNameSegue", sender: nil)
    }
    //tap profile image action
    @IBAction func tapChangeImg(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "openEditImageSegue", sender: nil)

    }
    
    //tapAddress View action
    @IBAction func tapAddress(_ sender: UIButton) {
        addressButton.sendActions(for: .touchUpInside)
    }
    
    //refresh data
    @IBAction func refreshData(_ sender: UIButton) {
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        loadData()
        loadImage()
        ERProgressHud.sharedInstance.hide()
    }



    
    
    
    // MARK: - Configure
    @objc func loadData() {
        nameLabel.text = userInfo?.displayName
        emailLabel.text = userInfo?.email
        getCurrentUserInfo {
            if (self.matchDetailsCurrentUser?.totalLiked != nil && self.matchDetailsCurrentUser?.totalMatched != nil && self.matchDetailsCurrentUser?.totalLiked != 0) {
                print("go to get total love")
                self.totalLoveLabel.text! = String(self.matchDetailsCurrentUser!.totalMatched)
                self.matchedLabel.text! = "\(String(Double(self.matchDetailsCurrentUser!.totalMatched) / Double(self.matchDetailsCurrentUser!.totalLiked) * 100 ))%"
            }
        }
    }
     @objc func loadImage() {
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        let userInfo = Auth.auth().currentUser
        if (userInfo?.photoURL != nil) {
            print("loading")
            
            let data = NSData(contentsOf : (userInfo?.photoURL!)!)
            profileImage.image = UIImage(data: data! as Data)
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
        //set image to beautiful
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        //set view
        matchView.layer.cornerRadius = 10
        totalLoveView.layer.cornerRadius = 10
        
        addressView.layer.cornerRadius = addressView.layer.frame.size.width/2
        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapAddress))
        addressBigView.addGestureRecognizer(tapAddress)
        
        languageView.layer.cornerRadius = languageView.layer.frame.size.width/2
        
        logoutView.layer.cornerRadius = logoutView.layer.frame.size.width/2
        let tapLogout = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.tapLogout))
        logoutBigView.addGestureRecognizer(tapLogout)
        
        addressBigView.layer.cornerRadius = 10
        languageBigView.layer.cornerRadius = 10
        logoutBigView.layer.cornerRadius = 10
        self.scrollView.contentSize.height = 1.0
        
        
    }
    
    
    //Refresh
    @objc func didPullToRefresh() {
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        refreshControl?.endRefreshing()
        loadData()
       _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadImage), userInfo: nil, repeats: false)
     }
    
    //get current user info form database
    func getCurrentUserInfo (completionHandler: @escaping () -> Void) {
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? [String : AnyObject] ?? [:]
            guard let email = value["email"] as? String,
                let photoURL = value["profileImageUrl"] as? String,
                let uid = value["uid"] as? String,
                let location = value["location"] as? String,
                let name = value["name"] as? String
            else {
                print("Error at get user from database")
                return
             }
            //set information to current user from database
            self.currentUser = User(email: email, name: name, photoURL: photoURL, uid: uid, location: location)
            completionHandler()
          }) { (error) in
            print(error.localizedDescription)
        }
        Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? [String : AnyObject] ?? [:]
            guard let uid = value["uid"] as? String,
                let totalLike = value["totalLike"] as? Int,
                let totalMatch = value["totalMatched"] as? Int,
                let likedID = value["likedID"] as? String,
                let dislikedID = value["dislikedID"] as? String,
                let matchedID = value["matchedID"] as? String
            else {
                print("Error at get matchDetail from database")
                return
             }
            //set information to match detail current user from database
            self.matchDetailsCurrentUser = UserMatchDetail(uid: uid, totalMatched: totalMatch, totalLiked: totalLike, likedID: likedID, dislikedID: dislikedID, matchedID: matchedID)
            completionHandler()
          }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }

    //MARK: -- Start
    override func viewDidLoad() {
        super.viewDidLoad()
        //show loading
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        setup()
        loadData()
         //pull to refresh
        scrollView.alwaysBounceVertical = true
        scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
        
        //timer to loading, prevent wait time to open view did load
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadImage), userInfo: nil, repeats: false)
        
        
    }
    
    
    //MARK: --Load
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        getLocation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
}
    //MARK:-- Location

extension ProfileViewController:  CLLocationManagerDelegate {
    func getLocation () {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestLocation()
        }

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            print("error")
            return
        }
        let dict: Dictionary<String, Any>  = [
            "uid": userInfo!.uid,
            "email": userInfo!.email!,
            "name": userInfo!.displayName!,
            "profileImageUrl": userInfo!.photoURL!.absoluteString,
            "location":"\(locValue.latitude),\(locValue.longitude)",
        ]
        Database.database().reference().child("users").child(userInfo!.uid).updateChildValues(dict, withCompletionBlock: {
            (error, ref) in
            if error == nil {
                print("Done Update Location")
            }
        })
        getNameLocation(lat: locValue.latitude, long: locValue.longitude)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getNameLocation(lat:Double,long:Double) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: Double(lat), longitude: Double(long)), completionHandler: { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            else {
                var location = ""
                let pm = placemarks![0]
                
                if pm.country != nil && pm.administrativeArea != nil   {
                    //get f, district, city
                    let upperCaseCity = pm.administrativeArea!.filter({$0.isUppercase})
                    location = "\(pm.subLocality!), \(pm.subAdministrativeArea!), \(upperCaseCity)"
                }
                else{
                    location = "NO_ADDRESS_FOUND"
                }
                print(location)
                self.locationLabel.text = location
            }
        })
    }
}
