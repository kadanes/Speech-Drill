//
//  ImageColorChangeExtension.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 18/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func changeColorTo(color: UIColor){
    guard let image =  self.image else {return}
    self.image = image.withRenderingMode(.alwaysTemplate)
    self.tintColor = color
    }
}
