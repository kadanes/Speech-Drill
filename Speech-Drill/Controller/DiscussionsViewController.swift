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
        
    var discussionsMessageBoxBottomAnchor: NSLayoutConstraint = NSLayoutConstraint()
    
    let infoMessage = "This is a chatroom created to help students discuss topics with each other and get advice. Use it to ask questions, get tips, etc."
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.black
        addSlideGesture()
        addHeader()
        addCountryCountTableView()
        addDiscussionsMessageBox()
        addDiscussionChatView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().signIn()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        let hamburgerBtn = UIButton()
        hamburgerBtn.translatesAutoresizingMaskIntoConstraints = false
        hamburgerBtn.setImage(sideNavIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        hamburgerBtn.tintColor = accentColor
        hamburgerBtn.addTarget(self, action: #selector(displaySideNavTapped), for: .touchUpInside)
        
        let infoButton = UIButton()
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setImage(infoIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        infoButton.tintColor = .white
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        infoButton.addTarget(self, action: #selector(displayInfoTapped), for: .touchUpInside)
        
        headerContainer.addSubview(hamburgerBtn)
        headerContainer.addSubview(discussionsTitleLbl)
        headerContainer.addSubview(infoButton)
        view.addSubview(headerContainer)
        
        NSLayoutConstraint.activate([
            hamburgerBtn.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            hamburgerBtn.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            hamburgerBtn.heightAnchor.constraint(equalToConstant: 20),
            hamburgerBtn.widthAnchor.constraint(equalToConstant: 20),
            
            discussionsTitleLbl.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            discussionsTitleLbl.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 10),
            discussionsTitleLbl.heightAnchor.constraint(equalToConstant: 50),
            discussionsTitleLbl.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 10),
            
            
            infoButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            infoButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            infoButton.heightAnchor.constraint(equalToConstant: 20),
            infoButton.widthAnchor.constraint(equalToConstant: 20),
            
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                
                headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
                
            ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                
                headerContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                
            ])
        }
        
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

        if #available(iOS 11.0, *) {
            discussionsMessageBoxBottomAnchor = discussionsMessageBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        } else {
            // Fallback on earlier versions
            discussionsMessageBoxBottomAnchor = discussionsMessageBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        }
        
        discussionsMessageBox.translatesAutoresizingMaskIntoConstraints = false
        
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                discussionsMessageBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                discussionsMessageBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                //                discussionsMessageBox.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                discussionsMessageBoxBottomAnchor,
                discussionsMessageBox.heightAnchor.constraint(equalToConstant: 150)
                
            ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                discussionsMessageBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                discussionsMessageBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                //                discussionsMessageBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
                discussionsMessageBoxBottomAnchor,
                discussionsMessageBox.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    }
    
    func addDiscussionChatView() {
        self.view.addSubview(discussionChatView)
        discussionChatView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                discussionChatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                discussionChatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
              discussionChatView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
              discussionChatView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
          ])
        }
        
        NSLayoutConstraint.activate([
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
        let alert = UIAlertController(title: "Discussions", message: infoMessage, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel) { _ in }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
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
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        if endFrameY >= UIScreen.main.bounds.size.height {
            self.discussionsMessageBoxBottomAnchor.constant = 0.0
        } else {
            self.discussionsMessageBoxBottomAnchor.constant = -1 * (endFrame?.size.height ?? 0.0)
        }
        
        UIView.animate(
            withDuration: duration,
            delay: TimeInterval(0),
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
    }
}
