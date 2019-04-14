//
//  AccountViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 1/30/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
//import FirebaseStorage
import FirebaseUI


class AccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var sampleUser : User!
    var testauth : Auth!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser == nil
            {
                //TODO: force relogin
            }
            // ...
            self.sampleUser = user
            self.testauth = auth
            
        }
        self.userID = Auth.auth().currentUser
        //print(handle)
        
        displayUser()
        displayImage()
        displayRuns()
        displayMileage()
    }
    
    func displayUser()
    {
        
        ref.child("users").child(userID?.uid ?? "derp").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary
            {
                let username = value["username"] as? String ?? "yeet"
                self.usernameLabel.text = "Username: \(username)"
            }
            
        })
    }
    
    
    //sets up DB to pull current user's profile picture
    func displayImage()
    {
        let storageRef = storage.reference(withPath: "profile_images/\(userID?.uid ?? "derp")/userImage.png")
        let placeHolderImage = UIImage(named: "default")
        profilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
    }
    
    func displayRuns()
    {
        ref.child("users").child(userID?.uid ?? "didn't work").child("runs").observeSingleEvent(of: .value, with: {(snapshot) in
            let count = snapshot.childrenCount
            self.runLabel.text = "Total Runs: \(count)"
            
        })
    }
    
    func displayMileage()
    {
        var sum = 0.00
        ref.child("users").child(userID?.uid ?? "didn't work").child("runs").observeSingleEvent(of: .value, with: {(snapshot) in
            if let runValues = snapshot.value as? NSDictionary
            {
                if let runKeys = runValues.allKeys as? [String]
                {
                    for current in runKeys
                    {
                        if let userValues = runValues[current] as? NSDictionary
                        {
                            let data = userValues["mileage"] as? String
                            if let split = data?.components(separatedBy: " ")
                            {
                                if let distance = Double(split[0])
                                {
                                    sum += distance
                                }
                            }
                        }
                    }
                    let formatter = NumberFormatter()
                    formatter.usesGroupingSeparator = true
                    formatter.numberStyle = .decimal
                    formatter.locale = Locale.current
                    let myNumber = NSNumber(value: sum)
                    let mileage = formatter.string(from: myNumber)!
                    print(mileage, "this is sum")
                    self.mileageLabel.text = "Mileage: \(mileage) miles"
                    
                }
            }
            
            
        })
        
    }
    
    
    //stuff for choosing the image
    // TODO Update the new image into the database
    
//    @IBAction func selectedImage(_ sender: UITapGestureRecognizer) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.delegate = self
//        imagePickerController.allowsEditing = true
//        present(imagePickerController, animated: true, completion: nil)
//        updatePicture()
//
//        
//        
//    }
//    
//    func updatePicture()
//    {
//        let imageName = "userImage.png"
//        let storageRef = Storage.storage().reference().child("profile_images/\(userID.uid)/\(imageName)")
//        if let uploadData = self.profilePicture.image!.pngData() {
//            storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
//                if let err = err {
//                    print(err, "there is an error here")
//                    return
//                }
//                storageRef.downloadURL(completion: { (url, err) in
//                    if let err = err {
//                        print(err, "there is another error here")
//                        return
//                    }
//                }
//                )}
//            )}
//        
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        // Dismiss the picker if the user canceled.
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController,
//                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        var selectedImage: UIImage?
//        
//        // this changes image to what user crops it too
//        if let editedImage = info[.editedImage] as? UIImage {
//            selectedImage = editedImage
//            self.profilePicture.image = selectedImage!
//            picker.dismiss(animated: true, completion: nil)
//
//        } else if let originalImage = info[.originalImage] as? UIImage {
//            selectedImage = originalImage
//            self.profilePicture.image = selectedImage!
//            picker.dismiss(animated: true, completion: nil)
//            
//        }
//
//    }
    
    
    
}
