//
//  SideNavAdCell.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 17/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class SideNavAdCell: UICollectionViewCell {
    
    let adView: UIView
    let bannerImageView: UIImageView
    let tagLineLabel: UILabel
    let contact1Button: UIButton
    let contact2Button: UIButton
    let userDefaults = UserDefaults.standard
    
    var adInformation: SideNavAdStructure?
    
    override init(frame: CGRect) {
        logger.info()
        
        adView = UIView()
        bannerImageView = UIImageView()
        tagLineLabel = UILabel()
        contact1Button = UIButton()
        contact2Button = UIButton()
        super.init(frame: frame)
        
        let bannerHeight: CGFloat = 70
        let spacing: CGFloat = 8
        let callBtnHeight: CGFloat = 30
        let tagLineHeight: CGFloat = 50
        
        adView.layer.borderWidth = 1
        adView.layer.borderColor = UIColor.white.cgColor
        adView.clipsToBounds = true
        adView.layer.cornerRadius = 5
        
        contentView.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            adView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        adView.addSubview(bannerImageView)
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.image = noImageLogo.withRenderingMode(.alwaysTemplate)
        bannerImageView.tintColor = accentColor
        bannerImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            bannerImageView.leadingAnchor.constraint(equalTo: adView.leadingAnchor,constant: 8),
            bannerImageView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            bannerImageView.topAnchor.constraint(equalTo: adView.topAnchor, constant: spacing),
            bannerImageView.heightAnchor.constraint(equalToConstant: bannerHeight)
        ])
        
        adView.addSubview(tagLineLabel)
        tagLineLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLineLabel.font = getFont(name: .HelveticaNeue, size: .medium)
        tagLineLabel.adjustsFontSizeToFitWidth = true
        tagLineLabel.minimumScaleFactor = 0.5
        tagLineLabel.textColor = .white
        tagLineLabel.textAlignment = .center
        tagLineLabel.numberOfLines = 0
        tagLineLabel.lineBreakMode = .byWordWrapping
        
        NSLayoutConstraint.activate([
            tagLineLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            tagLineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            tagLineLabel.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: spacing),
            tagLineLabel.heightAnchor.constraint(equalToConstant: tagLineHeight)
        ])
        
        let adTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openAdWebsite(_:)))
        adTapGesture.numberOfTapsRequired = 1
        adView.addGestureRecognizer(adTapGesture)
        //        adView.isUserInteractionEnabled = true
        
        configureContactButton(name: "Contact 1", contactButton: contact1Button)
        contact1Button.tag = 1
        adView.addSubview(contact1Button)
        contact1Button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contact1Button.topAnchor.constraint(equalTo: tagLineLabel.bottomAnchor, constant: spacing),
            contact1Button.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            contact1Button.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            contact1Button.heightAnchor.constraint(equalToConstant: callBtnHeight)
        ])
        
        configureContactButton(name: "Contact 2", contactButton: contact2Button)
        contact2Button.tag = 2
        adView.addSubview(contact2Button)
        contact2Button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contact2Button.topAnchor.constraint(equalTo: contact1Button.bottomAnchor, constant: 5),
            contact2Button.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 8),
            contact2Button.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -8),
            contact2Button.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -8),
            contact2Button.heightAnchor.constraint(equalToConstant: callBtnHeight)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(adInformation: SideNavAdStructure) {
        
        self.adInformation = adInformation
        
        
        let bannerFilePath: String = adInformation.bannerUrl
        let bannerFileUserDefaultsKey = sideNavAdBannerPrefixKey + bannerFilePath
        
        if let bannerImageData = userDefaults.object(forKey: bannerFileUserDefaultsKey) as? Data {
            let bannerImage = UIImage(data: bannerImageData)
            self.bannerImageView.image = bannerImage
            
        } else {
            let reference = Storage.storage().reference(withPath: bannerFilePath)
            reference.getData(maxSize: (1 * 1024 * 1024)) { (data, error) in
                if let _error = error{
                    print(_error)
                } else {
                    if let _data = data {
                        guard let bannerImage: UIImage = UIImage(data: _data) else { return }
                        self.bannerImageView.image = bannerImage
                        self.userDefaults.setValue(_data, forKey: bannerFileUserDefaultsKey)
                    }
                }
            }
        }
        
        
        
        tagLineLabel.text = adInformation.tagLine
        
        if let contact1Information = adInformation.contact1 {
            contact1Button.setTitle(contact1Information.contactTitle, for: .normal)
            contact1Button.isHidden = false
            contact1Button.removeTarget(self, action: #selector(contactPerson(_:)), for: .touchUpInside)
            contact1Button.addTarget(self, action: #selector(contactPerson(_:)), for: .touchUpInside)
            toggleButtonIcon(contact1Button, callsPhoneNumber: contact1Information.contactNumber != nil)
        } else {
            contact1Button.isHidden = true
        }
        
        if let contact2Information = adInformation.contact2 {
            contact2Button.setTitle(contact2Information.contactTitle, for: .normal)
            contact2Button.isHidden = false
            contact2Button.removeTarget(self, action: #selector(contactPerson(_:)), for: .touchUpInside)
            contact2Button.addTarget(self, action: #selector(contactPerson(_:)), for: .touchUpInside)
            toggleButtonIcon(contact2Button, callsPhoneNumber: contact2Information.contactNumber != nil)
        } else {
            contact2Button.isHidden = true
        }
        
    }
}


//MARK:- Utility functions

extension SideNavAdCell {
    
    func configureContactButton(name: String, contactButton: UIButton) {
        logger.info()
        
        contactButton.layer.cornerRadius = 10
        contactButton.clipsToBounds = true
        
        contactButton.setTitle(name, for: .normal)
        contactButton.titleLabel?.font = getFont(name: .HelveticaNeueBold, size: .large)
        contactButton.titleLabel?.minimumScaleFactor = 0.5
        contactButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func toggleButtonIcon(_ contactButton: UIButton, callsPhoneNumber: Bool) {
        logger.info()
        
        contactButton.backgroundColor = callsPhoneNumber ? confirmGreen.withAlphaComponent(0.6) : githubBlue.withAlphaComponent(0.6)
        let buttonImage = callsPhoneNumber ? callIcon.withRenderingMode(.alwaysTemplate) : emailIcon.withRenderingMode(.alwaysTemplate)
        contactButton.setImage(buttonImage, for: .normal)
        contactButton.tintColor = .white
        contactButton.imageView?.contentMode = .scaleAspectFit
        contactButton.contentHorizontalAlignment = .left
        contactButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 5)
        //        contactButton.imageEdgeInsets = callsPhoneNumber ? UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) : UIEdgeInsets(top: 10, left: 5, bottom:10, right: 20)
    }
}

//MARK:- Actions

extension SideNavAdCell {
    
    @objc func contactPerson(_ sender: UIButton) {
        logger.event()
        
        guard let contactDetails = sender.tag == 1 ? adInformation?.contact1 ?? nil : adInformation?.contact2 ?? nil else { return }
        
        if let phoneNumber = contactDetails.contactNumber {
            placeCall(phoneNumber: phoneNumber, contactName: contactDetails.contactTitle)
        } else if let emailId = contactDetails.contactEmail {
            sendEmail(emailId: emailId)
        }
    }
    
    func placeCall(phoneNumber: String, contactName: String) {
        logger.info("Calling \(contactName) with number \(phoneNumber)")
        
        Analytics.logEvent(AnalyticsEvent.CallCouncillor.rawValue, parameters: [StringAnalyticsProperties.CouncillorName.rawValue : contactName as NSObject])
        
        openURL(url: URL(string: "tel://\(phoneNumber)"))
    }
    
    func sendEmail(emailId: String) {
        logger.info("Emailing \(emailId)")
        
        let urlEncodedTagLine = adInformation?.tagLine.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailUrl = URL(string: "googlegmail:///co?to=" + emailId + "&subject=" + urlEncodedTagLine )
        openURL(url: mailUrl)
    }
    
    @objc func openAdWebsite(_ sender: UIButton) {
        logger.event("Opening ad url \(adInformation?.websiteUrl ?? "")")
        
        guard let url = URL(string: adInformation?.websiteUrl ?? "") else { return }
        openURL(url: url)
    }
}

