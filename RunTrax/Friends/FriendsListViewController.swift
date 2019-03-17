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
    
    
    
    var ref = Database.database().reference()
    // Get a reference to the storage service using the default Firebase App
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    lazy var friendList: [String] = [String]()
    var userInput = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

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
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //  <#code#>
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(String(describing: searchBar.text))")
    }
    
    private func setUpSearchBar()
    {
        searchBar.delegate = self
    }
    
    func searchUsers(searchText: String)
    {
        let ref = Database.database().reference()
        //let currentUser = Auth.auth().currentUser
        //let key = ref.child("friends").childByAutoId().key
        
        /*
         //Might be helpful
         
         var ref = Firebase(url: MY_FIREBASE_URL)
         ref.observeSingleEvent(of: .value) { snapshot in
         print(snapshot.childrenCount) // I got the expected number of items
         for case let rest as FIRDataSnapshot in snapshot.children {
         print(rest.value)
         }
         }
 */
        //TODO: how to go through this query for users
        ref.observeSingleEvent(of: .value)
        {
            
            (snapshot) in
            print("in the query")
            let results = ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText)
            for case let result as DataSnapshot in snapshot.children
            {
                print(result.value ?? "derpsnapshot")
                print(results)
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
