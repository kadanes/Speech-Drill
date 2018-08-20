//
//  RoundImage.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class RoundImage: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = layer.bounds.size.width / 2
        layer.masksToBounds = true
        
        //layer.borderColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0).cgColor
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
    }
}
