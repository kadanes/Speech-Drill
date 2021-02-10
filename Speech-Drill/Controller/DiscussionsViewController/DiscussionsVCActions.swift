//
//  DiscussionsVCActions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn

//MARK:- All Actions
extension DiscussionsViewController {
    @objc func displaySideNavTapped(_ sender: Any) {
        logger.info()
        Analytics.logEvent(AnalyticsEvent.ShowSideNav.rawValue, parameters: nil)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func displayInfoTapped(_ sender: UIButton) {
        logger.event("Display info tapped")
        //        if GIDSignIn.sharedInstance()?.currentUser == nil {
        if Auth.auth().currentUser == nil {
            let preSignInAlert = UIAlertController(title: "Discussions", message: preLoginInfoMessage, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Okay", style: .cancel) { _ in }
            let loginAction = UIAlertAction(title: "Login", style: .default) { (alert) in
                GIDSignIn.sharedInstance()?.signIn()
            }
            preSignInAlert.addAction(dismissAction)
            preSignInAlert.addAction(loginAction)
            present(preSignInAlert, animated: true, completion: nil)
        } else {
            let postSignInAlert = UIAlertController(title: "Discussions", message: postLoginInfoMessage, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Okay", style: .cancel) { _ in }
            let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (alert) in
                //                    let firebaseAuth = Auth.auth()
                do {
                    try Auth.auth().signOut()
                    GIDSignIn.sharedInstance().signOut()
                    //Reset user email, photo, chatview
                    //                    self.setUserProfileImage()
                } catch {
                    print ("Error signing out: %@", error)
                }
            }
            postSignInAlert.addAction(dismissAction)
            postSignInAlert.addAction(signOutAction)
            present(postSignInAlert, animated: true, completion: nil)
        }
    }
    
    @objc func showSettingsTapped() {
        logger.info()
        openAppSettings()
    }
}
