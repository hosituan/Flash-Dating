//
//  ShowingUser.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/8/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import Foundation

struct User: Codable {
    var email: String
    var name: String
    var photoURL: String
    var uid: String
    var location: String
    var distance: Double = 0.0
}

struct UserMatchDetail: Codable {
    var uid: String
    var totalMatched: Int
    var totalLiked: Int
    var likedID: String
    var dislikedID: String
    var matchedID: String
}

