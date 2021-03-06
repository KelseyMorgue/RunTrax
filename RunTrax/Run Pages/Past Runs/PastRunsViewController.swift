//
//  PastRunsViewController.swift
//  RunTrax
//
//  Shows the user all of their past runs
//
//  Created by Kelsey Henrichsen on 1/29/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
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
    
    //from item
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let directionsScreen = self.storyboard?.instantiateViewController(withIdentifier: "directionsViewController") as! DirectionsViewController
        
        directionsScreen.runKey = pastRunsList[indexPath.row].id
        let nav = self.navigationController
        nav?.pushViewController(directionsScreen, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if Auth.auth().currentUser == nil
            {
            }
        }
        self.userID = Auth.auth().currentUser
    }
    
    //gets the run information for the signed in user -- completion handler
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
                            //populates tableview variables
                            
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

