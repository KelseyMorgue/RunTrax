//  DirectionsTableViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/6/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import MapKit

class DirectionsTableViewController: UITableViewController
{
    lazy var directionsList : [String] = [String]()
    var directionsData : DirectionsDataSource?
    {
        didSet
        {
            tableView.dataSource = directionsData
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    
    
}
