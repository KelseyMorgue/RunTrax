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
import FirebaseFirestore





class SignUpViewController:UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var counter :Int = 0
    //var ref: DatabaseReference?
    
    
    
    // Outlets
    //All of these will need to be grabbed and pushed to the database once the "create user" button is hit
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var db: Firestore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.delegate = self
        self.emailField.delegate = self
        
        //This one doesn't work??? KELSEY FIX
      self.passwordField.delegate = self
        
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createAccount(_ sender: Any) {
        addUser()
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
    
    
    
    
    
    
    

    //firebase example modified !!!
        private func addUser()
        {
            // Add a new document with a generated ID
            //var ref: DocumentReference? = nil
        
            // Add a new document in collection "cities"
            db.collection("RunTrax").document("User").setData([
                "Username": "Ada",
                "Email": "Lovelace@gmail.com",
                "Password": "password"
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
            
            // [END add_ada_lovelace]

//            print(db.description())
            print("KELSEY HERE")
        }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    //DB Test
//    private func addUser()
//    {
//        //Need to make connection
//        let connection = Database.database().reference()
//
//        //Do the JSON
//
//        let key = connection.child("posts").childByAutoId().key
//
//        //forced post to see if DB works --> later on will change
//        let post =
//            ["Username": "kelseyhenrichsen",
//             "Email": "Kelsey@gmail.com",
//             "Password": "password"]
//
//        let childUpdates = ["/posts/\(key)": post]
//        connection.updateChildValues(childUpdates)
////
////        print(connection.description())
////        // result was: https://fir-app-dfd4d.firebaseio.com
////        // Dad thinks that this means configuration needs update
////
//        counter += 1
//
//}
}
