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

func saveBasicUserInfo(deleteUUIDInfo: Bool = false) {
        
    let uuid = UIDevice.current.identifierForVendor?.uuidString ?? valueNotAvailableIndicatorString
    let appVersion = getFullInstalledAppVersion() ?? valueNotAvailableIndicatorString
    let lastSeenTimestamp = Double(Date().timeIntervalSince1970)
    
    //Gmail Login
    if let GIDSignInInstance = GIDSignIn.sharedInstance(), let currentUser = GIDSignInInstance.currentUser, let profile = currentUser.profile, let userEmail = profile.email {
        
        let userEmailComponents = userEmail.components(separatedBy: "@")
        
        if userEmailComponents.count == 0  { return }
        
        let username = userEmailComponents[0].replacingOccurrences(of: ".", with: "")
        
        var userName: String = valueNotAvailableIndicatorString
        if let firstName = profile.givenName {
            userName = firstName
        }
        if let familyName = profile.familyName {
            userName += " \(familyName)"
        }
        var userProfilePictureURL = valueNotAvailableIndicatorString
        if let unwrappedUserProfilePictureURL = profile.imageURL(withDimension: 100) {
            userProfilePictureURL = String(describing: unwrappedUserProfilePictureURL)
        }
        
        let userInfo = UserInfo(userName: userName, userEmailID: userEmail, userProfilePictureURL: userProfilePictureURL, deviceUUID: uuid, authenticationType: .gmail, appVersion: appVersion, lastSeenTimestamp: lastSeenTimestamp)
        
        do {
            let userInfoDict = try userInfo.dictionary()
            authenticatedUsersReference.child(username).setValue(userInfoDict) { (error, ref) in
                if let error = error {
                    print("Error storing authenticated user info in firebase: \(error)")
                } else {
                    print("Deleting UUID Info")
                    unauthenticatedUsersReferences.child(uuid).setValue(nil) { (error, reference) in
                        if let error = error {
                            print("Error deleting unauthenticated user info from firebase: \(error)")
                        }
                    }
                }
            }
        } catch {
            print("Error saving authenticated user info ", error)
        }
        
    } else {
        
        let userInfo = UserInfo(deviceUUID: uuid, authenticationType: .none, appVersion: appVersion, lastSeenTimestamp: lastSeenTimestamp)
                
        do {
            let userInfoDict = try userInfo.dictionary()
            unauthenticatedUsersReferences.child(uuid).setValue(userInfoDict) { (error, ref) in
                if let error = error {
                    print("Error storing unauthenticated user info in firebase: \(error)")
                }
            }
        } catch {
            print("Error saving unauthenticated user info ", error)
        }
    }
}

func saveUserLocationInfo(isoCode: String, countryEmoji: String) {
    
}
