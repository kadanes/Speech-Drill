//
//  DiscussionMessage.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 13/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

struct DiscussionMessage: Codable {
    let message, userCountryCode, userCountryEmoji, userName, userEmailAddress: String
    let messageTimestamp: Double
    let fcmToken, question, recordingURL, profilePictureURL, messageID, providerID: String?
    
    enum CodingKeys: CodingKey {
        case message, userCountryCode, userCountryEmoji, userName, userEmailAddress
        case messageTimestamp
        case fcmToken, question, recordingURL, profilePictureURL, messageID, providerID
    }
}

//let disucssionMessageTimestampKey = "messageTimestamp"
