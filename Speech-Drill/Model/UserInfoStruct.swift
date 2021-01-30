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
    let userName, userEmailID, userProfilePictureURL: String
    let deviceUUID, fcmToken, currentUserLocation: String
    let allUserLocations: [String]
    let appVersion, lastReadMesssageID: String
    let currentNumberOfSavedRecordings: Int
    let lastSeenTimestamp: Double
    let authenticationType: AuthenticationType
    
    enum CodingKeys: CodingKey {
        case userName, userEmailID, deviceUUID, userProfilePictureURL, appVersion, fcmToken, lastReadMesssageID, currentUserLocation
        case allUserLocations
        case currentNumberOfSavedRecordings
        case lastSeenTimestamp
        case authenticationType
    }
}

extension UserInfo {
    init(userName: String, userEmailID: String, userProfilePictureURL: String, deviceUUID: String, authenticationType: AuthenticationType, appVersion: String, lastSeenTimestamp: Double) {
        self.userName = userName
        self.userEmailID = userEmailID
        self.userProfilePictureURL = userProfilePictureURL
        self.deviceUUID = deviceUUID
        self.authenticationType = authenticationType
        self.appVersion = appVersion
        self.lastSeenTimestamp = lastSeenTimestamp

        fcmToken = valueNotAvailableIndicatorString
        currentUserLocation = valueNotAvailableIndicatorString
        lastReadMesssageID = valueNotAvailableIndicatorString
        allUserLocations = [valueNotAvailableIndicatorString]
        currentNumberOfSavedRecordings = valueNotAvailableIndicatorInt
    }
    
    init(deviceUUID: String, authenticationType: AuthenticationType, appVersion: String, lastSeenTimestamp: Double) {
        self.deviceUUID = deviceUUID
        self.authenticationType = authenticationType
        self.appVersion = appVersion
        self.lastSeenTimestamp = lastSeenTimestamp

        userName = valueNotAvailableIndicatorString
        userEmailID = valueNotAvailableIndicatorString
        userProfilePictureURL = valueNotAvailableIndicatorString
        fcmToken = valueNotAvailableIndicatorString
        currentUserLocation = valueNotAvailableIndicatorString
        lastReadMesssageID = valueNotAvailableIndicatorString
        allUserLocations = [valueNotAvailableIndicatorString]
        currentNumberOfSavedRecordings = valueNotAvailableIndicatorInt
    }
}

enum AuthenticationType: String, Codable {
    case none, gmail
}
