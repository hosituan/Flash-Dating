//
//  MainTextField.swift
//  Flash Dating 001
//
//  Created by Hồ Sĩ Tuấn on 7/9/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit

class MainTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        let placeholderString = NSAttributedString(string: "User Name",  attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        self.attributedPlaceholder = placeholderString
        let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
        let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
        let overcastBlueColor = UIColor(red: 0, green: 187/255, blue: 204/255, alpha: 1.0)
    }

}
