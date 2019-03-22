//
//  ViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 11/15/18.
//  Copyright © 2018 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class StartScreenViewController: UIViewController {

    //Properties
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var pastRunsButton: UIButton!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var sharedRunsButton: UIButton!
    @IBOutlet weak var newRunButton: UIButton!
    
    //Actions
    
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser == nil
            {
                //TODO: force relogin
                print("flub!~")
            }
            // ...
        }
        self.userID = Auth.auth().currentUser
        
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let nav = self.storyboard?.instantiateViewController(withIdentifier: "startNav") as! UINavigationController
            self.present(nav,animated: true, completion: nil)

        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
    
}

