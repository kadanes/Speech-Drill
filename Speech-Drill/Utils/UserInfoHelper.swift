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


/// Saves value at passed reference else loggs errors
/// - Parameters:
///   - ref: Reference to store value at
///   - value: Value to be stored at reference
fileprivate func setUserInfoValueWithErrorLogging(ref: DatabaseReference, value: Any?) {
    ref.setValue(value) { (error, ref) in
        if let error = error {
            print("Error storing user info  '\(value)' for key '\(ref)' to firebase.\n\(String(describing: error))")
        }
    }
}


/// Saves user info by runing a check to see if data already exists at passed reference. Won't save if once is true and data exists.
/// - Parameters:
///   - ref: Reference to store value at
///   - value: The value to be stored at reference
///   - once: Should the value be set only once
fileprivate func saveUserInfo(at ref: DatabaseReference, with value: Any?, once: Bool) {
    //Authenticated
    if once {
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                setUserInfoValueWithErrorLogging(ref: ref, value: value)
            }
        }
    } else {
        setUserInfoValueWithErrorLogging(ref: ref, value: value)
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

fileprivate func getUnauthenticatedUserInfoReference() -> DatabaseReference {
    return unauthenticatedUsersReferences.child(getUUID())
}


fileprivate func saveUserInfo(at childKey: String, for key: String, as value: Any?, once: Bool, deleteUnauth: Bool = false) {
    let userInfoReference = getUserInfoReference().child(childKey).child(key)
    saveUserInfo(at: userInfoReference, with: value, once: once)
    if deleteUnauth {
        getUnauthenticatedUserInfoReference().child(childKey).child(key).setValue(nil) { (error, ref) in
            if let error = error {
                NSLog("Error deleteing unauthenticated user data at \(userInfoReference) \n\(error)")
            }
        }
    }
}

fileprivate func saveUserProfileInfo(for key: ProfileInfo.CodingKeys, as value: Any?, once: Bool, deleteUnauth: Bool = false) {
    let profileKey = UserInfo.CodingKeys.profile.stringValue
    saveUserInfo(at: profileKey, for: key.stringValue, as: value, once: once, deleteUnauth: deleteUnauth)
}

fileprivate func saveUserActivityInfo(for key: ActivityInfo.CodingKeys, as value: Any?, once: Bool, deleteUnauth: Bool = false) {
    let activityKey = UserInfo.CodingKeys.activity.stringValue
    saveUserInfo(at: activityKey, for: key.stringValue, as: value, once: once, deleteUnauth: deleteUnauth)
}

fileprivate func saveUserStatsInfo(for key: StatsInfo.CodingKeys, as value: Any?, once: Bool, deleteUnauth: Bool = false) {
    let statsKey = UserInfo.CodingKeys.stats.stringValue
    saveUserInfo(at: statsKey, for: key.stringValue, as: value, once: once, deleteUnauth: deleteUnauth)
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

func saveUserEmail(deleteUnauth: Bool = false) {
//    let userEmail: String = unwrapUserInfo(from: Auth.auth().currentUser?.email ?? nil)
    let userEmail: String? = Auth.auth().currentUser?.email ?? nil
    saveUserProfileInfo(for: .userEmailID, as: userEmail, once: true, deleteUnauth: deleteUnauth)
}

func saveUserDisplayName(deleteUnauth: Bool = false) {
//    let userDisplayName: String = unwrapUserInfo(from: Auth.auth().currentUser?.displayName ?? nil)
    let userDisplayName: String? = Auth.auth().currentUser?.displayName ?? nil
    saveUserProfileInfo(for: .userDisplayName, as: userDisplayName, once: false, deleteUnauth: deleteUnauth)
}

func saveUserProfilePictureURL(deleteUnauth: Bool = false) {
//    let userProfilePictureURL: String = unwrapUserInfo(from: Auth.auth().currentUser?.photoURL ?? nil)
    let userProfilePictureURL: String? = Auth.auth().currentUser?.photoURL?.absoluteString ?? nil
    saveUserProfileInfo(for: .userProfilePictureURL, as: userProfilePictureURL, once: false, deleteUnauth: deleteUnauth)
}

func saveDeviceUUID(deleteUnauth: Bool = false) {
    let deviceUUID = getUUID()
    saveUserStatsInfo(for: .deviceUUID, as: deviceUUID, once: false, deleteUnauth: deleteUnauth)
//    let uuidKey = StatsInfo.CodingKeys.deviceUUID.stringValue
//    saveLikelyUserName(using: uuidKey, with: deviceUUID)
}

func saveAuthenticationType(deleteUnauth: Bool = false) {
    let authenticationType: String = Auth.auth().currentUser?.providerData[0].providerID ?? AuthenticationType.NONE.rawValue
    saveUserStatsInfo(for: .authenticationType, as: authenticationType, once: false, deleteUnauth: deleteUnauth)
}

func saveInstalledAppVersion(deleteUnauth: Bool = false) {
//    let installedAppVersion: String = unwrapUserInfo(from: getFullInstalledAppVersion())
    let installedAppVersion: String? = getFullInstalledAppVersion()
    saveUserStatsInfo(for: .currentInstalledAppVersion, as: installedAppVersion, once: false, deleteUnauth: deleteUnauth)
    saveUserStatsInfo(for: .firstInstalledAppVersion, as: installedAppVersion, once: true, deleteUnauth: deleteUnauth)
}

func saveSeenTimestamp(deleteUnauth: Bool = false) {
    let seenTimestamp = Double(Date().timeIntervalSince1970)
    saveUserActivityInfo(for: .lastSeenTimestamp, as: nil, once: false, deleteUnauth: deleteUnauth)
    saveUserActivityInfo(for: .firstSeenTimestamp, as: seenTimestamp, once: true, deleteUnauth: deleteUnauth)
}

func saveLastSeenTimestamp(once: Bool = false, deleteUnauth: Bool = false) {
    let seenTimestamp = Double(Date().timeIntervalSince1970)
    saveUserActivityInfo(for: .lastSeenTimestamp, as: seenTimestamp, once: once, deleteUnauth: deleteUnauth)
}

func saveUserLocationInfo(deleteUnauth: Bool = false) {
    let currentUserLocation: String = UserDefaults.standard.string(forKey: userLocationCodeKey) ?? "UNK"
    saveUserProfileInfo(for: .currentUserLocation, as: currentUserLocation, once: false, deleteUnauth: deleteUnauth)
    
    let allUserLocationsInfoReference = getUserInfoReference().child(UserInfo.CodingKeys.profile.stringValue) .child(ProfileInfo.CodingKeys.allUserLocations.stringValue)
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

func saveFCMToken(deleteUnauth: Bool = false) {
    let fcmToken = Messaging.messaging().fcmToken
        
    saveUserStatsInfo(for: .fcmToken, as: fcmToken, once: false, deleteUnauth: deleteUnauth)
    if let userName = getAuthenticatedUsername() {
        let userGroupsInfoRef = getUserInfoReference().child("stats").child("groups")
            userGroupsInfoRef.observeSingleEvent(of: .value) { (snapshot) in
                if let groups = snapshot.value as? [String] {
                    for group in groups {
                        let currentGroupsReference = groupsReference.child(group).child(userName)
                        saveUserInfo(at: currentGroupsReference, with: fcmToken, once: false)
                    }
                }
            }
    } else if let fcmToken = fcmToken {
        
        let fcmTokenKey = StatsInfo.CodingKeys.fcmToken.stringValue
        saveLikelyUserName(using: fcmTokenKey, with: fcmToken)
    }
}


/// Saves likely usernames accociated with an unauthenticated user
/// - Parameters:
///   - property: Key of the property whoes value to match with in other authenticated user's stats. For example: "fcmToken"
///   - value: Value of the property to look for in other authenticated user's stats. For example: "abc...45fgg3"
func saveLikelyUserName(using property: String, with value: String) {
    //Function only to be run if the user is unauthenticated
    if let _ = getAuthenticatedUsername() { return }
    
    let statsKey = UserInfo.CodingKeys.stats.stringValue
    let likelyUserNamesKey = StatsInfo.CodingKeys.likelyUserNames.stringValue
            
    authenticatedUsersReference.queryOrdered(byChild: "\(statsKey)/\(property)").queryEqual(toValue: value).observeSingleEvent(of: .value) { (snapshot) in
        if snapshot.exists() {
            
            guard let semiParsedSnapshot = snapshot.value as? [String: Any] else { return }
            let newLikelyUserNames = Array(semiParsedSnapshot.keys)
            print("New Likely Usernames: ", newLikelyUserNames)

            let ref = getUnauthenticatedUserInfoReference().child(statsKey).child(likelyUserNamesKey)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if var likelyUsernames = snapshot.value as? [String] {
                    let setLikelyUserNames = Set(likelyUsernames)
                    likelyUsernames = setLikelyUserNames + newLikelyUserNames.filter { !setLikelyUserNames.contains($0) }
                    
                    saveUserInfo(at: ref, with: likelyUsernames, once: false)
                } else {
                    saveUserInfo(at: ref, with: newLikelyUserNames, once: false)
                }
            })
        }
    }
}


func saveCurrentNumberOfSavedRecordings(deleteUnauth: Bool = false) {
    let currentNumberOfSavedRecordings = UserDefaults.standard.integer(forKey: recordingsCountKey)
    saveUserActivityInfo(for: .currentNumberOfSavedRecordings, as: currentNumberOfSavedRecordings, once: false, deleteUnauth: deleteUnauth)
}

func saveLastReadMessageTimestamp(deleteUnauth: Bool = false) {
    let defaults = UserDefaults.standard
    let lastReadMessageTimestamp = defaults.double(forKey: lastReadMessageTimestampKey)
    let lastReadMessageID = defaults.string(forKey: lastReadMessageIDKey)
    saveUserActivityInfo(for: .lastReadMesssageTimestamp, as: lastReadMessageTimestamp, once: false, deleteUnauth: deleteUnauth)
    saveUserActivityInfo(for: .lastReadMesssageID, as: lastReadMessageID, once: false, deleteUnauth: deleteUnauth)
}

func addInFirebaseArray(ref: DatabaseReference, value entry: String) {
    ref.observeSingleEvent(of: .value) { (snapshot) in
        if var value = snapshot.value as? [String] {
            if value.contains(entry) {
                return
            } else {
                value.append(entry)
                saveUserInfo(at: ref, with: value, once: false)
            }
        } else {
            saveUserInfo(at: ref, with: [entry], once: false)
        }
    }
}

func removeFromFirebaseArray(ref: DatabaseReference, value entry: String) {
    ref.observeSingleEvent(of: .value) { (snapshot) in
        if var value = snapshot.value as? [String] {
            if value.contains(entry) {
                value = value.filter({$0 != entry})
                saveUserInfo(at: ref, with: value, once: false)
            }
        }
    }
}

func addOrRemoveUser(from group: UserGroup, userName: String, fcmToken: String?) {
    var filteredRef = groupsReference.child(group.rawValue).child(userName)
    let statsKey = UserInfo.CodingKeys.stats.stringValue
    let groupsKey = StatsInfo.CodingKeys.groups.stringValue
    let childGroupStatsReference = authenticatedUsersReference.child(userName).child(statsKey).child(groupsKey)

//    print("Filtering user \(userName)")
    
    filteredRef.observeSingleEvent(of: .value) { (snapshot) in
//        print("Value: \(snapshot.value)")
        if snapshot.exists() {
        //User belongs to filtered group
        NSLog("Removing user \(userName) at \(filteredRef)")
        saveUserInfo(at: filteredRef, with: nil, once: false)
        removeFromFirebaseArray(ref: childGroupStatsReference, value: group.rawValue)
        
        } else {
            NSLog("Adding user \(userName) at \(filteredRef)")
            saveUserInfo(at: filteredRef, with: fcmToken, once: false)
            addInFirebaseArray(ref: childGroupStatsReference, value: group.rawValue)
        }
    }
}


func saveBasicUserInfo(deleteUnauth: Bool = false) {
    saveUserDisplayName(deleteUnauth: deleteUnauth)
    saveUserEmail(deleteUnauth: deleteUnauth)
    saveUserProfilePictureURL(deleteUnauth: deleteUnauth)
    saveSeenTimestamp(deleteUnauth: deleteUnauth)
    saveInstalledAppVersion(deleteUnauth: deleteUnauth)
    saveAuthenticationType(deleteUnauth: deleteUnauth)
//    saveFCMToken(deleteUnauth: deleteUnauth)
    saveUserLocationInfo(deleteUnauth: deleteUnauth)
    saveDeviceUUID(deleteUnauth: deleteUnauth)
}
