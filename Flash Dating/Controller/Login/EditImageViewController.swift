//
//  EditImageViewController.swift
//  Flash Dating
//
//  Created by Hồ Sĩ Tuấn on 7/10/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class EditImageViewController: ViewController {
    
    @IBOutlet var imageView: UIImageView!
    var isChanged:Bool = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()

    }
    
    //MARK: -- Action
    
    @IBAction func selectButton(_ sender: UIButton) {
        
        
        
        if isChanged == true {
            setImage()
            self.dismiss(animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Message", message: "You have not choosen Profile Image", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    //MARK: --Function
    func setImage(){
        guard let imageData = self.imageView.image!.jpegData(compressionQuality: 1.0) else {
             return
        }
        let storageRef = Storage.storage().reference(forURL: "gs://flash-dating-001.appspot.com/")
        let storageProfileRef = storageRef.child("profile").child(Auth.auth().currentUser!.uid)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        storageProfileRef.putData(imageData, metadata: metadata, completion: {
            (StorageMetadata, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
        })
        storageProfileRef.downloadURL(completion: {
            (url, error) in
            if let metaImageUrl = url?.absoluteString {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = URL(string: metaImageUrl)
                changeRequest?.commitChanges { (error) in
                }
    
                Database.database().reference().child("user").child(Auth.auth().currentUser!.uid).updateChildValues(["profileImageUrl": metaImageUrl], withCompletionBlock: {
                    (error, ref) in
                    if error == nil {
                        print("Done")
                    }
                })
                

            }
        })
    }
    @IBAction func tapImageView(sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    
    //MARK: -- Set up
    func setUp() {
        imageView.layer.cornerRadius = imageView.layer.frame.size.width/2
        imageView.clipsToBounds = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(EditImageViewController.tapImageView))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTap)

    }

    

}


//MARK: --Extension
extension EditImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = imageSelected
            isChanged = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
