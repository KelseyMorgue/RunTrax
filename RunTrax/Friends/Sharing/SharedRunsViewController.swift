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
//import FirebaseStorage
import FirebaseUI

class SharedRunsViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    var handle: AuthStateDidChangeListenerHandle!
    var userID : User!
    var run : SharedRunItem?
    var sharedRunsList = [SharedRunItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                //TODO: force relogin
            }
            // ...
        }
        self.userID = Auth.auth().currentUser
    }
    
    func getRuns()    {
        
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        
        //
        ref.child("users").child(userID?.uid ?? "no users here").child("runs").observeSingleEvent(of: .value){(snapshot) in
            
            //            for _ in snapshot.children
            //            {
            let value = snapshot.value as? NSDictionary
            let runKeys = value?.allKeys as! [String]
            /*
             let userKeys = value?.allKeys as? [String]
             
             //make guard statement about checking users exist
             for currentKey in userKeys!
             {
             let userValues = value?[currentKey] as? NSDictionary
             
             */
            
            
            
            for current in runKeys{
                
                let userValues = value?[current] as? NSDictionary
               let distance = userValues?["mileage"] as? String ?? "yeeet"
                let imageUrl = userValues?["time"] as? String ?? "yeet"
                let id = userValues?["id"] as? String ?? "yeet"
                let username = userValues?["username"] as? String ?? "yeet"
                
                self.sharedRunsList.append(SharedRunItem(distance: distance, id: id, imageUrl: imageUrl, username: username))
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            //            }
            
            
        }
        
        self.tableView.endUpdates()
        
    }
    
}

extension SharedRunsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sharedRunsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharedRun", for: indexPath) as! SharedRunsTableViewCell
        let run = sharedRunsList[indexPath.row]
        cell.runDistance?.text = run.distance
        cell.friendUsername?.text = run.username
        
        return cell
        
        /*
         let user = users[indexPath.row]
         cell.textLabel?.text = user.name
         cell.detailTextLabel?.text = user.email
         */
        
        
    }
}
