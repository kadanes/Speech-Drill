//
//  SideNavVC.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 28/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class SideNavVC: UIViewController {
    
    static let sideNav = SideNavVC()
    var interactor: Interactor? = nil
   
    private var sideNavWidth: CGFloat = 100
    private var hiddenSideNavWidth: CGFloat = 30

    private let appstoreLink = "itms-apps://itunes.apple.com/app/id1433796147"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideNavWidth = view.bounds.width * MenuHelper.menuWidth
        hiddenSideNavWidth = view.bounds.width - sideNavWidth
        
        addVersionDetails()
        
        let closeBtn = UIButton(frame: CGRect(x: sideNavWidth, y: 0, width: hiddenSideNavWidth , height: view.bounds.height))
        closeBtn.addTarget(self, action: #selector(closeViewTapped), for: .touchUpInside)
        closeBtn.setTitle("Close", for: .normal)
        view.addSubview(closeBtn)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(closeViewWithPan(sender:)))
        view.addGestureRecognizer(panGesture)
        
        view.backgroundColor = UIColor.darkGray
        
    }
    
    
    func addVersionDetails() {
        
        let versionInfoLblHeight: CGFloat = 40
        let downloadBtnHeight: CGFloat = 40
        let seperatorHeight: CGFloat = 3
        
        let versionInfoViewHeight: CGFloat = versionInfoLblHeight + downloadBtnHeight + seperatorHeight
        
        let versionInfoView = UIView(frame: CGRect())
//        versionInfoView.backgroundColor = disabledRed
        
        view.addSubview(versionInfoView)
        versionInfoView.translatesAutoresizingMaskIntoConstraints = false
        let versionInfoViewTopCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 25)
        let versionInfoViewLeadingCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 8)
        let versionInfoViewTrailingCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -(8 + hiddenSideNavWidth))
        //let versionInfoViewHeightCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: versionInfoViewHeight)
        view.addConstraints([versionInfoViewTopCnstrnt,versionInfoViewLeadingCnstrnt,versionInfoViewTrailingCnstrnt])
        
        
        let versionInfoLbl = UILabel()
        versionInfoView.addSubview(versionInfoLbl)
        versionInfoLbl.textAlignment = .center
        versionInfoLbl.numberOfLines = 0
        versionInfoLbl.textColor = UIColor.white
        versionInfoLbl.translatesAutoresizingMaskIntoConstraints = false
        let versionInfoLblTopCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .top, relatedBy: .equal, toItem: versionInfoView, attribute: .top, multiplier: 1, constant: 0)
        let versionInfoLblLeadingCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .leading, relatedBy: .equal, toItem: versionInfoView, attribute: .leading, multiplier: 1, constant: 0)
        let versionInfoLblTrailingCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .trailing, relatedBy: .equal, toItem: versionInfoView, attribute: .trailing, multiplier: 1, constant: 0)
        let versionInfoLblHeightCnstrnt = NSLayoutConstraint(item: versionInfoLbl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: versionInfoLblHeight)
    versionInfoView.addConstraints([versionInfoLblTopCnstrnt,versionInfoLblLeadingCnstrnt,versionInfoLblTrailingCnstrnt,versionInfoLblHeightCnstrnt])
        
        
        let appstoreBtn = UIButton(frame: CGRect())
        versionInfoView.addSubview(appstoreBtn)
        appstoreBtn.translatesAutoresizingMaskIntoConstraints = false
        appstoreBtn.addTarget(self, action: #selector(openInAppstore), for: .touchUpInside)
        appstoreBtn.layer.cornerRadius = 10
        appstoreBtn.clipsToBounds = true
        appstoreBtn.backgroundColor = enabledGray.withAlphaComponent(0.1)
        let appstoreBtnWidthCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: sideNavWidth/2)
        let appstoreBtnHightCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: downloadBtnHeight)
        let appstoreBtnCntrCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .centerX, relatedBy: .equal, toItem: versionInfoView, attribute: .centerX, multiplier: 1, constant: 0)
        let appstoreBtnTopCnstrnt = NSLayoutConstraint(item: appstoreBtn, attribute: .top, relatedBy: .equal, toItem: versionInfoLbl, attribute: .bottom, multiplier: 1, constant: 7)
       versionInfoView.addConstraints([appstoreBtnHightCnstrnt,appstoreBtnWidthCnstrnt,appstoreBtnCntrCnstrnt,appstoreBtnTopCnstrnt])
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = enabledGray
        versionInfoView.addSubview(seperatorView)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        let seperatorViewHeightCnstrnt = NSLayoutConstraint(item: seperatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
        let seperatorViewTopCnstrnt = NSLayoutConstraint(item: seperatorView, attribute: .top, relatedBy: .equal, toItem: appstoreBtn, attribute: .bottom, multiplier: 1, constant: 10)
        
        seperatorView.leadingAnchor.constraint(equalTo: versionInfoView.leadingAnchor).isActive = true
        seperatorView.trailingAnchor.constraint(equalTo: versionInfoView.trailingAnchor).isActive = true
        versionInfoView.addConstraints([seperatorViewTopCnstrnt,seperatorViewHeightCnstrnt])
        
         let versionInfoViewBtmCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .bottom, relatedBy: .equal, toItem: seperatorView , attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([versionInfoViewBtmCnstrnt])
        
        var currentVersion = ""
        var latestVersion = ""
        
        if let installedVersion = getInstalledVersion() {
            currentVersion = installedVersion
        }
        if let appstoreVersion = getAppstoreVersion() {
            latestVersion = appstoreVersion
        }
        
        let versionInfo = "You are running v\(currentVersion)"
        if currentVersion == latestVersion {
            appstoreBtn.setTitle("View on Appstore", for: .normal)
        } else {
            appstoreBtn.setTitle("Download (v\(latestVersion))", for: .normal)
        }
        versionInfoLbl.text = versionInfo
 
    }
    
    @objc func openInAppstore() {
        let url = URL(string: appstoreLink)
        openURL(url: url)
    }
    
    @objc func closeViewWithPan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        // 4
        let progress = MenuHelper.calculateProgress(
            translationInView: translation,
            viewBounds: view.bounds,
            direction: .Left
        )
        // 5
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                // 6
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func closeViewTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
