//
//  SideNavMenuItemStruct.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 17/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

struct SideNavMenuItemStruct {
    let itemName: SideNavItemName
    var itemTag: String?
    let itemImg: UIImage
    let itemImgClr: UIColor
    let presentedVC: UIViewController
}

enum SideNavItemName: String {
    case RECORDINGS = "Recordings"
    case DISCUSSIONS = "Discussions"
    case ABOUT = "About"
}
