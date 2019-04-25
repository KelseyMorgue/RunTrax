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
import FirebaseUI


class AccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var ref = Database.database().reference()
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
            }
            self.sampleUser = user
            self.testauth = auth
            
        }
        self.userID = Auth.auth().currentUser
        
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
                    self.mileageLabel.text = "Mileage: \(mileage) miles"
                    
                }
            }
            
            
        })
        
    }
    
    
   
}
