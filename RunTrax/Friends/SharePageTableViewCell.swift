//
//  SharePageTableViewCell.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/7/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
//import FirebaseStorage
import FirebaseUI

class SharePageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendsProfilePicture: UIImageView!
    @IBOutlet weak var friendsUsername: UILabel!
    
        var sharedFriendItem : SharedFriendItem!
    {
        didSet
        {
            loadFriend()
        }
    }
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var shareRunKey : String?
    var sharedFriend : SharedFriendItem?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadFriend()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func loadFriend()
    {
        if sharedFriendItem != nil
        {
            friendsUsername.text = sharedFriendItem.name
            
            //TODO: query on user, for the friends that equals that id
            let storageRef = storage.reference(withPath: "profile_images/\(sharedFriendItem?.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
            
        }
    }
    
    @IBAction func sendRun(_ sender: UIButton) {
        /*
         here imma need to do the query to send that run (from runkey from overview) to the other users "shared run" thing (need to make key)
         
         let key = ref.child("sharedRuns").childByAutoId().key
         self.runKey = key
         let update = [key : runKey!]
         
         let updateUser = ["users/\(sharedFriend!.id)/sharedRuns/\(shareRunKey!)" : run]
         
         // let userDbRef =  newRun.child("users").child(currentUser!.uid)
         newRun.child("users").updateChildValues(updateUser) {
         (error:Error?, ref:DatabaseReference) in
         if let error = error {
         print("Data could not be saved: \(error).")
         } else {
         print("Data saved successfully!")
         }
         }
         */
        
 //ref.child("runs/\(runKey!)").observeSingleEvent(of: .value, with: { (snapshot) in
        
        ref.child("users/\(sharedFriend!.id)").child("sharedRuns/\(shareRunKey!)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            
            
        })
    }
    
    
}
