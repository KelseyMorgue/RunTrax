//
//  PastRunsViewController.swift
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

class PastRunsViewController: UIViewController, UITableViewDataSource {
  

    @IBOutlet weak var tableView: UITableView!
    
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    var handle: AuthStateDidChangeListenerHandle!
    var userID : User!
    var run : PastRunItem?
    lazy var pastRunsList: [PastRunItem] = [PastRunItem]()
    //var runs = PastRunsTableViewCell.loadRuns()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        getRuns()
        // Do any additional setup after loading the view.
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if pastRunsList.count > 0
//        {
//            return pastRunsList.count
//        }
//        else
//        {
//            print("returned one")
//            return 1
//        }
        return pastRunsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "pastRun", for: indexPath) as! PastRunsTableViewCell
        //let run = PastRunsTableViewCell.loadRuns(PastRunsTableViewCell)
        return cell
        
        /*
         let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
         
         let player = players[indexPath.row]
         cell.textLabel?.text = player.name
         cell.detailTextLabel?.text = player.game
         return cell
 */
        
        
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
    
    func getRuns()
    {
        
self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()

        
        ref.child("users").child(userID?.uid ?? "no users here").child("runs").child("-Lah4ZyRrtpR_Bpe0g7X").observeSingleEvent(of: .value){(snapshot) in
            
            
            let value = snapshot.value as? NSDictionary
            let date = value?["date"] as? String ?? "yeet"
            let distance = value?["mileage"] as? String ?? "yeet"
            let time = value?["time"] as? String ?? "yeet"
            let id = value?["id"] as? String ?? "yeet"
            

            
            self.pastRunsList.append(PastRunItem(date: date, distance: distance, time: time, id: id))
          
        }
            
        //self.tableView.reloadData()
        self.tableView.endUpdates()
    
    }

}
