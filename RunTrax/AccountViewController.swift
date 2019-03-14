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


class AccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //User inputted
    @IBOutlet weak var profilePicture: UIImageView!
    
    //From Database
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let userID = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUser()
        
    }
    
    // Do any additional setup after loading the view.
    
    // let ref = Database.database().reference()
    
    
    //sets up DB to pull current user's username
    func displayUser()
    {
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            self.usernameLabel.text = "Username: \(username)"
            

            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
    //sets up DB to pull current user's profile picture
    func displayImage()
    {
        
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
//       // let pathReference = storage.reference(withPath: "images/stars.jpg")
//        let imagesRef = storageRef.child("users")
//        let spaceRef = imagesRef.child("")
//
        // Reference to an image file in Firebase Storage
        let reference = storageRef.child("users/profileImageUrl")


        // Placeholder image
        let placeholderImage = UIImage(named: "default.imageset")

        // Load the image using SDWebImage
        profilePicture.sd_setImage(with: reference, placeholderImage: placeholderImage)

        
        
    }
    
    
    
    //stuff for choosing the image
    // TODO Update the new image into the database
    
    @IBAction func selectedImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        // this changes image to what user crops it too
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            self.profilePicture.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.profilePicture.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}
