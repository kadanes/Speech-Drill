//
//  IconCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class IconCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    
    func configureCell(icon: UIImage, tintColor : UIColor? ) {
        if let tintColor = tintColor {
            let templateImg = icon.withRenderingMode(.alwaysTemplate)
            iconImage.image = templateImg
            iconImage.tintColor = tintColor
            
        } else {
            iconImage.image = icon
        }
    }
    
}
