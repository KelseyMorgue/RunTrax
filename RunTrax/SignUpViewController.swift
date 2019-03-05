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





class SignUpViewController:UIViewController, UITextFieldDelegate {
    
    var counter :Int = 0
    var ref: DatabaseReference?
    
    
    
    // Outlets
    //All of these will need to be grabbed and pushed to the database once the "create user" button is hit
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tapToChangeProfileButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.delegate = self
        self.emailField.delegate = self
        
        //This one isn't working??? KELSEY FIX
       self.passwordField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createAccount(_ sender: Any) {
        addUser()
    }
    

    //firebase example modified
        private func addUser()
        {
            // Add a new document with a generated ID
            var ref: DocumentReference? = nil
            ref = db.collection("User").addDocument(data: [
                "Username": "Ada",
                "Email": "Lovelace@gmail.com",
                "Password": "password"
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            // [END add_ada_lovelace]
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
