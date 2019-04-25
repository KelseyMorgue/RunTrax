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
import FirebaseUI

class SharePageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendsProfilePicture: UIImageView!
    @IBOutlet weak var friendsUsername: UILabel!
    
    var sharedFriend : FriendsItem!
    {
        didSet
        {
            loadFriend()
        }
    }
    
    var ref = Database.database().reference()
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var shareRunKey : String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadFriend()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func loadFriend()
    {
        if sharedFriend != nil && friendsUsername != nil && friendsProfilePicture != nil
        {
            
            friendsUsername.text = sharedFriend?.name
            
            let storageRef = storage.reference(withPath: "profile_images/\(sharedFriend?.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
            
        }
    }
    
}
