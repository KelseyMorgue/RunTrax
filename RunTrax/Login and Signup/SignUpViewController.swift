//
//  SignUpViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/1/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import Firebase





class SignUpViewController:UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    
    // Outlets
    //All of these will need to be grabbed and pushed to the database once the "create user" button is hit
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var newUsers = Database.database().reference()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.newUsers = Database.database().reference().child("User")
    }
   
    
    @IBAction func createAccount(_ sender: Any) {
        addUser()
    }
    
    
    func addUser()
    {
       let key = newUsers.childByAutoId().key
        
        let user = ["Id" : key,
                    "Username" : usernameField.text! as String,
                    "Email" : emailField.text! as String,
                    "Password" : passwordField.text! as String]
        
        //Also need to add the optional profile photo image
        // string -> URL path
        
        newUsers.child(key!).setValue(user)
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func selectedImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        profileImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
}
