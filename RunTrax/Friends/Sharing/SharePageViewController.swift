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
import FirebaseUI

class SharePageViewController: UIViewController, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var shareRun: UIButton!
    
    let ref = Database.database().reference()
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
                }
        }
        self.userID = Auth.auth().currentUser
        let allUsers = ref.child("users").child("username")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loadFriends()
        shareRun.isEnabled = false
    }
    

    func loadFriends()
    {
         self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        ref.child("users").child(userID?.uid ?? "no users here").child("friends").observeSingleEvent(of: .value){(snapshot) in
            
           if let value = snapshot.value as? NSDictionary
           {
            if let friendKeys = value.allValues as? [String]
            {
            for current in friendKeys
            {
                self.ref.child("users").child(current).observeSingleEvent(of: .value)
                {(snapshot) in
                    let friendValue = snapshot.value as? NSDictionary
                    
                    
                    let name = friendValue?["username"] as? String ?? "yeet"
                    let imageUrl = friendValue?["profileImageUrl"] as? String ?? "yeet"
                    let id = current
                    let count = 0
                    
                    self.sharedFriendList.append(FriendsItem(name: name, imageUrl: imageUrl, id: id, runCount: count))
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
    }
    
    @IBAction func shareClick(_ sender: Any) {
        selectFriends()
        shareRunWithSelectedFriends()
    
    }
    
    private func selectFriends() -> Void
    {
        if let selection = tableView.indexPathsForSelectedRows
        {
            for row in selection
            {
                if let currentFriend = (tableView.cellForRow(at: row) as! SharePageTableViewCell).sharedFriend
                {
                    selectedFriends.append(currentFriend)
                }
            }
        }
    }
    
    
    
    
    private func shareRunWithSelectedFriends() -> Void
    {
        for currentFriend in selectedFriends
        {
            if let friendKey = ref.child("users/\(currentFriend.id)/sharedRuns").childByAutoId().key
            {
                print("\(friendKey): is the current key")
                let updateSharedRun = ["/users/\(currentFriend.id)/sharedRuns/\(friendKey)" : shareRunKey]
                ref.updateChildValues(updateSharedRun as [AnyHashable: Any])
                {
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error
                    {
                        let saveAlert = UIAlertController(title: "Run Not Shared 😿", message: "Your run did not share", preferredStyle: .actionSheet)
                        saveAlert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                        self.present(saveAlert, animated: true, completion: nil)
                    }
                    else
                    {
                        
                        let saveAlert = UIAlertController(title: "Run Shared 🏃🏾‍♀️", message: "You have successfully shared a run", preferredStyle: .actionSheet)
                        saveAlert.addAction(UIAlertAction(title: "Okay, return to main screen", style: .cancel, handler:
                            {
                                action in
                                let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
                                self.present(nav,animated: true, completion: nil)
                                
                        }))
                        self.present(saveAlert, animated: true, completion: nil)
                    }
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
            
           cell.sharedFriend = sharedFriendList[indexPath.row]
            
            return cell
            
        }
        
        
        return cell
        
    }
    
  
    
}
