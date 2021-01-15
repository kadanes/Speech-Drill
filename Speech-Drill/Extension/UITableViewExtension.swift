//
//  UITableViewExtension.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 15/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func isValid(indexPath: IndexPath) -> Bool {
        return indexPath.section >= 0 && indexPath.section < self.numberOfSections && indexPath.row >= 0 && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
