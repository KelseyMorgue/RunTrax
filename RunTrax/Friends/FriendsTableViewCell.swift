//
//  FriendsTableViewCell.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/10/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
//import FirebaseStorage
import FirebaseUI
class FriendsTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var friendsProfilePicture: UIImageView!
    
    @IBOutlet weak var friendsUsername: UILabel!
    
    var friendItem : FriendsItem!
    {
        didSet
        {
            addFriend()
            loadFriend()
        }
    }
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func loadFriend()
    {
        if friendItem != nil
        {
            friendsUsername.text = friendItem.name
            
            //TODO: query on user, for the friends that equals that id
            let storageRef = storage.reference(withPath: "profile_images/\(userID?.uid ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)        }
    }
    
    
    func addFriend()
    {
        // DB Check
        let key = ref.childByAutoId().key
        
        /*
         Need to make an if statement or something here,
         if username/email already exist then print error
         else set user = []
         */
        
//        let friend = ["Id" : key,
//                    "Username" : usernameField.text! as String,
//                    "Email" : emailField.text! as String,
//                    "Password" : passwordField.text! as String]
        let friend =
            [
                "id" : key,
                "currentUser" : userID.uid,
                "username" : "powerade"
                
        ]
        
        
        
        //Also need to add the optional profile photo image
        // string -> URL path
        
        //ref.child(key!).setValue(friend)
        ref.child("users").child(key!).setValue(friend)
    }

}
