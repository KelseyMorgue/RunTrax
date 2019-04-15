//
//  SharedRunDataSource.swift
//  RunTrax
//
//  Created by Cody Henrichsen on 4/14/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit

class SharedRunDataSource: NSObject, UITableViewDataSource
{
    var shared : [SharedRunItem]
    
    init(shared: [SharedRunItem])
    {
        self.shared = shared
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shared.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharedRun", for: indexPath) as! SharedRunsTableViewCell
        
        cell.sharedRunItem = shared[indexPath.row]
        return cell
    }
    

}
