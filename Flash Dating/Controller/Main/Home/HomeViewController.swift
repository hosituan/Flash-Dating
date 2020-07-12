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

class HomeViewController: UIViewController {
    

    //MARK: -- Declare
    
    
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
        getUserInRange()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    

    //MARK: -- ACTION
    @IBAction func dislikeSwipe(_ sender: UIButton) {
    }
    @IBAction func likeSwipe(_ sender: UIButton) {
    }
    

    @IBAction func tapMainImage(sender: UITapGestureRecognizer) {

    }
    @IBAction func tapLikeImage(sender: UITapGestureRecognizer) {

    }
    @IBAction func tapDislikeImage(sender: UITapGestureRecognizer) {

    }
    
//MARK: -- Get image
    func getMyLocation(completionHandler: @escaping (String) -> ()){
        let userID = Auth.auth().currentUser?.uid
        var myLocation = ""
        Database.database().reference().child("user").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                myLocation = value?["location"] as? String ?? ""
 
                completionHandler(myLocation)
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserInRange()
    {
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
                        let location = item["location"] as? String
                    else {
                          print("Something is not well")
                         continue
                     }
                    let object = User(email: email, photoURL: photoURL, uid: uid, location: location)
                    arr.append(object)
                }
                print(arr[0].email)
                    
                }
                
            
            }) { (error) in
                   print(error.localizedDescription)
               }
//        getMyLocation { myLocation in
//            let result = myLocation.split(separator: ",")
//            let lat = Double(result[0])!
//            let long = Double(result[1])!
//
//            repeat {
//
//            }
//            while (true)
//            //let value = sqrt( (lat - long) *
//            //print(value)
//
//        }
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


