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
        self.newUsers = Database.database().reference().child("users")
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        addUser()
        //addQuery()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "startScreen") as! StartScreenViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
//    
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let yourVC = segue.destination as? StartScreenViewController {
//            yourVC.yourData = self.someData
//        }
//    }
    
    
    
    func addUser()
    {
        
        //checks to make sure all are entered (these are required, unlike the image)
        
        guard let email = emailField.text, let password = passwordField.text, let name = usernameField.text else {
            print("Not all fields are completed")
            return
        }
        //        //authenticates user with firebase
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (res, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = res?.user.uid else {
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let uploadData = self.profileImageView.image!.pngData() {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        guard let url = url else { return }
                        let values = ["username": name, "email": email, "profileImageUrl": url.absoluteString]
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    })
                    
                })
            }
        })
        
        
    }
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if let err = err {
                print(err)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    //keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func selectedImage(_ sender: Any) {
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
            self.profileImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.profileImageView.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        }
    }
    func addQuery()
    {
        // DB Check
        let key = newUsers.childByAutoId().key
        
        /*
         Need to make an if statement or something here,
         if username/email already exist then print error
         else set user = []
         */
        
        let user = ["Id" : key,
                    "Username" : usernameField.text! as String,
                    "Email" : emailField.text! as String,
                    "Password" : passwordField.text! as String]
        
        
        
        
        //Also need to add the optional profile photo image
        // string -> URL path
        
        newUsers.child(key!).setValue(user)
    }
    
}
