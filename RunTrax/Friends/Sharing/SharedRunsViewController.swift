//
//  SharedRunsViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/12/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import SDWebImage
import FirebaseUI

class SharedRunsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    var handle: AuthStateDidChangeListenerHandle!
    var userID : User!
    var run : SharedRunItem?
    var sharedRunsList = [SharedRunItem]()
    var sharedData : SharedRunDataSource?
    {
        didSet
        {
            tableView.dataSource = sharedData
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRuns()
        {(shared) in
            if shared.count > 0
            {
                self.sharedData = SharedRunDataSource(shared: shared)
                self.sharedRunsList = shared
                self.tableView.dataSource = self.sharedData
            }
                
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "directionsViewController") as! DirectionsViewController
        
        nav.runKey = sharedRunsList[indexPath.row].id
        self.present(nav,animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser == nil
            {
            }
        }
        self.userID = Auth.auth().currentUser
    }
    
    func getRuns(completion: @escaping ([SharedRunItem]) -> Void)
    {
        
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        
        
        ref.child("users").child(userID?.uid ?? "no users here").child("sharedRuns").observe( .value, with: {(snapshot) in
            
            var sharedRuns = [SharedRunItem]()
            if let value = snapshot.value as? NSDictionary
            {
               if let runKeys = value.allKeys as? [String]
               {
                for current in runKeys
                {
                    if let runKey = value[current] as? String
                    {
                        self.ref.child("runs").child(runKey).observe( .value , with: {(snapshot) in
                            if let runValues = snapshot.value as? NSDictionary
                            {
                                let distance = runValues["mileage"] as? String ?? "yeeet"
                                
                                let userId = runValues["userId"] as? String ?? "spongebob"
                                self.queryForFriends(friendID: userId)
                                {
                                    (profileData) in
                                    sharedRuns.append(SharedRunItem(distance: distance, id: userId, imageUrl: profileData[1], username: profileData[0]))
                                
                                DispatchQueue.main.async
                                    {
                                        self.sharedData = SharedRunDataSource(shared: sharedRuns)
                                        self.sharedRunsList = sharedRuns
                                        self.tableView.reloadData()
                                }
                                }
                            }
                        })
                    }
                    
                }
                self.tableView.endUpdates()
            }
            completion(sharedRuns)
        }
    })
    
    }
    
    private func queryForFriends(friendID: String, completion: @escaping ([String]) -> Void) -> Void
    {
        var userData = [String]()
        
        ref.child("users").child(friendID).observeSingleEvent(of: .value) {(snapshot) in
            if let data = snapshot.value as? NSDictionary
            {
                let name = data["username"] as? String ?? "derps"
                let url = data["imageProfileUrl"] as? String ?? "www.derp.com"
                userData.append(name)
                userData.append(url)
                completion(userData)
            }
        }
    }
    
    
    
    
}
