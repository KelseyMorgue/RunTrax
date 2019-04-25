//
//  SharedRunsTableViewCell.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/12/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage
import FirebaseUI
class SharedRunsTableViewCell: UITableViewCell {

    @IBOutlet weak var friendProfilePicture: UIImageView!
    @IBOutlet weak var friendUsername: UILabel!
    @IBOutlet weak var runDistance: UILabel!
    
    
    var sharedRunItem : SharedRunItem!
    {
        didSet
        {
            loadData()
        }
    }

    var ref = Database.database().reference()
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }
    
    
    func loadData()
    {
        if let run = sharedRunItem
        {
            runDistance.text = "\(run.distance ?? "distance fail")"
            friendUsername.text = "\(run.username ?? "username fail")"
            
            let storageRef = storage.reference(withPath: "profile_images/\(run.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
        }
       
    }
    
}

