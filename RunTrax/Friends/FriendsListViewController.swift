//
//  FriendsListViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 1/29/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FriendsListViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate
{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var ref = Database.database().reference()
    
    lazy var friendList: [String] = [String]()
    var userInput = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  self.tableView.register(UITableViewCell.self, forCellWithReuseIdentifier: "friendCell")

        searchBar.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
        
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: searchText)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
