//
//  DiscussionsVCViewConfigurer.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension DiscussionsViewController {
    func addHeader() {
        logger.info("Configuring DiscussionsViewControllers header")
        
        let discussionsTitleLbl = UILabel()
        discussionsTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        discussionsTitleLbl.text = "Discussions"
        discussionsTitleLbl.textColor = .white
        discussionsTitleLbl.font = getFont(name: .HelveticaNeueBold, size: .xxlarge)
        
        let hamburgerBtn = UIButton()
        hamburgerBtn.translatesAutoresizingMaskIntoConstraints = false
        hamburgerBtn.setImage(sideNavIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        
        hamburgerBtn.tintColor = accentColor
        setBtnImgProp(button: hamburgerBtn, topPadding: 45/4, leftPadding: 5)
        hamburgerBtn.addTarget(self, action: #selector(displaySideNavTapped), for: .touchUpInside)
        hamburgerBtn.contentMode = .scaleAspectFit
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerBtn)
        
        userProfileButton.translatesAutoresizingMaskIntoConstraints = false
        userProfileButton.setImage(userPlaceholder.withRenderingMode(.alwaysOriginal), for: .normal)
        userProfileButton.imageView?.contentMode = .scaleAspectFit
        userProfileButton.addTarget(self, action: #selector(displayInfoTapped), for: .touchUpInside)
        userProfileButton.clipsToBounds = true
        userProfileButton.imageView?.layer.cornerRadius = 15
        userProfileButton.imageView?.layer.borderWidth = 1
        userProfileButton.imageView?.layer.borderColor = UIColor.white.cgColor
        userProfileButton.imageView?.clipsToBounds = true
        setBtnImgProp(button: userProfileButton, topPadding: 5, leftPadding: 5)
        
        //        setUserProfileImage()
        
        let notificationsSettingButton = UIButton()
        notificationsSettingButton.translatesAutoresizingMaskIntoConstraints = false
        notificationsSettingButton.setImage(notificationBellIcon.withRenderingMode(.alwaysOriginal), for: .normal)
        notificationsSettingButton.imageView?.contentMode = .scaleAspectFit
        notificationsSettingButton.addTarget(self, action: #selector(showSettingsTapped), for: .touchUpInside)
        
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: notificationsSettingButton), UIBarButtonItem(customView: userProfileButton)]
        
    }
    
    func addCountryCountTableView() {
        logger.info()
        countryCountView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countryCountView)
        
        NSLayoutConstraint.activate([
            countryCountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            countryCountView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countryCountView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            countryCountView.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func addDiscussionsMessageBox() {
        logger.info("Adding discussion message box")
        
        view.addSubview(discussionsMessageBox)
        discussionsMessageBox.translatesAutoresizingMaskIntoConstraints = false
        
        
        discussionsMessageBoxBottomAnchor = discussionsMessageBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            discussionsMessageBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            discussionsMessageBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            discussionsMessageBoxBottomAnchor,
        ])
        
    }
    
    func addDiscussionChatView() {
        logger.info("Adding discussion chat view")
        
        self.view.addSubview(discussionChatView)
        discussionChatView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            discussionChatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            discussionChatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            discussionChatView.topAnchor.constraint(equalTo: countryCountView.bottomAnchor  , constant: 5),
            discussionChatView.bottomAnchor.constraint(equalTo: discussionsMessageBox.topAnchor, constant: -10)
        ])
    }
    
    func loadBlockedUserList() {
        logger.info("Loading list of blocked users")
        
        blockedGroupReference.observe(.value) { (snapshot) in
            if let value = snapshot.value as? [String: Any] {
                self.blockedUsers = Array(value.keys)
                if let currentUserName = getAuthenticatedUsername() {
                    if self.blockedUsers.contains(currentUserName) {
                        self.discussionsMessageBox.isHidden = true
                    } else {
                        self.discussionsMessageBox.isHidden = false
                    }
                }
            } else {
                self.blockedUsers = [String]()
                self.discussionsMessageBox.isHidden = false
            }
        }
    }
    
    func readBlockedUserList() {
        logger.info("Reading blocked user list and toggling message box")
        
        if let userName = getAuthenticatedUsername() {
            if blockedUsers.contains(userName) {
                self.discussionsMessageBox.isHidden = true
            } else {
                self.discussionsMessageBox.isHidden = false
            }
        } else {
            self.discussionsMessageBox.isHidden = false
        }
    }
}
