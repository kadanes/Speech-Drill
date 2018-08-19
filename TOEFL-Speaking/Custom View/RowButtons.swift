//
//  RowButtons.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 18/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class RowButtons: UIButton {

    override func awakeFromNib() {
        self.imageView?.contentMode = .scaleAspectFit
        self.imageEdgeInsets = UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0)
    }

}
