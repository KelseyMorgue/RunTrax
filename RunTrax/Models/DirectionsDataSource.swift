//
//  DirectionsDataSource.swift
//  RunTrax
//
//  Created by Cody Henrichsen on 4/14/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit

class DirectionsDataSource: NSObject, UITableViewDataSource
{
    var directions : [String]
    
    init(directions : [String])
    {
        self.directions = directions
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as! DirectionsTableViewCell
        
        cell.directionsItem = directions [indexPath.row]
        return cell
    }
    

}
