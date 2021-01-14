//
//  DataExtension.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 14/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

extension Data {
    func decodedObject<D: Decodable>(using decoder: JSONDecoder = .init()) throws -> D {
        try decoder.decode(D.self, from: self)
    }
}
