//
//  SequenceExtension.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 14/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

extension Sequence where Element == UInt8 {
    var string: String? { String(bytes: self, encoding: .utf8) }
}
