//
//  UIFonts.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

enum FontName: String {
    case HelveticaNeueBold = "HelveticaNeue-Bold"
    case HelveticaNeue = "Helvetica Neue"
}

enum FontSize: CGFloat {
    case xxsmall = 8
    case xsmall = 10
    case small = 12
    case medium = 14
    case large = 16
    case xlarge = 18
    case xxlarge = 20
    case enormous = 23
    case xenormous = 26
    case xxenormous = 28
}



/// Get a UIFont easily by using the FontName and FontSize enums for a consistent look and feel
/// - Parameters:
///   - name: Name of the font to be returend
///   - size: Size of the font to be returned
/// - Returns: Returns font of specified name and size if valid name is passed else returns system font of specified size
func getFont(name: FontName, size: FontSize) -> UIFont {
    return UIFont(name: name.rawValue, size: size.rawValue) ?? UIFont.systemFont(ofSize: size.rawValue)
}
