//
//  FriendsListViewController.swift
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

class FriendsListViewController: UIViewController, UISearchBarDelegate
{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var friend : FriendsItem?
    lazy var friendList: [FriendsItem] = [FriendsItem]()
    lazy var foundFriends: [FriendsItem] = [FriendsItem]()
    var userInput = ""
    var searchButtonClicked : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriends()
        searchBar.delegate = self
        
        
        
        //call something to load current friends
        
        let allUsers = ref.child("users").child("username")
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser == nil
            {
                //TODO: force relogin
            }
            // ...
        }
        self.userID = Auth.auth().currentUser
        
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
////        searchUsers(searchText: searchText)
////        print("searchText \(searchText)")
////        searchButtonClicked = true
//
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(String(describing: searchBar.text))")
        searchUsers(searchText: searchBar.text ?? "didn't get it")
        searchButtonClicked = true
    }
    
    private func setUpSearchBar()
    {
        searchBar.delegate = self
    }
    
    func searchUsers(searchText: String)
    {
        foundFriends.removeAll()
        self.tableView.beginUpdates()

        //see dads query email
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText.lowercased()).observeSingleEvent(of: .value){(snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let userKeys = value?.allKeys as? [String]
            
            //make guard statement about checking users exist
            for currentKey in userKeys!
            {
                let userValues = value?[currentKey] as? NSDictionary
                
                //if (!self.foundFriends.contains(where: { $0.id == currentKey}))
               // {
                    let username = userValues?["username"] as? String ?? "yeet"
                    let imageUrl = userValues?["profileImageUrl"] as? String ?? "noppers"
                    
                    self.foundFriends.append(FriendsItem(name: username, imageUrl: imageUrl, id: currentKey))
                //}
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
           // self.tableView.reloadData()
            self.tableView.endUpdates()
        }
        
    }
    
    
    func loadFriends()
    {
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        ref.child("users").child(userID?.uid ?? "no users here").child("friends").observeSingleEvent(of: .value){(snapshot) in
            
            //            for _ in snapshot.children
            //            {
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

                self.friendList.append(FriendsItem(name: name, imageUrl: imageUrl, id: id))
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            }
            //            }
            
            
        }
        
        self.tableView.endUpdates()
        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
   
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    }
    
}
extension FriendsListViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
         have an if searching --> pull all users in DB to search through users (if greater that 0 --> to be sure theres something in it) set addButton to true
         else --> load friends table
         */
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        cell.addButtonOn = false
        
        if searchButtonClicked
        {
            cell.addButtonOn = true
            cell.friendItem = foundFriends[indexPath.row]
        }
            
        else if friendList.count > 0
        {
            // cell.addButtonOn = false
            let friend = friendList[indexPath.row]
            cell.friendsUsername?.text = friend.name
//cell.friendsProfilePicture = friend.imageUrl
            let storageRef = storage.reference(withPath: "profile_images/\(friend.id ?? "derp")/userImage.png")
            let placeHolderImage = UIImage(named: "default")
            cell.friendsProfilePicture.sd_setImage(with: storageRef, placeholderImage: placeHolderImage)
//
            
            return cell
            
        }
        
        ref.child("users").child(userID.uid).child("friends").observe(.value){(snapshot) in
            
            self.tableView.beginUpdates()
            cell.loadFriend()
            self.tableView.reloadData()
            self.tableView.endUpdates()
            
            
        }
        
        return cell
        
        
    }
    
}
