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
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var friendsUsername: UILabel!
    
    var friendItem : FriendsItem!
    {
        didSet
        {
            if addButtonOn == true{
                addButton.isHidden = false
            }
            else{
                addButton.isHidden = true
            }
            loadFriend()
        }
    }
    
    //boolean value to show "add" button
    var addButtonOn : Bool = false
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addButton.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadFriend()
    {
        if friendItem != nil
        {
            friendsUsername.text = friendItem.name
            
            //TODO: query on user, for the friends that equals that id
            let storageRef = storage.reference(withPath: "profile_images/\(friendItem?.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
            
            
            
        }
    }
    
    func loadCurrentFriends()
    {
        ref.child("users").child(userID?.uid ?? "derp").child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if self.friendItem != nil
            {
                self.friendsUsername.text = self.friendItem.name
                
                //TODO: query on user, for the friends that equals that id
                let storageRef = self.storage.reference(withPath: "profile_images/\(self.friendItem?.id ?? "derp")/userImage.png")
                let placeHolderImage = UIImage(named: "default")
                self.friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
                
                
                
            }
        }) { (error) in
            print("hello error")
            print(error.localizedDescription)
        }
    }
    
    //adds new friend to user's friendlist
    @IBAction func addButtonClicked(_ sender: UIButton) {
        
        self.userID = Auth.auth().currentUser
        
        //update child id for friends --> pass id of user
        let key = ref.childByAutoId().key
        
      //  let key = ref.child("friends").childByAutoId()
        
        
        
        let updateUser = ["/\(userID!.uid)/friends/\(key ?? "not here ")/" : friendItem.id]
        
        ref.child("users").updateChildValues(updateUser) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
                
            }
        }
        
    }
    
    
    
}
