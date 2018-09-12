//
//  File.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 12/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class RoundBorderedBtn: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        layer.cornerRadius = layer.bounds.width/2
        layer.borderColor = accentColor.cgColor
        layer.borderWidth = 1
    }
}
