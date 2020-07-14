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
    
    let userInfo = Auth.auth().currentUser
    
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
    @IBOutlet var totalLoveView: UIView!
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
        logoutButton.sendActions(for: .touchUpInside)

    }
    @IBAction func tapAddress(_ sender: UIButton) {
        addressButton.sendActions(for: .touchUpInside)
    }

    
    
    
    // MARK: - Configure
    @objc func loadData() {
        //ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        
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
            "profileImageUrl": userInfo!.photoURL!.absoluteString ?? nil,
            "location":"\(locValue.latitude),\(locValue.longitude)",
        ]
        Database.database().reference().child("user").child(userInfo!.uid).updateChildValues(dict, withCompletionBlock: {
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
                
                if let addrList = pm.addressDictionary?["FormattedAddressLines"] as? [String] {
                    let addressString = addrList.joined(separator: ", ")
                    print(addressString)

                }
                
                if pm.country != nil && pm.administrativeArea != nil   {
                    
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
