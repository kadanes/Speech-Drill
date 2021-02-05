//
//  SafeArrayExtension.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 04/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
