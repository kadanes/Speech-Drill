//
//  SceenType.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/10/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhoneXR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX_iPhoneXS
        case 2688:
            return .iPhoneXSMax
        default:
            return .unknown
        }
    }
}
