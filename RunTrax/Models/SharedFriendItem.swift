//
//  SharedFriendItem.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 4/7/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
public class SharedFriendItem
{
    
    var name : String
    var imageUrl : String
    var id : String
    
    init(name : String, imageUrl : String, id: String)
    {
        self.name = name
        self.imageUrl = imageUrl
        self.id = id
    }
    
}
