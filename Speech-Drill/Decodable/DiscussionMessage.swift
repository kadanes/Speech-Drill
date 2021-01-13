//
//  DiscussionMessage.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 13/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

struct DiscussionMessage: Decodable {
    var message: String
    var userCountryCode: String
    var userCountryEmoji: String
    var messageTimestamp: Double
    var userName: String
    var userEmailAddress: String
    var fcmToken: String?
    var question: String?
    var recordingUrl: String?
}


//struct Request: Decodable {
//    var Address: String
//    var RequestID: String
//    var Status: String
//}
//
//self.ref.child("requests").observe(.childAdded, with: { snapshot in
//    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
//    let yourStructObject = try? JSONDecoder().decode(Request.self, from: data)
//}
