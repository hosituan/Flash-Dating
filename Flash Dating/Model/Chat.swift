//
//  Chat.swift
//  Flash Dating
//
//  Created by Hồ Sĩ Tuấn on 7/16/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import Foundation
import UIKit

struct Chat {
    
    var users: [String]
    
    var dictionary: [String: Any] {
        return [
            "users": users
        ]
    }
}

extension Chat {
    
    init?(dictionary: [String:Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else {return nil}
        self.init(users: chatUsers)
    }
    
}
