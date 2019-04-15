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
//import FirebaseStorage
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
    var friendItem : FriendsItem!

    var ref = Database.database().reference()
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        // Configure the view for the selected state
    }
    
    
    func loadData()
    {
        if let run = sharedRunItem
        {
            runDistance.text = "\(run.distance ?? "distance fail")"
            friendUsername.text = "\(run.username ?? "username fail")"
            let storageRef = storage.reference(withPath: "profile_images/\(friendItem?.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            friendProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
        }
       
    }
    
}

