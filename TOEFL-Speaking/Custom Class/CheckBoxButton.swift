//
//  CheckBoxButton.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 13/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class CheckBoxButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = 5
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3
    }
}
