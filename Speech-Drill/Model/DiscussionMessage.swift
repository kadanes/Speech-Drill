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
    let fcmToken, question, recordingUrl, profilePictureUrl: String?
}
