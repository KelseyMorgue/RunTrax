//  DirectionsTableViewCell.swift
//  RunTrax
//
//  Code for the cell in the direction page
//
//  Created by Kelsey Henrichsen on 4/6/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import UIKit

class DirectionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var directionsLabel: UILabel!
    
    var directionsItem : String!
    {
        didSet
        {
            updateText()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func updateText()
    {
        if let directions = directionsItem
        {
            directionsLabel.text = directions
        }
    }
    
    
    
    
    
}
