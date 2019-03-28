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

class PastRunsViewController: UIViewController{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    var handle: AuthStateDidChangeListenerHandle!
    var userID : User!
    var run : PastRunItem?
    var pastRunsList = [PastRunItem]()
    //var runs = PastRunsTableViewCell.loadRuns()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         getRuns()
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
    
    func getRuns()    {
        
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()
        
        //
        ref.child("users").child(userID?.uid ?? "no users here").child("runs").child("-Lah4ZyRrtpR_Bpe0g7X").observeSingleEvent(of: .value){(snapshot) in
            
//            for _ in snapshot.children
//            {
                print("in the for loop")
                let value = snapshot.value as? NSDictionary
                let date = value?["date"] as? String ?? "yeet"
                let distance = value?["mileage"] as? String ?? "yeet"
                let time = value?["time"] as? String ?? "yeet"
                let id = value?["id"] as? String ?? "yeet"
                self.pastRunsList.append(PastRunItem(date: date, distance: distance, time: time, id: id))
                
                print(self.pastRunsList, "hello here")
            print(date, distance, time, id, "all the things")
//            }
            
            self.tableView.reloadData()
            
        }
        
      //  self.tableView.endUpdates()
    }
    
}

extension PastRunsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("made it here")

        return pastRunsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastRun", for: indexPath) as! PastRunsTableViewCell
        let run = pastRunsList[indexPath.row]
        cell.distanceLabel?.text = run.distance
        cell.dateLabel?.text = run.date
        cell.timeLabel?.text = run.time
        print("made it here too")

        return cell
        
        /*
         let user = users[indexPath.row]
         cell.textLabel?.text = user.name
         cell.detailTextLabel?.text = user.email
         */
        
        
    }
}
