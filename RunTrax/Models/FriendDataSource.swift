//
//  FriendDataSource.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/14/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit

class FriendDataSource: NSObject, UITableViewDataSource
{
    var friends : [FriendsItem]
    var found : Bool
    
    init(friends: [FriendsItem], found: Bool)
    {
        self.friends = friends
        self.found = found
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        cell.friendItem = friends[indexPath.row]
        
        if found
        {
            cell.addButtonOn = true
            return cell
        }
        cell.addButtonOn = false
        return cell
        
    }
    
    
}
