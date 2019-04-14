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
                    //TODO: force relogin
                }
                // ...
        }
        self.userID = Auth.auth().currentUser
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    private func loadFriendProfile()
    {
        
        
        if friendProfilePicture != nil && friendRuns != nil && friendMileage != nil && friendUsername != nil
        {
            loadMoreInfo()
            
            friendUsername.text = friend?.name

        }
    }
    

    private func loadMoreInfo()
    {
        let storageRef = storage.reference(withPath: "profile_images/\(friend?.id ?? "derp")/userImage.png")
        let placeHolderImage = UIImage(named: "default")
        friendProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
    }
    

}
