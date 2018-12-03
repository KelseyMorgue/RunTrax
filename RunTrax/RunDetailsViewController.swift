//
//  RunDetailsViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 11/21/18.
//  Copyright © 2018 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class RunDetailsViewController: UIViewController {
    //Properties
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //What to do in this view controller:
    //  -Have distance, time, and pace totals displayed
    //  -Show map with finished run (maybe with colors for speeds?)
    //  -When share button is clicked bring up display of sharing options
    
    
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
