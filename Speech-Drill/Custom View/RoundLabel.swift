//
//  RoundLabel.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 12/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class RoundLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        layer.cornerRadius = 10
        layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
    }
}
