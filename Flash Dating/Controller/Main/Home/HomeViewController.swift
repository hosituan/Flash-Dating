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
    
    
    let userInfo = Auth.auth().currentUser
    
    let locationManager = CLLocationManager()
    var currentLocation = ""
    
    
    
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
        updateLocation()
        //lay tam range la 50000km
        getUserInRange(range: 50000) {
            self.setInformation(i: self.index)
            ERProgressHud.sharedInstance.hide()
        }

        
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
        self.index += 1
        self.setInformation(i: self.index)
        //update total Liked and idLiked
        var totalLike = 0
        var likedID = ""
        Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            totalLike = value?["totalMatched"] as? Int ?? 0
            likedID = value?["likedID"] as? String ?? ""
            Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).updateChildValues(["totalLiked": totalLike + 1, "likedID": "\(likedID),\(self.userArr[self.index - 1].uid)"], withCompletionBlock: {
                              (error, ref) in
                              if error == nil {
                                  print("Done Liked")
                              }
                        })
            
          }) { (error) in
            print(error.localizedDescription)
        }





    }
    @IBAction func tapDislikeImage(sender: UITapGestureRecognizer) {
        self.index += 1
        self.setInformation(i: self.index)
        //update total Liked and idLiked
        var dislikedID = ""
        Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            dislikedID = value?["dislikedID"] as? String ?? ""
            Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).updateChildValues(["dislikedID": "\(dislikedID),\(self.userArr[self.index - 1].uid)"], withCompletionBlock: {
                              (error, ref) in
                              if error == nil {
                                  print("Done Liked")
                              }
                        })
            
          }) { (error) in
            print(error.localizedDescription)
        }

    }
    

//MARK: -- Get user info
    func getMyLocation(completionHandler: @escaping ( String, String) -> ()){
        let userID = Auth.auth().currentUser?.uid
        var myLiked = ""
        var myDisliked = ""
        Database.database().reference().child("user").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                myLiked = value?["likedID"] as? String ?? ""
                myDisliked = value?["dislikedID"] as? String ?? ""
                completionHandler(myLiked, myDisliked)
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //Get User in Range
    func getUserInRange(range: Double, completionHandler: @escaping () -> Void)
    {
        //Only get user have not seen
        Database.database().reference().child("user").queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
               if let data = snapshot.value as? [String: Any] {
                    let dataArray = Array(data)
                var arr = [User]()
                let values = dataArray.map { $0.1 }
                for dict in values {
                    let item = dict as! NSDictionary
                    
                    guard let email = item["email"] as? String,
                            let photoURL = item["profileImageUrl"] as? String,
                            let uid = item["uid"] as? String,
                            let location = item["location"] as? String,
                            let name = item["name"] as? String
                    else {
                          print("Something is not well")
                         continue
                     }
                    let object = User(email: email, name: name, photoURL: photoURL, uid: uid, location: location, distance: 0.0)
                    arr.append(object)
                }
                
                self.getMyLocation { myLiked, myDisliked in
                    let result = self.currentLocation.split(separator: ",")
                    let mylocation = CLLocation(latitude: Double(result[0])!, longitude: Double(result[1])!)
                    for item in arr {
                        let locationItem = item.location.split(separator: ",")
                        let currentlocation = CLLocation(latitude: Double(locationItem[0])!, longitude: Double(locationItem[1])!)
                        let distanceInKms = currentlocation.distance(from: mylocation) / 1000
                        //get user have not liked and dislike, not me
                        if (distanceInKms <= range && !myLiked.contains(item.uid) && !myDisliked.contains(item.uid) && item.uid != self.userInfo?.uid)
                        {
                            var subItem = item
                            subItem.distance = distanceInKms
                            self.userArr.append(subItem)
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
        guard i < self.userArr.count else {
            let alert = UIAlertController(title: "Message", message: "No user in range!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        let data = NSData(contentsOf : URL(string: self.userArr[i].photoURL)!)
        self.mainImage.image = UIImage(data: data! as Data)
        self.nameLabel.text = self.userArr[i].name
        self.distanceLabel.text = "\(self.userArr[i].distance.rounded()) KM"
        
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
extension HomeViewController:  CLLocationManagerDelegate {

    func updateLocation () {
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
        self.currentLocation = "\(locValue.latitude),\(locValue.longitude)"
        Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).updateChildValues(["location": self.currentLocation], withCompletionBlock: {
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

//MARK: --Update Location
func updateLocation ()
{
    
}


