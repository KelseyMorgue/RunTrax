//
//  FriendsItem.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 3/10/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//
// Database stuff here

import Foundation

public class FriendsItem
{
    
    var name : String
    var imageUrl : String
    var id : String
    var runCount : Int
    
    init(name : String, imageUrl : String, id: String, runCount: Int)
    {
        self.name = name
        self.imageUrl = imageUrl
        self.id = id
        self.runCount = runCount
    }
    
}
