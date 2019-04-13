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
    
        var FriendsItem : FriendsItem!
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
    var sharedFriend : FriendsItem?

    
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
        if FriendsItem != nil && friendsUsername != nil && friendsProfilePicture != nil
        {
            
            friendsUsername.text = FriendsItem.name
            
            //TODO: query on user, for the friends that equals that id
            let storageRef = storage.reference(withPath: "profile_images/\(sharedFriend?.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
            
        }
    }
    
}
