//
//  VersionInfoView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class VersionInfoView: UIView {
    
    let versionInfoLblHeight: CGFloat = 40
    let downloadBtnHeight: CGFloat = 40
    let downloadBtnWidth: CGFloat = 180
    let versionInfoLbl: UILabel
    let appstoreBtn: UIButton
        
    override init(frame: CGRect) {
        versionInfoLbl = UILabel()
        appstoreBtn = UIButton()
        super.init(frame: frame)
        
        
        addSubview(versionInfoLbl)
        versionInfoLbl.translatesAutoresizingMaskIntoConstraints = false
        versionInfoLbl.textAlignment = .left
//        versionInfoLbl.numberOfLines = 0
        versionInfoLbl.textColor = UIColor.white
        versionInfoLbl.minimumScaleFactor = 0.5
        versionInfoLbl.adjustsFontSizeToFitWidth = true
        versionInfoLbl.lineBreakMode = .byTruncatingTail
        
        NSLayoutConstraint.activate([
            versionInfoLbl.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            versionInfoLbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
//            versionInfoLbl.heightAnchor.constraint(equalToConstant: versionInfoLblHeight),
            versionInfoLbl.widthAnchor.constraint(equalToConstant: 100),
            versionInfoLbl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
                
        addSubview(appstoreBtn)
        appstoreBtn.translatesAutoresizingMaskIntoConstraints = false
        appstoreBtn.addTarget(self, action: #selector(openInAppstore), for: .touchUpInside)
        appstoreBtn.layer.cornerRadius = 10
        appstoreBtn.clipsToBounds = true
        appstoreBtn.backgroundColor = enabledGray.withAlphaComponent(0.1)
        appstoreBtn.titleLabel?.font = getFont(name: .HelveticaNeueBold, size: .small)
        appstoreBtn.titleLabel?.minimumScaleFactor = 0.5
        appstoreBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        NSLayoutConstraint.activate([
            appstoreBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            appstoreBtn.leadingAnchor.constraint(equalTo: versionInfoLbl.trailingAnchor, constant:  2),
            appstoreBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            appstoreBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
        
        
        var currentVersion = ""
        let currentBuildNo = getBuildNumber()
        var latestVersion = ""
        if let installedVersion = getInstalledVersion() {
            currentVersion = installedVersion
        }
        if let appstoreVersion = getAppstoreVersion() {
            latestVersion = appstoreVersion
        }
        
        
        let versionInfoString = NSMutableAttributedString(string: "ⓘ ", attributes: [NSAttributedStringKey.font: getFont(name: .HelveticaNeueBold, size: .xxlarge)])
    
        var versionInfo = " v\(currentVersion)"
        if currentBuildNo != "" {
            versionInfo += " (\(currentBuildNo))"
        }
        
        versionInfoString.append(NSMutableAttributedString(string: versionInfo, attributes: [NSAttributedStringKey.font: getFont(name: .HelveticaNeueBold, size: .small)]))
        
        if currentVersion == latestVersion {
            appstoreBtn.setTitle("App Store", for: .normal)
        } else {
            appstoreBtn.setTitle("Download (v\(latestVersion))", for: .normal)
        }
        versionInfoLbl.attributedText = versionInfoString
        
        addTopBorder(with: .darkGray, andWidth: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openInAppstore() {
        
        var currentVersion = "0"
        var latestVersion = "0"
        var isVersionSame: Int = 1
        
        if let cv = getInstalledVersion(), let lv = getAppstoreVersion() {
            currentVersion = cv
            latestVersion = lv
        }
        if currentVersion != latestVersion { isVersionSame = 0 }
        
        Analytics.logEvent(AnalyticsEvent.ViewOnAppstore.rawValue, parameters: [IntegerAnalyticsPropertites.ShowCurrentVersion.rawValue : isVersionSame as NSObject ])
        let url = URL(string: appstoreLink)
        openURL(url: url)
    }
    
}
