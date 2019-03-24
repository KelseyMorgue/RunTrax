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

class FriendsListViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate
{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    let ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    var friend : FriendsItem?
    lazy var friendList: [String] = [String]()
    var userInput = ""
    var searchButtonClicked : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUsers(searchText: searchText)
        print("searchText \(searchText)")
        searchButtonClicked = true
        
    }
    
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
        
        
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText).observeSingleEvent(of: .value){(snapshot) in
            
            //  let value = snapshot.value as? NSDictionary
            print("in the query")
            for case let result as DataSnapshot in snapshot.children
            {
                print(result.value ?? "derpppy")
                print(searchText, "search text value")
                
                self.friend = FriendsItem(name:result.value as! String, imageUrl: "", id: result.key)
                
            }
            
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if friendList.count > 0
        {
            return friendList.count
        }
        else
        {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
         have an if searching --> pull all users in DB to search through users (if greater that 0 --> to be sure theres something in it) set addButton to true
         else --> load friends table
         */
        if searchButtonClicked
        {
        }
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
            
            //cell.friendsProfilePicture = friendList[indexPath.row] // taking from DB (example)
            return cell
        
        
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
