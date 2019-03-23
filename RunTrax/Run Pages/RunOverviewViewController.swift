/*
  RunDetailsViewController.swift
  RunTrax

  Created by Kelsey Henrichsen on 11/21/18.
  Copyright © 2018 Kelsey Henrichsen. All rights reserved.

What to do in this view controller:
  -Have distance, time, and pace totals displayed
  -Show map with finished run (maybe with colors for speeds?)
  -When share button is clicked bring up display of sharing options
*/

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase

class RunOverviewViewController: UIViewController {
    //Properties
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var runKey : String?
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFields()
    }
    
    /*
     ref.child("users").child(userID?.uid ?? "derp").observeSingleEvent(of: .value, with: { (snapshot) in
     // Get user value
     let value = snapshot.value as? NSDictionary
     let username = value?["username"] as? String ?? "yeet"
     self.usernameLabel.text = "Username: \(username)"
     }) { (error) in
     print("hello error")
     print(error.localizedDescription)
     }
 */

    private func loadFields() -> Void
    {
        ref.child("runs/\(runKey!)").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let distance = value?["mileage"] as? String ?? "yeet"
            self.distanceLabel.text = "Distance: \(distance)"
        }) { (error) in
            print("hello error")
            print(error.localizedDescription)
        }
    }
    
    
    //Actions
    @IBAction func shareMenu()
    {
        let alert = UIAlertController(title: "Sharing Run",
                                      message: "How would you like to share?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Share", style: .default))
        self.present(alert, animated: true, completion: nil)
        

    }
}

