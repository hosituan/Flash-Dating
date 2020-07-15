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
import Koloda
import FirebaseAuth

class HomeViewController: UIViewController {
    

    
    //MARK: -- Declare for Swipe like and Dislike
    
    var userProfileImgsArray:[UIImage] = []
    
    var userArr:[User] = []
    
    @IBOutlet var mainView: KolodaView!
    
    @IBOutlet var dislikeImageSwipe: UIImageView!
    @IBOutlet var likeImageSwipe: UIImageView!
    
    //MARK: -- Declare
    
    
    let userInfo = Auth.auth().currentUser //current user information
    
    let locationManager = CLLocationManager()
    var currentLocation = "37.785834,-122.406417" //set default location
    
    
    

    
    @IBOutlet var infoView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!

    @IBOutlet var likeImage: UIImageView!
    @IBOutlet var dislikeImage: UIImageView!
    //MARK: -- START
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        ERProgressHud.sharedInstance.show(withTitle: "Loading...")
        self.updateLocation {
            //lay tam range la 50000km
            self.getUserInRange(range: 500000) { userProfileImgsArray in
                if (self.userArr.count > 0) {
                    self.nameLabel.text = self.userArr[0].name
                    self.distanceLabel.text = "\(self.userArr[0].distance.rounded()) KM"
                }
                else {
                    self.nameLabel.text = "Nobody here!"
                    self.distanceLabel.text = "0.0KM"
                    let uiImage = UIImage(named: "Logout")
                    self.ageLabel.text = "0"
                    let backgroundColor = UIColor(patternImage: uiImage!)
                    self.mainView.backgroundColor = backgroundColor
                }
                //set up for swipe
                self.mainView.dataSource = self
                self.mainView.delegate = self

                ERProgressHud.sharedInstance.hide()
                
            }


        }
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        
    }
    

    //MARK: -- ACTION

    

    @IBAction func tapLikeImage(Index: Int, sender: UITapGestureRecognizer) {
        checkMatch(index: Index)
        guard self.userArr.count != 0 else {
            return
        }
        updateLike (index: Index) {
        }
    }
    @IBAction func tapDislikeImage(Index: Int, sender: UITapGestureRecognizer) {
        updateDislike (index: Index) {
                
            }

        }

    
    
    //MARK: --Function
    func updateLike(index: Int, completionHandler: @escaping () -> Void) {
        //update total Liked and idLiked
        var likedID = ""
        var totalLike = 0
        Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            likedID = value?["likedID"] as? String ?? ""
            totalLike = value?["totalLike"] as? Int ?? 0
            Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["likedID": "\(likedID),\(self.userArr[index].uid)", "totalLike": totalLike + 1], withCompletionBlock: { (error, ref) in
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
    
    func updateDislike(index: Int, completionHandler: @escaping () -> Void) {
        //update total Liked and idLiked
        var dislikedID = ""
        Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            dislikedID = value?["dislikedID"] as? String ?? ""
            Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["dislikedID": "\(dislikedID),\(self.userArr[index].uid)"], withCompletionBlock: { (error, ref) in
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
    
    func checkMatch(index: Int) {
        var likedID = ""
        Database.database().reference().child("matchDetails").child(userArr[index].uid).observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            likedID = value?["likedID"] as? String ?? ""
            let result = likedID.split(separator: ",")
            for item in result {
                if item == Auth.auth().currentUser!.uid
                {
                    //show alert
                    let alert = UIAlertController(title: "Message", message: "You matched with this people", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    //update for current user, set matchedID += userArr[index]
                    let matchedIDForCurrent = value?["matchedID"] as? String ?? ""
                    let totalMatched = value?["totalMatched"] as? Int ?? 0
                    Database.database().reference().child("matchDetails").child(Auth.auth().currentUser!.uid).updateChildValues(["matchedID": "\(matchedIDForCurrent),\(self.userArr[index].uid)", "totalMatched": totalMatched + 1], withCompletionBlock: { (error, ref) in
                        if error == nil {
                          print("Done update match for current user")
                        }
                    })
                    
                    //update for current user, set matchedID += currentUser.uid
                    Database.database().reference().child("matchDetails").child(self.userArr[index].uid).observeSingleEvent(of: .value, with: { (snapshot) in
                      let valueDestination = snapshot.value as? NSDictionary
                        let matchedIDForDestination = valueDestination?["matchedID"] as? String ?? ""
                        let totalMatchedDestination = valueDestination?["totalMatched"] as? Int ?? 0
                        Database.database().reference().child("matchDetails").child(self.userArr[index].uid).updateChildValues(["matchedID": "\(matchedIDForDestination),\(Auth.auth().currentUser!.uid)", "totalMatched": totalMatchedDestination + 1], withCompletionBlock: { (error, ref) in
                            if error == nil {
                              print("Done update match for destination Match")
                            }
                        })
                        
                      }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                }
            }
            
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
    func getUserInRange(range: Double, completionHandler: @escaping ([UIImage]?) -> Void)
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
                    var count = 0
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
                                //append img to array for swipe
                                guard let urlImg = URL(string: item.photoURL) else { return }
                                UIImage.loadFrom(url: urlImg) { image in
                                    if let image = image {
                                        print("append image to array list")
                                        self.userProfileImgsArray.append(image)
                                        count += 1
                                        if count == arr.count {
                                            print("complete")
                                            completionHandler(self.userProfileImgsArray)
                                        }
                                    } else {
                                        count += 1
                                        if count == arr.count {
                                            print("complete")
                                            completionHandler(self.userProfileImgsArray)
                                        }
                                        print("Image does not exist!")
                                    }
                                }
                            }
                        else //for if at check liked and disliked
                        {
                            count += 1
                            if count == arr.count {
                                print("complete")
                                completionHandler(self.userProfileImgsArray)
                            }
                        }
                    }



                }
            }


                
            }) { (error) in
                   print(error.localizedDescription)
                //completionHandler(self.userProfileImgsArray)
            }

    }
    
    func setInformation(i: Int) {
        self.nameLabel.text = self.userArr[i + 1].name
        self.distanceLabel.text = "\(self.userArr[i + 1].distance.rounded()) KM"
    }
//MARK: --Setup
    func setUp() {
        

        
        likeImageSwipe.isHidden = true
        dislikeImageSwipe.isHidden = true
        
        //mainImage.layer.cornerRadius = 10
        infoView.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 10
        
        //set Interaction
        //let mainImageTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.tapMainImage))
        //mainImage.isUserInteractionEnabled = true
        //mainImage.addGestureRecognizer(mainImageTap)
        
        let likeImageTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.sendSwipeRightAction))
        likeImage.isUserInteractionEnabled = true
        likeImage.addGestureRecognizer(likeImageTap)
        
        let dislikeImageTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.sendSwipeLeftAction))
        dislikeImage.isUserInteractionEnabled = true
        dislikeImage.addGestureRecognizer(dislikeImageTap)

    }
    @objc func sendSwipeRightAction() {
        mainView.swipe(.right)
        
    }
    @objc func sendSwipeLeftAction() {
        mainView.swipe(.left)
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



extension HomeViewController: KolodaViewDelegate {
    
  func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
    self.nameLabel.text = "Nobody here!"
    self.distanceLabel.text = "0.0KM"
    let uiImage = UIImage(named: "Logout")
    self.ageLabel.text = "0"
    let backgroundColor = UIColor(patternImage: uiImage!)
    self.mainView.backgroundColor = backgroundColor
  }
  
  func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
  }
}
extension HomeViewController: KolodaViewDataSource {
      func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return userProfileImgsArray.count
      }
      
      func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView{
        let view = UIImageView(image: userProfileImgsArray[index])
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
      }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection)
    {
        print("we have \(userArr.count) user")
        if (index + 1  < userProfileImgsArray.count) {
            self.nameLabel.text = self.userArr[index + 1].name
            self.distanceLabel.text = "\(self.userArr[index + 1].distance.rounded()) KM"
        }
        if direction == .left {
            tapDislikeImage(Index: index, sender: .init())
            print ("swipe left")
        }
        if direction == .right {
            
            tapLikeImage(Index: index, sender: .init())
            print("swipe right")
        }
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection)
    {
        
        if direction == .left {
            dislikeImageSwipe.isHidden = false
            likeImageSwipe.isHidden = true
        }
        if direction == .right {
            dislikeImageSwipe.isHidden = true
            likeImageSwipe.isHidden = false
        }
        
    }
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        dislikeImageSwipe.isHidden = true
        likeImageSwipe.isHidden = true
        return true
    }
    
    
    
}



//extension for get image from URL
extension UIImage {

public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        if let data = try? Data(contentsOf: url) {
                completion(UIImage(data: data))
        } else {
                completion(nil)
        }
    }
}





