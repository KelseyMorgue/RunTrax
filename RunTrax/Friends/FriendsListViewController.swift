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
import FirebaseUI

class FriendsListViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate
{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference()
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
                self.tableView.dataSource = self.data
            }
        }
        searchBar.delegate = self
       
        
        let allUsers = ref.child("users").child("username")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        handle = Auth.auth().addStateDidChangeListener
            { (auth, user) in
                
                if Auth.auth().currentUser == nil
                {
                }
        }
        self.userID = Auth.auth().currentUser
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "friendAccount") as! FriendAccountViewController
        
        nav.friend = data?.friends[indexPath.row]
        
        self.present(nav,animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        print("searchText \(String(describing: searchBar.text))")
        searchUsers(searchText: searchBar.text ?? "didn't get it")
        {
            (foundFriends) in
            if foundFriends.count > 0
            {
                self.data = FriendDataSource(friends: foundFriends, found: true)
                self.foundFriends = foundFriends
                self.tableView.dataSource = self.data
            }
        }
    }
    
    private func setUpSearchBar()
    {
        searchBar.delegate = self
    }
    
    func searchUsers(searchText: String, completion: @escaping ([FriendsItem]) -> Void)
    {
        self.tableView.beginUpdates()
        
        
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText.lowercased()).observe(.value, with: {(snapshot) in
            var newFriends = [FriendsItem]()
            if let value = snapshot.value as? NSDictionary
            {
                if let userKeys = value.allKeys as? [String]
                {
                    for currentKey in userKeys
                    {
                        let friendsKeys = self.friendList.compactMap {$0.id }
                        if !friendsKeys.contains(currentKey)
                        {
                            let userValues = value[currentKey] as? NSDictionary
                            let username = userValues?["username"] as? String ?? "yeet"
                            let imageUrl = userValues?["profileImageUrl"] as? String ?? "noppers"
                            
                            self.queryForRuns(friendID: currentKey){ (runTotal) -> () in
                                newFriends.append(FriendsItem(name: username, imageUrl: imageUrl, id: currentKey, runCount: runTotal))
                                DispatchQueue.main.async
                                    {
                                    self.data = FriendDataSource(friends: newFriends, found: true)
                                    self.foundFriends = newFriends
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    self.tableView.endUpdates()
                }
            completion(newFriends)
            }
        })
    }
    
    func loadFriends(completion: @escaping ([FriendsItem]) -> Void)
    {
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        
        ref.child("users").child(userID?.uid ?? "no users here").child("friends").observe( .value, with: {
            (snapshot) in
            var friendz = [FriendsItem]()
            if let value = snapshot.value as? NSDictionary
            {
                if let friendKeys = value.allValues as? [String]
                {
                    for current in friendKeys
                    {
                        self.ref.child("users").child(current).observe( .value, with:
                        {(snapshot) in
                            let friendValue = snapshot.value as? NSDictionary
                            
                            let name = friendValue?["username"] as? String ?? "yeet"
                            let imageUrl = friendValue?["profileImageUrl"] as? String ?? "yeet"
                            let id = current
                            
                            self.queryForRuns(friendID: current)
                            {
                                (result) -> () in 
                            
                                friendz.append(FriendsItem(name: name, imageUrl: imageUrl, id: id, runCount: result))
                                DispatchQueue.main.async {
                                    self.data = FriendDataSource(friends: friendz, found: false)
                                    self.friendList = friendz
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                    self.tableView.endUpdates()
                }
            }
            completion(friendz)
        })
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

