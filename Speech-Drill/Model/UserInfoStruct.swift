//
//  UserInfoStruct.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 30/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

struct UserInfo {
    let userName, userEmail, profilePictureUrl, appVersion, fcmToken: String
    let numberOfRecordings: Int
    let lastSeenTimestamp: Double
}
