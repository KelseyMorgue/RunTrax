//
//  PastRunsTableViewCell.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/25/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
//import FirebaseStorage
import FirebaseUI
class PastRunsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var pastRunItem : PastRunItem!
    {
        didSet
        {
            loadRuns()
        }
    }
    
    var ref = Database.database().reference()
    let storage = Storage.storage()
    var handle : AuthStateDidChangeListenerHandle!
    var userID : User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        loadRuns()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        
        // Configure the view for the selected state
    }

    
    func loadRuns()
    {
        if pastRunItem != nil
        {
            distanceLabel.text = "Distance: \(pastRunItem.distance)"
            timeLabel.text = "Time: \(pastRunItem.time)"
            dateLabel.text = "Date: \(pastRunItem.date)"
            
        }
        
        
        
    }
    
}
