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
    let lastSeenTimestamp, firstSeenTimestamp: Double
    let lastReadMesssageTimestamp: Double?
    let lastReadMesssageID: String?
    
    enum CodingKeys: CodingKey {
        case currentNumberOfSavedRecordings
        case lastSeenTimestamp, firstSeenTimestamp
        case lastReadMesssageTimestamp
        case lastReadMesssageID
    }
}

struct StatsInfo: Codable {
    let fcmToken: String?
    let firstInstalledAppVersion, currentInstalledAppVersion: String
    let deviceUUID: String
    let authenticationType: AuthenticationType
    let groups: [String]?
    let likelyUserNames: [String]?
    
    enum CodingKeys: CodingKey {
        case deviceUUID, firstInstalledAppVersion, currentInstalledAppVersion, fcmToken
        case authenticationType
        case groups
        case likelyUserNames
    }
}

//extension UserInfo {
//    init(userName: String, userEmailID: String, userProfilePictureURL: String, deviceUUID: String, authenticationType: AuthenticationType, appVersion: String, lastSeenTimestamp: Double) {
//        self.userDisplayName = userName
//        self.userEmailID = userEmailID
//        self.userProfilePictureURL = userProfilePictureURL
//        self.deviceUUID = deviceUUID
//        self.authenticationType = authenticationType
//        self.installedAppVersion = appVersion
//        self.lastSeenTimestamp = lastSeenTimestamp
//
//        fcmToken = valueNotAvailableIndicatorString
//        currentUserLocation = valueNotAvailableIndicatorString
//        lastReadMesssageID = valueNotAvailableIndicatorString
//        allUserLocations = [valueNotAvailableIndicatorString]
//        currentNumberOfSavedRecordings = valueNotAvailableIndicatorInt
//        firstSeenTimestamp = valueNotAvailableIndicatorDouble
//    }
//
//    init(deviceUUID: String, authenticationType: AuthenticationType, appVersion: String, lastSeenTimestamp: Double) {
//        self.deviceUUID = deviceUUID
//        self.authenticationType = authenticationType
//        self.installedAppVersion = appVersion
//        self.lastSeenTimestamp = lastSeenTimestamp
//
//        userDisplayName = valueNotAvailableIndicatorString
//        userEmailID = valueNotAvailableIndicatorString
//        userProfilePictureURL = valueNotAvailableIndicatorString
//        fcmToken = valueNotAvailableIndicatorString
//        currentUserLocation = valueNotAvailableIndicatorString
//        lastReadMesssageID = valueNotAvailableIndicatorString
//        allUserLocations = [valueNotAvailableIndicatorString]
//        currentNumberOfSavedRecordings = valueNotAvailableIndicatorInt
//        firstSeenTimestamp = valueNotAvailableIndicatorDouble
//    }
//}

enum AuthenticationType: String, Codable {
    case none, gmail
}
