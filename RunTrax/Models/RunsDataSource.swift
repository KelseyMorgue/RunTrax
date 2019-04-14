//
//  RunsDataSource.swift
//  RunTrax
//
//  Created by Cody Henrichsen on 4/14/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit

class RunsDataSource: NSObject, UITableViewDataSource
{
    var runs : [PastRunItem]
    
    init(runs: [PastRunItem])
    {
        self.runs = runs
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastRun", for: indexPath) as! PastRunsTableViewCell
        
        let pastRun = runs[indexPath.row]
        cell.pastRunItem = pastRun
        
        return cell
    }
    

}
