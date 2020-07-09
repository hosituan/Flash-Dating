//
//  ShowingUser.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import Foundation

struct User {
    var username: String
    var password: String
    var name: String
    var age: Int
    var location: String
    
    init(username: String, password: String, name: String, age: Int, location: String)
    {
        self.username = username
        self.password = password
        self.name = name
        self.age = age
        self.location = location
    }
}
