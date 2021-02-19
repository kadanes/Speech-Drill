//
//  DateToISOFormatHelperExtensions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 19/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

extension Formatter {
    static let iso8601withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601withFractionalSeconds.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container,
                  debugDescription: "Invalid date: " + string)
        }
        return date
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let iso8601withFractionalSeconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
    }
}


// Encoder Decoder Usage:
//
// let dates = [Date()]   // ["Feb 8, 2019 at 9:48 PM"]
// let encoder = JSONEncoder()
// encoder.dateEncodingStrategy = .iso8601withFractionalSeconds
// let data = try! encoder.encode(dates)
//
// print(String(data: data, encoding: .utf8)!)
// let decoder = JSONDecoder()
// decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
// let decodedDates = try! decoder.decode([Date].self, from: data)  // ["Feb 8, 2019 at 9:48 PM"]
