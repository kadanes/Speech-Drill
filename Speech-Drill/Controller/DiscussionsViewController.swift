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
        
        static let discussionVC = DiscussionsViewController()
        let interactor = Interactor()
        let sideNavVC = SideNavVC()
        
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
            
            view.backgroundColor = UIColor.black
            addSlideGesture()
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
                default:
                    break
                }
            }

            
        }
        
        deinit {
            //        NotificationCenter.default.removeObserver(self)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            discussionChatView.scrollTableViewToEnd(animated: true)
        }
        
        
        func addHeader() {
            
            headerContainer.translatesAutoresizingMaskIntoConstraints = false
            let discussionsTitleLbl = UILabel()
            discussionsTitleLbl.translatesAutoresizingMaskIntoConstraints = false
            discussionsTitleLbl.text = "Discussions"
            discussionsTitleLbl.textColor = .white
            discussionsTitleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 20)!
            
            let hamburgerBtn = UIButton()
            hamburgerBtn.translatesAutoresizingMaskIntoConstraints = false
            hamburgerBtn.setImage(sideNavIcon.withRenderingMode(.alwaysTemplate), for: .normal)
            
            hamburgerBtn.tintColor = accentColor
            setBtnImgProp(button: hamburgerBtn, topPadding: 45/4, leftPadding: 5)
            hamburgerBtn.addTarget(self, action: #selector(displaySideNavTapped), for: .touchUpInside)
            hamburgerBtn.contentMode = .scaleAspectFit
            
            
            userProfileButton.translatesAutoresizingMaskIntoConstraints = false
            userProfileButton.setImage(userPlaceholder.withRenderingMode(.alwaysOriginal), for: .normal)
            userProfileButton.imageView?.contentMode = .scaleToFill
    //        userProfileButton.tintColor = accentColor
            userProfileButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            userProfileButton.addTarget(self, action: #selector(displayInfoTapped), for: .touchUpInside)
            userProfileButton.clipsToBounds = true
            userProfileButton.layer.cornerRadius = 20
            userProfileButton.layer.borderWidth = 1
            userProfileButton.layer.borderColor = UIColor.white.cgColor
            setUserProfileImage()
            
            headerContainer.addSubview(hamburgerBtn)
            headerContainer.addSubview(discussionsTitleLbl)
            headerContainer.addSubview(userProfileButton)
            view.addSubview(headerContainer)
            
            NSLayoutConstraint.activate([
                hamburgerBtn.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
                hamburgerBtn.topAnchor.constraint(equalTo: headerContainer.topAnchor),
                hamburgerBtn.heightAnchor.constraint(equalToConstant: 35),
                hamburgerBtn.widthAnchor.constraint(equalToConstant: 35),
                
                discussionsTitleLbl.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
                discussionsTitleLbl.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
                discussionsTitleLbl.heightAnchor.constraint(equalToConstant: 50),
                
                userProfileButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -4),
                userProfileButton.topAnchor.constraint(equalTo: headerContainer.topAnchor),
                userProfileButton.heightAnchor.constraint(equalToConstant: 40),
                userProfileButton.widthAnchor.constraint(equalToConstant: 40),
            
                headerContainer.heightAnchor.constraint(equalToConstant: 50),
                headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
                headerContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
                headerContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            ])
        }
        
        func addCountryCountTableView() {
            countryCountView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(countryCountView)
            
            NSLayoutConstraint.activate([
                countryCountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                countryCountView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                countryCountView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
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
        
        func addSlideGesture() {
            
            let edgeSlide = UIPanGestureRecognizer(target: self, action: #selector(presentSideNav(sender:)))
            view.addGestureRecognizer(edgeSlide)
        }
    }


    //MARK:- All Actions

    extension DiscussionsViewController {
        @objc func displaySideNavTapped(_ sender: Any) {
            Analytics.logEvent(AnalyticsEvent.ShowSideNav.rawValue, parameters: nil)
            sideNavVC.transitioningDelegate = self
            sideNavVC.modalPresentationStyle = .custom
            sideNavVC.interactor = interactor
            sideNavVC.calledFromVC = DiscussionsViewController.discussionVC
            self.present(sideNavVC, animated: true, completion: nil)
            
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
                postSignInAlert.addAction(dismissAction)
                present(postSignInAlert, animated: true, completion: nil)
            }
        }
        
        @objc func presentSideNav(sender: UIPanGestureRecognizer) {
            
            let translation = sender.translation(in: view)
            let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
            
            MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor) {
                
                sideNavVC.transitioningDelegate = self
                sideNavVC.modalPresentationStyle = .custom
                sideNavVC.interactor = interactor
                sideNavVC.calledFromVC = DiscussionsViewController.discussionVC
                self.present(sideNavVC, animated: true, completion: nil)
                
            }
        }
    }


    //MARK:- Transition Delegate

    extension DiscussionsViewController: UIViewControllerTransitioningDelegate {
        
        func animationController(forPresented presented: UIViewController,
                                 presenting: UIViewController,
                                 source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
        {
            if presenting == self && presented == sideNavVC {
                return RevealSideNav()
            }
            return nil
        }
        
        func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
            if dismissed == sideNavVC {
                return HideSideNav(vcPresent: true)
            }
            return nil
        }
        
        func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
            return interactor.hasStarted ? interactor : nil
        }
        
        func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
            return interactor.hasStarted ? interactor : nil
        }
    }

    //MARK:- Keyboard handler

    extension DiscussionsViewController {
        
        @objc func keyboardWillShow(notification: Notification) {
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                print("Keyboard Height:", keyboardHeight)
            }
        }
        
        func keyboardWillShow(keyboarEvent: KeyboardEvent ) {
            let keyboardFrame = keyboarEvent.keyboardFrameEnd
            let keyboardHeight = keyboardFrame.height
            print("Keyboard Height from observer:", keyboardHeight)
        }
        
        
        func handleKeyboardWillChangeFrame(keyboardEvent: KeyboardEvent) {
            
            
            let uiScreenHeight = UIScreen.main.bounds.size.height
            let endFrame = keyboardEvent.keyboardFrameEnd
            
            let endFrameY = endFrame.origin.y
            
            let offset = -1 * endFrame.size.height
            
            if endFrameY >= uiScreenHeight {
                self.discussionsMessageBoxBottomAnchor.constant = 0.0
                self.discussionChatView.discussionTableView.contentOffset.y += 2 * offset
            } else {
                self.discussionsMessageBoxBottomAnchor.constant = offset
                self.discussionChatView.discussionTableView.contentOffset.y -= offset
                print("Shifted visible paths: ", self.discussionChatView.discussionTableView.indexPathsForVisibleRows)
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
            guard let googleUser = GIDSignIn.sharedInstance()?.currentUser else { return }
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

