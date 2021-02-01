//
//  DiscussionsViewController.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 11/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

    class DiscussionsViewController: UIViewController {
        
//        static let discussionVC = DiscussionsViewController()
//        let interactor = Interactor()
//        let sideNavVC = SideNavVC()
        
        var oldKeyboardEndFrameY: CGFloat = 0
        var scrolledChatViewToSavedOffset: Bool = false
            
        let countryCountView = UserCountryUIView()
        let discussionsMessageBox = DiscussionsMessageBox()
        let discussionChatView = DiscussionChatView()
        let userProfileButton = UIButton()
        
        var discussionsMessageBoxBottomAnchor: NSLayoutConstraint = NSLayoutConstraint()
        var isKeyboardFullyVisible = false
        let keyboard = KeyboardObserver()
            
        let postLoginInfoMessage =  "This is a chatroom created to help students discuss topics with each other and get advice. Use it to ask questions, get tips, etc. "
        var preLoginInfoMessage = "You will have to login with your gmail account to send messages."

        override func viewDidLoad() {
                        
            view.backgroundColor = UIColor.black
            addHeader()
            addCountryCountTableView()
            addDiscussionsMessageBox()
            addDiscussionChatView()
            
            preLoginInfoMessage = postLoginInfoMessage + preLoginInfoMessage
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance()?.presentingViewController = self

            keyboard.observe { [weak self] (event) -> Void in
                guard let self = self else { return }
                switch event.type {
                case .willChangeFrame:
                    self.handleKeyboardWillChangeFrame(keyboardEvent: event)
//                case .willShow, .willHide:
//                    self.handleKeyboardWillChangeFrame(keyboardEvent: event)
                default:
                    break
                }
            }

            self.title = "Discussions"
            navigationController?.navigationBar.barTintColor = .black
        }
        
        deinit {
            //        NotificationCenter.default.removeObserver(self)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
//            discussionChatView.scrollTableViewToEnd(animated: true)

            DispatchQueue.main.async { // Giving time for `viewDidLayoutSubviews` to do its thing
                if !self.scrolledChatViewToSavedOffset {
                    self.discussionChatView.scrollToSavedContentOffset()
                    self.scrolledChatViewToSavedOffset = true
               }
            }
//            navigationController?.navigationBar.barTintColor = .black
        }
    }
