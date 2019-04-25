//
//  PastRunsTableViewCell.swift
//  RunTrax
//
//  Code for the cell of the tableview
//
//  Created by Kelsey Henrichsen on 3/25/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseUI
class PastRunsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //from item
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
        loadRuns()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func loadRuns()
    {
        //pulls data from the database
        if let run = pastRunItem
        {
            distanceLabel.text = "\(run.distance)"
            timeLabel.text = "\(run.time)"
            dateLabel.text = "\(run.date)"
        }
    }
    
}
