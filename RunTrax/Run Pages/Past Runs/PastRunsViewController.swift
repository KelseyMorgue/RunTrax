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

class PastRunsViewController: UIViewController, UITableViewDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let ref = Database.database().reference()
    let storage = Storage.storage()
    var handle: AuthStateDidChangeListenerHandle!
    var userID : User!
    var run : PastRunItem?
    var pastRunsList = [PastRunItem]()
    var sendKey : String?
    //var runs = PastRunsTableViewCell.loadRuns()
    var runData : RunsDataSource?
    {
        didSet
        {
            tableView.dataSource = runData
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRuns()
        {(runs) in
            if runs.count > 0
            {
                self.runData = RunsDataSource(runs: runs)
                self.pastRunsList = runs
                self.tableView.dataSource = self.runData
            }
                
        }
        // Do any additional setup after loading the view.
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "directionsViewController") as! DirectionsViewController
        
        nav.runKey = pastRunsList[indexPath.row].id
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
    
    func getRuns(completion: @escaping ([PastRunItem]) -> Void)
    {
        self.userID = Auth.auth().currentUser
        self.tableView.beginUpdates()

        ref.child("users").child(userID?.uid ?? "no users here").child("runs").observe( .value, with:
        {
            (snapshot) in
            var oldRuns = [PastRunItem]()
            if let value = snapshot.value as? NSDictionary
            {
               if let runKeys = value.allKeys as? [String]
               {
                
                for current in runKeys
                {
                    
                    let userValues = value[current] as? NSDictionary
                    
                    let date = userValues?["date"] as? String ?? "yeet"
                    let distance = userValues?["mileage"] as? String ?? "yeet"
                    let time = userValues?["time"] as? String ?? "yeet"
                    let id = userValues?["id"] as? String ?? "yeet"
                    oldRuns.append(PastRunItem(date: date, distance: distance, time: time, id: id))
                    DispatchQueue.main.async
                        {
                            self.runData = RunsDataSource(runs: oldRuns)
                            self.pastRunsList = oldRuns
                        self.tableView.reloadData()
                    }
                }
                self.tableView.endUpdates()
                }
                completion(oldRuns)
            }
        })
    }
}
//extension PastRunsViewController: UITableViewDataSource
//{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return pastRunsList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "pastRun", for: indexPath) as! PastRunsTableViewCell
//        let run = pastRunsList[indexPath.row]
//        cell.distanceLabel?.text = run.distance
//        cell.dateLabel?.text = run.date
//        cell.timeLabel?.text = run.time
//
//        return cell
//
//        /*
//         let user = users[indexPath.row]
//         cell.textLabel?.text = user.name
//         cell.detailTextLabel?.text = user.email
//         */
//
//
//    }
//}
