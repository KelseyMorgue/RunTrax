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

class FriendsListViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate
{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Database stuff
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
    var data : FriendDataSource?
    {
        didSet
        {
            tableView.dataSource = data
            tableView.reloadData()
            
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loadFriends(){(friends) in
            if friends.count > 0
            {
                self.data = FriendDataSource(friends: friends, found: false)
                self.friendList = friends
            }
            
        }
        
        //self.data = FriendDataSource(friends: self.friendList, found: false)
        self.tableView.dataSource = self.data
        searchBar.delegate = self
        
        
        
        //call something to load current friends
        
        let allUsers = ref.child("users").child("username")
        
        
        // Do any additional setup after loading the view.
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "friendAccount") as! FriendAccountViewController
        
        nav.friend = friendList[indexPath.row]
        
        self.present(nav,animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
        print("searchText \(String(describing: searchBar.text))")
        searchUsers(searchText: searchBar.text ?? "didn't get it")
        self.data = FriendDataSource(friends: foundFriends, found: true)
        tableView.dataSource = data
    }
    
    private func setUpSearchBar()
    {
        searchBar.delegate = self
    }
    
    func searchUsers(searchText: String)
    {
        //foundFriends.removeAll()
        self.tableView.beginUpdates()
        
        //see dads query email
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText.lowercased()).observeSingleEvent(of: .value){(snapshot) in
            
            if let value = snapshot.value as? NSDictionary
            {
                if let userKeys = value.allKeys as? [String]
                {
                    //make guard statement about checking users exist
                    for currentKey in userKeys
                    {
                        let userValues = value[currentKey] as? NSDictionary
                        
                        //if (!self.foundFriends.contains(where: { $0.id == currentKey}))
                        // {
                        let username = userValues?["username"] as? String ?? "yeet"
                        let imageUrl = userValues?["profileImageUrl"] as? String ?? "noppers"
                        self.queryForRuns(friendID: currentKey){ (runTotal) -> () in
                            print("Result for runs is: \(runTotal)")
                            self.foundFriends.append(FriendsItem(name: username, imageUrl: imageUrl, id: currentKey, runCount: runTotal))
                            DispatchQueue.main.async {
                                self.data = FriendDataSource(friends: self.foundFriends, found: true)
                                self.tableView.dataSource = self.data
                                self.tableView.reloadData()
                            }
                            
                        }
                        
                        //}
                        
                    }
                   // self.tableView.reloadData()
                    self.tableView.endUpdates()
                }
            }
            
        }
        //        foundFriends.removeAll()
        //        self.tableView.beginUpdates()
        //
        //        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText.lowercased()).observeSingleEvent(of: .value)
        //        {(snapshot) in
        //
        //
        //            //I think I need to go through all the keys and add each key if not in list to foundFriends
        //
        //            let value = snapshot.value as? NSDictionary
        //            let userKeys = value?.allKeys as? [String]
        //
        //            //make guard statement about checking users exist
        //            for currentKey in userKeys!
        //            {
        //                let userValues = value?[currentKey] as? NSDictionary
        //
        //                if (!self.foundFriends.contains(where: { $0.id == currentKey}))
        //                {
        //                    let username = userValues?["username"] as? String ?? "yeet"
        //                    let imageUrl = userValues?["profileImageUrl"] as? String ?? "noppers"
        //
        //                    self.foundFriends.append(FriendsItem(name: username, imageUrl: imageUrl, id: currentKey))
        //                    print("found friends is here", self.foundFriends)
        //                }
        //            }
        //
        //            DispatchQueue.main.async
        //            {
        //                self.tableView.reloadData()
        //            }
        //            self.tableView.endUpdates()
        //
        //        }
        
    }
    
    
    func loadFriends(completion: @escaping ([FriendsItem]) -> Void)
    {
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        var friendz = [FriendsItem]()
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
                            self.queryForRuns(friendID: current)
                            {
                                (result) -> () in print(result)
                            
                                friendz.append(FriendsItem(name: name, imageUrl: imageUrl, id: id, runCount: result))
//                                DispatchQueue.main.async
//                                    {
//
//                                        self.tableView.reloadData()
//                                }
                                
                            }
                        }
                    }
                    self.tableView.endUpdates()
                    completion(friendz)
                }
            }
        
        }
        
    }
    
    private func queryForRuns(friendID : String, completion: @escaping (Int) -> Void) -> Void
    {
        var runCount = 0
        
        ref.child("users").child(friendID).child("runs").observeSingleEvent( of: .value) {(snapshot) in
            let count = snapshot.childrenCount
            runCount = Int(count)
            completion(runCount)
        }
        
    }
    
}

