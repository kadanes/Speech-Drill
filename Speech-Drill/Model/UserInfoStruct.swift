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
    let userDisplayName, userEmailID, userProfilePictureURL, fcmToken, currentUserLocation: String?
    let firstInstalledAppVersion, currentInstalledAppVersion, lastReadMesssageID: String?
    let deviceUUID: String
    let allUserLocations: [String]
    let currentNumberOfSavedRecordings: Int
    let lastSeenTimestamp, firstSeenTimestamp: Double
    let lastReadMesssageTimestamp: Double?
    let authenticationType: AuthenticationType
    
    enum CodingKeys: CodingKey {
        case userDisplayName, userEmailID, deviceUUID, userProfilePictureURL, firstInstalledAppVersion, currentInstalledAppVersion, fcmToken, lastReadMesssageID, currentUserLocation
        case allUserLocations
        case currentNumberOfSavedRecordings
        case lastSeenTimestamp, firstSeenTimestamp, lastReadMesssageTimestamp
        case authenticationType
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
