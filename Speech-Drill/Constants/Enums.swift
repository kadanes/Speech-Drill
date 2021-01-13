//
//  Constants.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 11/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

enum NotificationType {
case Success
case Failure
case Info
}

enum DeleteResult {
case Success
case FileNotFound
case Failed
}

enum ScreenType: String {
    case iPhone4_4S = "iPhone 4 or iPhone 4S"
    case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
    case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
    case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
    case iPhoneXR = "iPhone XR"
    case iPhoneX_iPhoneXS = "iPhone X,iPhoneXS"
    case iPhoneXSMax = "iPhoneXS Max"
    case unknown
}
