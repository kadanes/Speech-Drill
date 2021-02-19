//
//  UserInfoStruct.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 30/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

let valueNotAvailableIndicatorString = "UNKNOWN_USER_INFO"
let valueNotAvailableIndicatorDouble: Double = 0
let valueNotAvailableIndicatorInt: Int = 0

struct UserInfo: Codable {
    let profile: ProfileInfo
    let activity: ActivityInfo
    let stats: StatsInfo
    
    enum CodingKeys: CodingKey {
        case profile
        case activity
        case stats
        
    }
}


struct ProfileInfo: Codable {
    let allUserLocations: [String]
    let userDisplayName, userEmailID, userProfilePictureURL, currentUserLocation: String?
    
    enum CodingKeys: CodingKey {
        case allUserLocations
        case userDisplayName, userEmailID, userProfilePictureURL, currentUserLocation
    }
}

struct ActivityInfo: Codable {
    let currentNumberOfSavedRecordings: Int
    let lastSeenTimestamp: Double?
    let firstSeenTimestamp: Double
    let lastSeenDate: Date?
    let firstSeenDate: Date
    let lastReadMesssageTimestamp: Double?
    let lastReadMesssageID: String?
    
    enum CodingKeys: CodingKey {
        case currentNumberOfSavedRecordings
        case lastSeenTimestamp, firstSeenTimestamp
        case lastSeenDate, firstSeenDate
        case lastReadMesssageTimestamp
        case lastReadMesssageID
    }
}

struct StatsInfo: Codable {
    let fcmToken: String?
    let firstInstalledAppVersion, currentInstalledAppVersion: String
    let deviceUUID: String
    let authenticationType: AuthenticationType
    let groups: [UserGroup]?
    let likelyUserNames: [String]?
    
    enum CodingKeys: CodingKey {
        case deviceUUID, firstInstalledAppVersion, currentInstalledAppVersion, fcmToken
        case authenticationType
        case groups
        case likelyUserNames
    }
}

enum UserGroup: String, Codable {
    case ADMIN = "admin"
    case FILTERED = "filtered"
    case BLOCKED = "blocked"
}

enum AuthenticationType: String, Codable {
    case NONE = "none"
    case GOOGLE = "google.com"
}
