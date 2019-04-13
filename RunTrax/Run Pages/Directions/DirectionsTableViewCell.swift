//
//  DirectionsTableViewCell.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/6/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var directionsLabel: UILabel!
    
    var directionsItem : DirectionsItem!
    {
        didSet
        {
            directionsLabel.text = "\(directionsItem.direction)"
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    
    
    
    
    
}