//
//  FriendAccountViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/13/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase

class FriendAccountViewController: UIViewController
{
    
    var friend : FriendsItem?
    {
        didSet
        {
            loadFriendProfile()
        }
    }
    
    @IBOutlet weak var friendProfilePicture: UIImageView!
    @IBOutlet weak var friendUsername: UILabel!
    @IBOutlet weak var friendRuns: UILabel!
    @IBOutlet weak var friendMileage: UILabel!
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    override func viewWillAppear(_ animated: Bool)
    {
        handle = Auth.auth().addStateDidChangeListener
            { (auth, user) in
                
                if Auth.auth().currentUser == nil
                {
                }
        }
        self.userID = Auth.auth().currentUser
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadFriendProfile()
        
    }
    func displayRuns()
    {
        ref.child("users").child(friend?.id ?? "didn't work").child("runs").observeSingleEvent(of: .value, with: {(snapshot) in
            let count = snapshot.childrenCount
            self.friendRuns.text = "Total Runs: \(count)"
            
        })
    }
    func displayUsername()
    {
        ref.child("users").child(friend?.id ?? "derp").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary
            {
                let friendsUsername = value["username"] as? String ?? "yeet"
                self.friendUsername.text = "Username: \(friendsUsername)"
            }
            
        })
    }
    
    private func loadFriendProfile()
    {
        if friendProfilePicture != nil && friendRuns != nil && friendMileage != nil && friendUsername != nil
        {
            displayUsername()
            displayImage()
            displayRuns()
            displayMileage()
        }
    }
    
    @IBAction func returnToMain(_ sender: Any)
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
    }
    
    private func displayImage()
    {
        let storageRef = storage.reference(withPath: "profile_images/\(friend?.id ?? "derp")/userImage.png")
        let placeHolderImage = UIImage(named: "default")
        friendProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
    }
    
    private func displayMileage()
    {
        var sum = 0.00
        ref.child("users").child(friend?.id ?? "didn't work").child("runs").observeSingleEvent(of: .value, with: {(snapshot) in
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
                    self.friendMileage.text = "Mileage: \(mileage) miles"
                 
                }
            }
        })
    }
            
            
}
