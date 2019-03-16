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
    
    //User inputted
    @IBOutlet weak var profilePicture: UIImageView!
    
    //From Database
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
   let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.ref = Database.database().reference().child("users")

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser == nil
            {
                //TODO: force relogin
            }
            // ...
        }
        self.userID = Auth.auth().currentUser
        //print(handle)
        displayUser()
        displayImage()
    }
    
    // Do any additional setup after loading the view.
    
    // let ref = Database.database().reference()
    
    
    //sets up DB to pull current user's username
    func displayUser()
    {
        let ref = Database.database().reference()

        ref.child("users").child(userID?.uid ?? "derp").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? "yeet"
            self.usernameLabel.text = "Username: \(username)"
            }) { (error) in
                print("hello error")
            print(error.localizedDescription)
        }
    }
    
    
    
    //sets up DB to pull current user's profile picture
    func displayImage()
    {
       // let storage = Storage.storage()
     // let key = "fg1eM6pQvMQ5SToiK7q3C16zXFg1"

        let storageRef = storage.reference(withPath: "profile_images/\(userID?.uid ?? "derp")/userImage.png")
        let placeHolderImage = UIImage(named: "default")
        profilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)

        
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
