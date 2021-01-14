//
//  EncodableExtension.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 14/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

extension Encodable {
    func data(using encoder: JSONEncoder = .init()) throws -> Data { try encoder.encode(self) }
    func string(using encoder: JSONEncoder = .init()) throws -> String { try data(using: encoder).string! }
    func dictionary(using encoder: JSONEncoder = .init(), options: JSONSerialization.ReadingOptions = []) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: try data(using: encoder), options: options) as? [String: Any] ?? [:]
    }
}
