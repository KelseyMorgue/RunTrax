//
//  NewRunViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 11/21/18.
//  Copyright © 2018 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class NewRunViewController: UIViewController {
    //Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var endButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    //What to do in this view controller:
    //  -Have distance, time, and pace update and displayed
    //  -Show map with current path (?? need to look up)
    //  -When end button is clicked:
    //      *Have save/delete option pop up
    //      *If run is saved, push to next screen (sharing run options, and totals)
    //      *If run is deleted, return to home screen

    
    
}


