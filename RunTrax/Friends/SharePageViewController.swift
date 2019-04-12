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

class SharePageViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var shareRun: UIButton!
    
    let ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var sharedFriend : FriendsItem?
    lazy var sharedFriendList: [FriendsItem] = [FriendsItem]()
    var selectedFriends: [FriendsItem] = [FriendsItem]()
    var shareRunKey : String?

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
        shareRun.isEnabled = false
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
                    
                    self.sharedFriendList.append(FriendsItem(name: name, imageUrl: imageUrl, id: id))
                    DispatchQueue.main.async
                        {
                            self.tableView.reloadData()
                    }
                }
                
            }
            
            self.tableView.endUpdates()
            
        }
    }
    
    @IBAction func shareClick(_ sender: Any) {
        shareRunWithSelectedFriends()
    
    }
    private func shareRunWithSelectedFriends() -> Void
        
    {
        
        let key = ref.child("sharedRuns").childByAutoId().key

        print(sharedFriend?.id, "this is the id") //this is nil, need to take in the selected users id
        print(sharedFriendList, "dumped here")
        print(selectedFriends, "heres selected")
        for _ in selectedFriends
        {
        let updateUser = ["/\(sharedFriend!.id)/sharedRuns/\(key)" : shareRunKey!]
        print(updateUser, "updated user")
        // let userDbRef =  newRun.child("users").child(currentUser!.uid)
        ref.child("users").updateChildValues(updateUser as [AnyHashable : Any]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void
        
    {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark
            
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            
        }
            
        else
            
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            
        }
        
        
        
        let selectedCount = (tableView.indexPathsForSelectedRows?.count)!
        
        
        if selectedCount >= 1
            
        {
            
            shareRun.isEnabled = true
            
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
            let storageRef = storage.reference(withPath: "profile_images/\(sharedFriend?.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            cell.friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
            //let storageRef = storage.reference(withPath: "profile_images/\(userID?.uid ?? "derp")/userImage.png")
           
            
            return cell
            
        }
        
        
        return cell
        
    }
    
  
    
}
