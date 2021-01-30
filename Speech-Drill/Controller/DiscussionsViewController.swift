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
            
        let headerContainer = UIView()
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
            
            print("Google User (Discussion VC): ", GIDSignIn.sharedInstance()?.currentUser)

            
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
//            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)


            self.title = "Discussions"
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
    
        func addHeader() {
            
            headerContainer.translatesAutoresizingMaskIntoConstraints = false
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
            
//            navigationItem.leftBarButtonItem = UIBarButtonItem(image: sideNavIcon.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(displaySideNavTapped))
//            navigationItem.leftBarButtonItem?.buttonGroup?.barButtonItems[0].tintColor = accentColor
//            navigationItem.leftBarButtonItem?.buttonGroup?.barButtonItems[0].imageInsets = UIEdgeInsets(top: 45/4, left: 5, bottom: 45/4, right: 5)
            
            userProfileButton.translatesAutoresizingMaskIntoConstraints = false
            userProfileButton.setImage(smallUserPlaceholder.withRenderingMode(.alwaysOriginal), for: .normal)
            userProfileButton.imageView?.contentMode = .scaleToFill
    //        userProfileButton.tintColor = accentColor
            userProfileButton.addTarget(self, action: #selector(displayInfoTapped), for: .touchUpInside)
            userProfileButton.clipsToBounds = true
            userProfileButton.layer.cornerRadius = 20
            userProfileButton.layer.borderWidth = 1
            userProfileButton.layer.borderColor = UIColor.white.cgColor
            setUserProfileImage()
            
            
            let notificationsSettingButton = UIButton()
            notificationsSettingButton.translatesAutoresizingMaskIntoConstraints = false
            notificationsSettingButton.setImage(notificationBellIcon.withRenderingMode(.alwaysOriginal), for: .normal)
            notificationsSettingButton.imageView?.contentMode = .scaleToFill
                //        userProfileButton.tintColor = accentColor
            notificationsSettingButton.addTarget(self, action: #selector(showSettingsTapped), for: .touchUpInside)
                   

            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: notificationsSettingButton), UIBarButtonItem(customView: userProfileButton)]
            
//            navigationItem.rightBarButtonItem = userProfileButton
            
//            headerContainer.addSubview(hamburgerBtn)
//            headerContainer.addSubview(discussionsTitleLbl)
//            headerContainer.addSubview(userProfileButton)
            view.addSubview(headerContainer)
            
//            NSLayoutConstraint.activate([
//                hamburgerBtn.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
//                hamburgerBtn.topAnchor.constraint(equalTo: headerContainer.topAnchor),
//                hamburgerBtn.heightAnchor.constraint(equalToConstant: 35),
//                hamburgerBtn.widthAnchor.constraint(equalToConstant: 35),
//
//                discussionsTitleLbl.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
//                discussionsTitleLbl.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
//                discussionsTitleLbl.heightAnchor.constraint(equalToConstant: 50),
//
//                userProfileButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -4),
//                userProfileButton.topAnchor.constraint(equalTo: headerContainer.topAnchor),
//                userProfileButton.heightAnchor.constraint(equalToConstant: 40),
//                userProfileButton.widthAnchor.constraint(equalToConstant: 40),
//
//                headerContainer.heightAnchor.constraint(equalToConstant: 50),
//                headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
//                headerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
//                headerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
//            ])
        }
        
        func addCountryCountTableView() {
            countryCountView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(countryCountView)
            
            NSLayoutConstraint.activate([
                countryCountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                countryCountView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                countryCountView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                countryCountView.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        func addDiscussionsMessageBox() {
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
            self.view.addSubview(discussionChatView)
            discussionChatView.translatesAutoresizingMaskIntoConstraints = false
            
            
            NSLayoutConstraint.activate([
                discussionChatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                discussionChatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                discussionChatView.topAnchor.constraint(equalTo: countryCountView.bottomAnchor  , constant: 10),
                discussionChatView.bottomAnchor.constraint(equalTo: discussionsMessageBox.topAnchor, constant: -10),
            ])
        }
    }


    //MARK:- All Actions

    extension DiscussionsViewController {
        @objc func displaySideNavTapped(_ sender: Any) {
            Analytics.logEvent(AnalyticsEvent.ShowSideNav.rawValue, parameters: nil)
//            sideNavVC.transitioningDelegate = self
//            sideNavVC.modalPresentationStyle = .custom
//            sideNavVC.interactor = interactor
//            sideNavVC.calledFromVC = DiscussionsViewController.discussionVC
//            self.present(sideNavVC, animated: true, completion: nil)
            _ = navigationController?.popViewController(animated: true)
            
        }
        
        @objc func displayInfoTapped(_ sender: UIButton) {
            
            if GIDSignIn.sharedInstance()?.currentUser == nil {
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
                        self.setUserProfileImage()
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
            openAppSettings()
        }
    }

    //MARK:- Keyboard handler

    extension DiscussionsViewController {
        
//        @objc func keyboardWillShow(notification: Notification) {
//            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
//                let keyboardRectangle = keyboardFrame.cgRectValue
//                let keyboardHeight = keyboardRectangle.height
//                print("Keyboard Height:", keyboardHeight)
//            }
//        }
//
//        func keyboardWillShow(keyboarEvent: KeyboardEvent ) {
//            let keyboardFrame = keyboarEvent.keyboardFrameEnd
//            let keyboardHeight = keyboardFrame.height
//            print("Keyboard Height from observer:", keyboardHeight)
//        }

        func handleKeyboardDisplay(keyboardEvent: KeyboardEvent) {
            print("Called handle keyboard")
//        let info = (notification as NSNotification).userInfo
            let value =  keyboardEvent.keyboardFrameEnd
           if let rawFrame = (value as AnyObject).cgRectValue
           {
            let keyboardFrame = self.view.convert(rawFrame, from: nil)
               let keyboardHeight = keyboardFrame.height //Height of the keyboard
            print("Keyboard height: ", keyboardHeight)
           }
        }
        
        @objc func handleKeyboardDisplay(_ notification: Notification) {
                   print("Notif Called handle keyboard")
                let info = (notification as NSNotification).userInfo
                let value = info?[UIKeyboardFrameEndUserInfoKey]
                  if let rawFrame = (value as AnyObject).cgRectValue
                  {
                   let keyboardFrame = self.view.convert(rawFrame, from: nil)
                      let keyboardHeight = keyboardFrame.height //Height of the keyboard
                   print("Notif Keyboard height: ", keyboardHeight)
                  }
               }
        
        func handleKeyboardWillChangeFrame(keyboardEvent: KeyboardEvent) {
          
            let uiScreenHeight = UIScreen.main.bounds.size.height
            let endFrame = keyboardEvent.keyboardFrameEnd
            let endFrameY = endFrame.origin.y
            
            if oldKeyboardEndFrameY == endFrameY {
                return
            }
            oldKeyboardEndFrameY = endFrameY
            
            let offset = -1 * endFrame.size.height
            
            print("Handling keyboard change frame:  End Y - ", endFrameY)
            
            if endFrameY >= uiScreenHeight {
                self.discussionsMessageBoxBottomAnchor.constant = 0.0
                self.discussionChatView.discussionTableView.contentOffset.y += 2 * offset
            } else {
                self.discussionsMessageBoxBottomAnchor.constant = offset
                self.discussionChatView.discussionTableView.contentOffset.y -= offset
            }
            
            UIView.animate(
                withDuration: keyboardEvent.duration,
                delay: TimeInterval(0),
                options: keyboardEvent.options,
                animations: {
                    self.view.layoutIfNeeded()
                    
                },
                completion: nil)
        }
    }

    //MARK:- Login Handler

    extension DiscussionsViewController: GIDSignInDelegate {
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
            // ...
            if let error = error {
                // ...
                print("Error signing in")
                print(error)
                return
            }
            
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("authentication error \(error.localizedDescription)")
                }
            }
            setUserProfileImage()
        }
          
          func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
              // Perform any operations when the user disconnects from app here.
              // ...
          }
        
        func setUserProfileImage() {
            discussionChatView.saveUserEmail()
            guard let googleUser = GIDSignIn.sharedInstance()?.currentUser else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.userProfileButton.setImage(smallUserPlaceholder, for: .normal)
                }
            return
            }
            guard let userImageUrl = googleUser.profile.imageURL(withDimension: 40) else { return }
            URLSession.shared.dataTask(with: userImageUrl) { (data, response, error) in
                
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { [weak self] in
                   let userImage = UIImage(data: data)
                   self?.userProfileButton.setImage(userImage, for: .normal)
               }
            }.resume()
        }
    }

