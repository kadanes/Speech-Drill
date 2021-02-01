//
//  UserInfoHelper.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 30/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn


fileprivate func setUserInfoValueWithErrorLogging(ref: DatabaseReference, value: Any?) {
    ref.setValue(value) { (error, ref) in
        if let error = error {
            print("Error storing user info  '\(value)' for key '\(ref)' to firebase.\n\(String(describing: error))")
        }
    }
}


fileprivate func getUserInfoReference() -> DatabaseReference {
    var userInfoReference: DatabaseReference
    if let username = getAuthenticatedUsername() {
        userInfoReference = authenticatedUsersReference.child(username)
    } else {
        userInfoReference = unauthenticatedUsersReferences.child(getUUID())
    }
    return userInfoReference
}

fileprivate func saveUserInfo(for key: UserInfo.CodingKeys, as value: Any?, once: Bool, deleteUnauth: Bool = false) {
    //Authenticated
    var userInfoReference = getUserInfoReference()
    userInfoReference = userInfoReference.child(key.stringValue)
    if once {
        userInfoReference.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                setUserInfoValueWithErrorLogging(ref: userInfoReference, value: value)
            }
        }
    } else {
        setUserInfoValueWithErrorLogging(ref: userInfoReference, value: value)
    }
}

fileprivate func unwrapUserInfo(from value: String?) -> String {
    if let value = value { return value }
    return valueNotAvailableIndicatorString
}

fileprivate func unwrapUserInfo(from value: Double?) -> Double {
    if let value = value { return value }
    return valueNotAvailableIndicatorDouble
}

fileprivate func unwrapUserInfo(from value: Int?) -> Int {
    if let value = value { return value }
    return valueNotAvailableIndicatorInt
}

fileprivate func unwrapUserInfo(from value: URL?) -> String {
    if let value = value {
        return value.absoluteString
    }
    return valueNotAvailableIndicatorString
}

func saveUserEmail() {
//    let userEmail: String = unwrapUserInfo(from: Auth.auth().currentUser?.email ?? nil)
    let userEmail: String? = Auth.auth().currentUser?.email ?? nil
    saveUserInfo(for: .userEmailID, as: userEmail, once: true)
}

func saveUserDisplayName() {
//    let userDisplayName: String = unwrapUserInfo(from: Auth.auth().currentUser?.displayName ?? nil)
    let userDisplayName: String? = Auth.auth().currentUser?.displayName ?? nil
    saveUserInfo(for: .userDisplayName, as: userDisplayName, once: false)
}

func saveUserProfilePictureURL() {
//    let userProfilePictureURL: String = unwrapUserInfo(from: Auth.auth().currentUser?.photoURL ?? nil)
    let userProfilePictureURL: String? = Auth.auth().currentUser?.photoURL?.absoluteString ?? nil
    saveUserInfo(for: .userProfilePictureURL, as: userProfilePictureURL, once: false)
}

func saveDeviceUUID() {
    saveUserInfo(for: .deviceUUID, as: getuid(), once: false)
}

func saveAuthenticationType() {
    let authenticationType: String = Auth.auth().currentUser?.providerData[0].providerID ?? AuthenticationType.none.rawValue
    saveUserInfo(for: .authenticationType, as: authenticationType, once: false)
}

func saveInstalledAppVersion() {
//    let installedAppVersion: String = unwrapUserInfo(from: getFullInstalledAppVersion())
    let installedAppVersion: String? = getFullInstalledAppVersion()
    saveUserInfo(for: .currentInstalledAppVersion, as: installedAppVersion, once: false)
    saveUserInfo(for: .firstInstalledAppVersion, as: installedAppVersion, once: true)
}

func saveSeenTimestamp() {
    let seenTimestamp = Double(Date().timeIntervalSince1970)
    saveUserInfo(for: .lastSeenTimestamp, as: nil, once: false)
    saveUserInfo(for: .firstSeenTimestamp, as: seenTimestamp, once: true)
}

func saveLastSeenTimestamp(once: Bool = false) {
    let seenTimestamp = Double(Date().timeIntervalSince1970)
    saveUserInfo(for: .lastSeenTimestamp, as: seenTimestamp, once: once)
}

func saveUserLocationInfo() {
    let currentUserLocation: String = UserDefaults.standard.string(forKey: userLocationCodeKey) ?? "UNK"
    saveUserInfo(for: .currentUserLocation, as: currentUserLocation, once: false)
    
    let allUserLocationsInfoReference = getUserInfoReference().child(UserInfo.CodingKeys.allUserLocations.stringValue)
    allUserLocationsInfoReference.observeSingleEvent(of: .value) { (snapshot) in
        if snapshot.exists() {
            if var value = snapshot.value as? [String] {
                if !value.contains(currentUserLocation) {
                    value.append(currentUserLocation)
                    setUserInfoValueWithErrorLogging(ref: allUserLocationsInfoReference, value: value)
                }
            }
        } else {
            setUserInfoValueWithErrorLogging(ref: allUserLocationsInfoReference, value: [currentUserLocation])
        }
    }
}

func saveFCMToken() {    
    saveUserInfo(for: .fcmToken, as: Messaging.messaging().fcmToken, once: false)
}

func saveCurrentNumberOfSavedRecordings() {
    let currentNumberOfSavedRecordings = UserDefaults.standard.integer(forKey: recordingsCountKey)
    saveUserInfo(for: .currentNumberOfSavedRecordings, as: currentNumberOfSavedRecordings, once: false)
}

func saveLastReadMessageTimestamp() {
    let defaults = UserDefaults.standard
    let lastReadMessageTimestamp = defaults.double(forKey: lastReadMessageTimestampKey)
    let lastReadMessageID = defaults.string(forKey: lastReadMessageIDKey)
    saveUserInfo(for: .lastReadMesssageTimestamp, as: lastReadMessageTimestamp, once: false)
    saveUserInfo(for: .lastReadMesssageID, as: lastReadMessageID, once: false)

}


func saveBasicUserInfo(deleteUUIDInfo: Bool = false) {
    saveUserDisplayName()
    saveUserEmail()
    saveUserProfilePictureURL()
    saveSeenTimestamp()
    saveInstalledAppVersion()
    saveAuthenticationType()
    saveFCMToken()
    saveUserLocationInfo()
}
