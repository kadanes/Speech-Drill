//
//  DiscussionsVCLoginHandler.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

//MARK:- Login Handler
extension DiscussionsViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        logger.info("Handling google sign in")
        
        // ...
        if let error = error {
            // ...
            logger.error("Error signing in with google:\n\(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                logger.error("Authentication error with google login \(error.localizedDescription)")
                return
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        logger.info("Gmail user disconnected from the app")
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func setUserProfileImage() {
        logger.info("Setting user profile image")
        
        discussionChatView.saveUserEmail()
        //        guard let googleUser = GIDSignIn.sharedInstance()?.currentUser else {
        guard let currentUser = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                [weak self] in
                self?.userProfileButton.setImage(userPlaceholder, for: .normal)
            }
            return
        }
        //        guard let userImageUrl = googleUser.profile.imageURL(withDimension: 40) else { return }
        guard let userImageUrl = currentUser.photoURL else {
            DispatchQueue.main.async {
                [weak self] in
                self?.userProfileButton.setImage(loggedInUserPlaceholder, for: .normal)
            }
            return
        }
        URLSession.shared.dataTask(with: userImageUrl) { (data, response, error) in
            
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                let userImage = UIImage(data: data)
                if let userImage = userImage?.resize(maxWidthHeight: 30) {
                    self?.userProfileButton.setImage(userImage, for: .normal)
                    //                    self?.userProfileButton.setImage(loggedInUserPlaceholder, for: .normal)
                } else {
                    self?.userProfileButton.setImage(loggedInUserPlaceholder, for: .normal)
                }
            }
        }.resume()
    }
}

