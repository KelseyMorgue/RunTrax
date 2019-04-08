//
//  SharePageViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 1/29/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
//import FirebaseStorage
import FirebaseUI

class SharePageViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var sharedFriend : SharedFriendItem?
    lazy var sharedFriendList: [SharedFriendItem] = [SharedFriendItem]()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriends()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func returnToMain(_ sender: Any) {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
    }
    func loadFriends()
    {
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        ref.child("users").child(userID?.uid ?? "no users here").child("friends").observeSingleEvent(of: .value){(snapshot) in
            
            
            let value = snapshot.value as? NSDictionary
            let friendKeys = value?.allValues as! [String]
            
            for current in friendKeys
            {
                self.ref.child("users").child(current).observeSingleEvent(of: .value)
                {(snapshot) in
                    let friendValue = snapshot.value as? NSDictionary
                    
                    
                    let name = friendValue?["username"] as? String ?? "yeet"
                    let imageUrl = friendValue?["profileImageUrl"] as? String ?? "yeet"
                    let id = current
                    
                    self.sharedFriendList.append(SharedFriendItem(name: name, imageUrl: imageUrl, id: id))
                    DispatchQueue.main.async
                        {
                            self.tableView.reloadData()
                    }
                }
                
            }
            
            self.tableView.endUpdates()
            
        }
    }
    
}

extension SharePageViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if sharedFriendList.count > 0
        {
            return sharedFriendList.count
        }
        else
        {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! SharePageTableViewCell
        
    
            
         if sharedFriendList.count > 0
        {
            let friend = sharedFriendList[indexPath.row]
            cell.friendsUsername?.text = friend.name
            //cell.friendsProfilePicture = friend.imageUrl
            let storageRef = storage.reference(withPath: "profile_images/\(friend.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            cell.friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
            //
            
            return cell
            
        }
        
        
        return cell
        
    }
    
}
