//
//  PastRunItem.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/25/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation

public class PastRunItem
{
    var date : String
    var distance : String
    var time : String
    var id : String
    
    init(date : String, distance : String, time: String, id: String)
    {
        self.date = date
        self.distance = distance
        self.time = time
        self.id = id
    }   
}
