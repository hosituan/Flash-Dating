//
//  HomeViewController.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class HomeViewController: UIViewController {
    

    //MARK: -- Declare
    
    
    let userInfo = Auth.auth().currentUser //current user information
    
    let locationManager = CLLocationManager()
    var currentLocation = "37.785834,-122.406417" //set default location
    
    
    
    var userArr:[User] = []
    var index = 0
    
    @IBOutlet var infoView: UIView!
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!

    @IBOutlet var likeImage: UIImageView!
    @IBOutlet var dislikeImage: UIImageView!
    //MARK: -- START
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        ERProgressHud.sharedInstance.showBlurView(withTitle: "Loading...")
        self.updateLocation {
            //lay tam range la 50000km
            self.getUserInRange(range: 500000) {

                self.setInformation(i: self.index)
                
            }
        }
        ERProgressHud.sharedInstance.hide()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        
    }
    

    //MARK: -- ACTION
    @IBAction func dislikeSwipe(_ sender: UIButton) {
        self.index += 1
        self.setInformation(i: self.index)
        
    }
    @IBAction func likeSwipe(_ sender: UIButton) {
        self.index += 1
        self.setInformation(i: self.index)
    }
    

    @IBAction func tapMainImage(sender: UITapGestureRecognizer) {

    }
    @IBAction func tapLikeImage(sender: UITapGestureRecognizer) {
        checkMatch()
        guard self.userArr.count != 0 else {
            return
        }
        updateLike {
            self.index += 1
            if self.index >= self.userArr.count {
                let alert = UIAlertController(title: "Message", message: "No user in range!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.setInformation(i: self.index)
            }

        }
    }
    @IBAction func tapDislikeImage(sender: UITapGestureRecognizer) {
        updateDislike {
            self.index += 1
            if self.index >= self.userArr.count {
                let alert = UIAlertController(title: "Message", message: "No user in range!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.setInformation(i: self.index - 1)
            }

        }
    }
    
    
    //MARK: --Function
    func updateLike(completionHandler: @escaping () -> Void) {
        //update total Liked and idLiked
        var likedID = ""
        var totalLike = 0
        Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            likedID = value?["likedID"] as? String ?? ""
            totalLike = value?["totalLike"] as? Int ?? 0
            Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["likedID": "\(likedID),\(self.userArr[self.index].uid)", "totalLike": totalLike + 1], withCompletionBlock: { (error, ref) in
                if error == nil {
                  print("Done Liked")
                }
                completionHandler()
                })
            
          }) { (error) in
            print(error.localizedDescription)
            completionHandler()
        }
    }
    
    func updateDislike(completionHandler: @escaping () -> Void) {
        //update total Liked and idLiked
        var dislikedID = ""
        Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            dislikedID = value?["dislikedID"] as? String ?? ""
            Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["dislikedID": "\(dislikedID),\(self.userArr[self.index].uid)"], withCompletionBlock: { (error, ref) in
                if error == nil {
                  print("Done Disliked")
                }
                completionHandler()
                })
            
          }) { (error) in
            print(error.localizedDescription)
            completionHandler()
        }
    }
    
    func checkMatch() {
        var likedID = ""
        Database.database().reference().child("matchDetails").child(userArr[index].uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            likedID = value?["likedID"] as? String ?? ""
            let result = likedID.split(separator: ",")
            for item in result {
                if item == Auth.auth().currentUser!.uid
                {
                    print("matched")
                    
                    //update for current user, set matchedID += userArr[index]
                    let matchedIDForCurrent = value?["matchedID"] as? String ?? ""
                    let totalMatched = value?["totalMatched"] as? Int ?? 0
                    Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["matchedID": "\(matchedIDForCurrent),\(self.userArr[self.index].uid)", "totalMatched": totalMatched + 1], withCompletionBlock: { (error, ref) in
                        if error == nil {
                          print("Done update match for current user")
                        }
                    })
                    
                    //update for current user, set matchedID += currentUser.uid
                    Database.database().reference().child("matchDetails").child(self.userArr[self.index].uid).observeSingleEvent(of: .value, with: { (snapshot) in
                      let valueDestination = snapshot.value as? NSDictionary
                        let matchedIDForDestination = valueDestination?["matchedID"] as? String ?? ""
                        let totalMatchedDestination = valueDestination?["totalMatched"] as? Int ?? 0
                        Database.database().reference().child("matchDetails").child(self.userArr[self.index].uid).updateChildValues(["matchedID": "\(matchedIDForDestination),\(Auth.auth().currentUser!.uid)", "totalMatched": totalMatchedDestination + 1], withCompletionBlock: { (error, ref) in
                            if error == nil {
                              print("Done update match for destination Match")
                            }
                        })
                        
                      }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                }
            }
            
//            Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["likedID": "\(likedID),\(self.userArr[self.index].uid)", "totalLike": totalLike + 1], withCompletionBlock: { (error, ref) in
//                if error == nil {
//                  print("Done Liked")
//                }
//                completionHandler()
//                })
            
          }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    

//MARK: -- Get user info
    //get like and dislike id
    func getLikeAndDislike(completionHandler: @escaping ( String, String) -> ()){
        let userID = Auth.auth().currentUser?.uid
        var myLiked = ""
        var myDisliked = ""
        Database.database().reference().child("matchDetails").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                myLiked = value?["likedID"] as? String ?? ""
                myDisliked = value?["dislikedID"] as? String ?? ""
                completionHandler(myLiked, myDisliked)
          }) { (error) in
            print("Error at get like and dislike ID")
            print(error.localizedDescription)
        }
    }
    
//MARK: --Get User in Range
    func getUserInRange(range: Double, completionHandler: @escaping () -> Void)
    {
        //Only get user have not liked or disliked
        //Get first 20 users, i will imporve algorthm later
        Database.database().reference().child("users").queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
               if let data = snapshot.value as? [String: Any] {
                    let dataArray = Array(data)
                var arr = [User]() //this is user array list, have 20 users
                let values = dataArray.map { $0.1 }
                for dict in values {
                    let item = dict as! NSDictionary
                    
                    guard let email = item["email"] as? String,
                            let name = item["name"] as? String,
                            let photoURL = item["profileImageUrl"] as? String,
                            let uid = item["uid"] as? String,
                            let location = item["location"] as? String
                    else {
                          print("Error at get users in ranges")
                         continue
                     }
                    //append user to User array list, i have not set distance here
                    let object = User(email: email, name: name, photoURL: photoURL, uid: uid, location: location, distance: 0.0)
                    arr.append(object)
                }
                
                //used it to remove user liked or disliked
                self.getLikeAndDislike { myLiked, myDisliked in
                    let result = self.currentLocation.split(separator: ",") //split to get latitude and longtitude
                    let mylocation = CLLocation(latitude: Double(result[0])!, longitude: Double(result[1])!)
                    for item in arr {
                        let locationItem = item.location.split(separator: ",") //get location (String) in each user
                        //convert to Location type
                        let currentlocation = CLLocation(latitude: Double(locationItem[0])!, longitude: Double(locationItem[1])!)
                        let distanceInKms = currentlocation.distance(from: mylocation) / 1000 //calculater distance in kilometers
                        //get user have not liked, dislike and not me
                        if (distanceInKms <= range && !myLiked.contains(item.uid) && !myDisliked.contains(item.uid) && item.uid != self.userInfo?.uid)
                            {
                                //because i can't change item value, so i need an subItem
                                var subItem = item
                                subItem.distance = distanceInKms
                                self.userArr.append(subItem) //this is userArr, have distance
                                completionHandler()
                            }
                    }

                }
                
            }
                
            }) { (error) in
                   print(error.localizedDescription)
                completionHandler()
            }

    }
    
    func setInformation(i: Int) {
        let data = NSData(contentsOf : URL(string: self.userArr[i].photoURL)!)
        self.mainImage.image = UIImage(data: data! as Data)
        self.nameLabel.text = self.userArr[i].name
        self.distanceLabel.text = "\(self.userArr[i].distance.rounded()) KM"
        ERProgressHud.sharedInstance.hide()
    }
//MARK: --Setup
    func setUp() {
        mainImage.layer.cornerRadius = 10
        infoView.layer.cornerRadius = 10
        
        //set Interaction
        let mainImageTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.tapMainImage))
        mainImage.isUserInteractionEnabled = true
        mainImage.addGestureRecognizer(mainImageTap)
        
        let likeImageTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.tapLikeImage))
        likeImage.isUserInteractionEnabled = true
        likeImage.addGestureRecognizer(likeImageTap)
        
        let dislikeImageTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.tapDislikeImage))
        dislikeImage.isUserInteractionEnabled = true
        dislikeImage.addGestureRecognizer(dislikeImageTap)


    }
    

}


//MARK: -- Get location
extension HomeViewController:  CLLocationManagerDelegate {

    func updateLocation (completionHandler: @escaping () -> Void) {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestLocation()
            completionHandler()
        }

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            print("error")
            return
        }
        self.currentLocation = "\(locValue.latitude),\(locValue.longitude)"
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).updateChildValues(["location": self.currentLocation], withCompletionBlock: {
            (error, ref) in
            if error == nil {
                print("Done Updated Location")
            }
        })
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}




