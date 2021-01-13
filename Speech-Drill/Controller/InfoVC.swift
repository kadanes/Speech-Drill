//
//  InfoVC.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class InfoVC: UIViewController {

    static let infoVC = InfoVC()
    let sideNavVC = SideNavVC()
    
    @IBOutlet weak var displaySideNavBtn: UIButton!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var githubBtn: UIButton!
    @IBOutlet weak var gmailBtn: UIButton!
    @IBOutlet weak var twitterBtn: RoundButton!
    @IBOutlet weak var fABtn: UIButton!
    @IBOutlet weak var tTSBtn: UIButton!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var creditsTextView: UITextView!
    
    @IBOutlet weak var creditsTxtViewHeight: NSLayoutConstraint!
    
    let interactor = Interactor()
    
    let repoURL = URL(string: "https://github.com/parthv21/TOEFL-Speaking")
    
    let reportBugURL = URL(string: "googlegmail:///co?to=parthv21@gmail.com&subject=Bug%20Report%20(Speaking%20App)&body=Hey%20I%20found%20a%20bug!")
    
    let licenseURL = URL(string: "https://fontawesome.com/license")
    
    let ttsURL = URL(string: "http://www.fromtexttospeech.com")
    
    var icons = [boxIcon,infoIcon,emailIcon,shareIcon,checkIcon,closeIcon,githubIcon,deleteIcon,playBtnIcon,pauseBtnIcon,deleteBtnIcon,singleLeftIcon,doubleLeftIcon,tripleLeftIcon,doubleRightIcon,singleRightIcon,singleShareIcon,tripleRightIcon,plusIcon,minusIcon]
    
    var redIcons = [deleteIcon,closeIcon]
    
    var accentedIcons = [checkIcon,singleLeftIcon,singleRightIcon,doubleLeftIcon,doubleRightIcon,tripleLeftIcon,tripleRightIcon,infoIcon,sideNavIcon]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setButtonProp()
        
        infoContainer.layer.cornerRadius = 5
        infoContainer.layer.masksToBounds = true
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
        icons = icons.shuffled()
        
        creditsTxtViewHeight.constant = self.view.bounds.height - 400
        
        fetchAndSetCredits()
        
        addSlideGesture()
    }
    
    func fetchAndSetCredits() {
        let ref = Database.database().reference().child("credits")
        ref.keepSynced(true)
        ref.observe(.value, with: {(snapshot) in
            if let value = snapshot.value as? String {
                self.creditsTextView.text = value
                self.creditsTextView.scrollsToTop = true
                self.creditsTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
            }
        })
    }
    
    func addSlideGesture() {
        
        let edgeSlide = UIPanGestureRecognizer(target: self, action: #selector(presentSideNav(sender:)))
        view.addGestureRecognizer(edgeSlide)
    }
    
    @objc func presentSideNav(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(gestureState: sender.state, progress: progress, interactor: interactor) {
        
            sideNavVC.transitioningDelegate = self
            sideNavVC.modalPresentationStyle = .custom
            sideNavVC.interactor = interactor
            sideNavVC.calledFromVC = InfoVC.infoVC
            self.present(sideNavVC, animated: true, completion: nil)

        }
        
    }
    
    
    @IBAction func displaySideNavTapped(_ sender: Any) {
        Analytics.logEvent(AnalyticsEvent.ShowSideNav.rawValue, parameters: nil)
        sideNavVC.transitioningDelegate = self
        sideNavVC.modalPresentationStyle = .custom
        sideNavVC.interactor = interactor
        sideNavVC.calledFromVC = InfoVC.infoVC
        self.present(sideNavVC, animated: true, completion: nil)
    }
    
    
    func setButtonProp() {
        
        setBtnImgProp(button: displaySideNavBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setButtonBgImage(button: displaySideNavBtn, bgImage: sideNavIcon, tintColor: accentColor)
        
        setBtnImgProp(button: githubBtn, topPadding: 10, leftPadding: 1)
        githubBtn.backgroundColor = githubBlue.withAlphaComponent(0.8)
        
        setBtnImgProp(button: gmailBtn, topPadding: 10, leftPadding: 1)
        gmailBtn.backgroundColor = disabledRed.withAlphaComponent(0.8)
        
        setBtnImgProp(button: twitterBtn, topPadding: 10, leftPadding: 1)
        twitterBtn.backgroundColor = twitterBlue.withAlphaComponent(0.8)
    
        fABtn.setTitleColor(accentColor, for: .normal)
        tTSBtn.setTitleColor(accentColor, for: .normal)
    }

    @IBAction func gitHubTapped(_ sender: UIButton) {
        Analytics.logEvent(AnalyticsEvent.OpenRepo.rawValue, parameters: nil)
        openURL(url: repoURL)
    }
    
    @IBAction func gmailTapped(_ sender: UIButton) {
        Analytics.logEvent(AnalyticsEvent.SendMail.rawValue, parameters: nil)
        openURL(url: reportBugURL)
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        
        Analytics.logEvent(AnalyticsEvent.SendTweet.rawValue, parameters: nil)
        let screenName =  "parthv21"
        let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    
    @IBAction func showLicenseTapped(_ sender: UIButton) {
        Analytics.logEvent(AnalyticsEvent.OpenFontAwesome.rawValue, parameters: nil)
        openURL(url: licenseURL)
    }
    
    @IBAction func fromTTSTapped(_ sender: UIButton) {
        Analytics.logEvent(AnalyticsEvent.OpenTextToSpeech.rawValue, parameters: nil)
        openURL(url: ttsURL)
    }
  
}

extension InfoVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCell {
            
            let cellImg = icons[indexPath.row]
            if accentedIcons.contains(cellImg) {
                cell.configureCell(icon: cellImg, tintColor: accentColor)
            } else if redIcons.contains(cellImg) {
                cell.configureCell(icon: cellImg, tintColor: enabledRed)
            } else {
                cell.configureCell(icon: icons[indexPath.row], tintColor: nil)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 40, height: 40)
    }

}

extension InfoVC: UIViewControllerTransitioningDelegate {
    
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
