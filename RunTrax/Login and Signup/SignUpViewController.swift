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
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var checkFieldsButton: UIButton!
    
    var newUsers = Database.database().reference()
    var appAuth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAccountButton.isHidden = true
        checkFieldsButton.isHidden = false
        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.newUsers = Database.database().reference().child("users")
    }
    
    //button
    @IBAction func createAccount(_ sender: Any) {
        addUser()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "startScreen") as! StartScreenViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    //button
    @IBAction func checkFields(_ sender: Any) {
        usernameCheck(username: usernameField.text ?? "")
    }
    
    //adds user into the database
    func addUser()
    {
        guard let email = emailField.text, let password = passwordField.text, let name = usernameField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (res, error) in
            
            if let error2 = error {
                print(error2)
                return
            }
            
            guard let uid = res?.user.uid else {
                return
            }
            
            //successfully authenticated user
            let key = uid
            let imageName = "userImage.png"
            let storageRef = Storage.storage().reference().child("profile_images/\(key)/\(imageName)")
            if let uploadData = self.profileImageView.image!.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                    if let error = error {
                        print(error, "there is an error here")
                        return
                    }
                    storageRef.downloadURL(completion: { (url, err) in
                        if let err = err {
                            print(err, "there is another error here")
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
    
    //this checks if the user name is already taken
    func usernameCheck(username: String)
    {
        let ref = Database.database().reference()
        
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists(){
                let alert = UIAlertController(title: "Username already exists",
                                              message: "Please try a new username",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:
                    {
                        action in
                        let nav = self.storyboard?.instantiateViewController(withIdentifier: "signUpViewController") as! UIViewController
                        self.present(nav,animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.ifNilCheck()
            }
        })
        
    }
    
    //makes sure all fields are filled out
    func ifNilCheck()
    {
        //checks to make sure all are entered (these are required, unlike the image)
        if emailField.text == "" || passwordField.text == "" || usernameField.text == "" {
            let alert = UIAlertController(title: "Not all fields are completed",
                                          message: "Please be sure to have a username, password, and email",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler:
                {
                    action in
                    let nav = self.storyboard?.instantiateViewController(withIdentifier: "startNav") as! UINavigationController
                    self.present(nav,animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            print("Not all fields are completed")
        }
        else{
            //usernameCheck(username: usernameField.text ?? "")
            createAccountButton.isHidden = false
            checkFieldsButton.isHidden = true
            
        }
    }
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
    
    
    //these functions are for picking an image and allowing cropping etc
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
}
