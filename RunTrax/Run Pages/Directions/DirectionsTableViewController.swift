//
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
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    
    
    private func loadDirections() -> Void
    {
        
    }
    
 

  

}
