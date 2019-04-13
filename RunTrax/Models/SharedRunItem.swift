//
//  SharedRunItem.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/13/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation

public class SharedRunItem
{
    
    var distance : String?
    var id : String?
    var imageUrl : String?
    var username : String?

    
    init(distance : String, id: String, imageUrl: String, username: String?)
    {
        self.distance = distance
        self.id = id
        self.imageUrl = imageUrl
        self.username = username
    }
    
    
}
