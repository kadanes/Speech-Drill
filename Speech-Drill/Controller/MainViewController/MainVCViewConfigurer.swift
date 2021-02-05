//
//  MainVCViewConfigurer.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension MainVC {
    func configureTopicsView() {
        topicsContainer.layer.cornerRadius = 10
        topicsContainer.clipsToBounds = true
        topicTxtView.layer.cornerRadius = 10
        topicTxtView.clipsToBounds = true
        topicTxtView.font = getFont(name: .HelveticaNeue, size: .large)
        topicTxtView.textAlignment = .center
        topicTxtView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        
        thinkTimeChangeStackViewContainer.layer.cornerRadius = 10
        thinkTimeChangeStackViewContainer.clipsToBounds = true
        
        configureThinkTimeChangeButton(thinkTimeChange15)
        configureThinkTimeChangeButton(thinkTimeChange20)
        configureThinkTimeChangeButton(thinkTimeChange30)
    }
    
    func configureThinkTimeChangeButton(_ thinkTimeChangeButton: UIButton) {
        thinkTimeChangeButton.clipsToBounds = true
        thinkTimeChangeButton.layer.cornerRadius = 5
        thinkTimeChangeButton.setTitleColor(accentColor, for: .normal)
        thinkTimeChangeButton.titleLabel?.font = getFont(name: .HelveticaNeueBold, size: .medium)
    }
    
    func addHeader() {
        
        title = "Practice Mode"
        
        let hamburgerBtn = UIButton()
        hamburgerBtn.translatesAutoresizingMaskIntoConstraints = false
        hamburgerBtn.setImage(sideNavIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        
        hamburgerBtn.tintColor = accentColor
        setBtnImgProp(button: hamburgerBtn, topPadding: 45/4, leftPadding: 5)
        hamburgerBtn.addTarget(self, action: #selector(displaySideNavTapped), for: .touchUpInside)
        hamburgerBtn.contentMode = .scaleAspectFit
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerBtn)
        
        switchModeButton.translatesAutoresizingMaskIntoConstraints = false
        switchModeButton.setImage(practiceModeIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        switchModeButton.tintColor = .white
        switchModeButton.addTarget(self, action: #selector(switchModesTapped(_:)), for: .touchUpInside)
        switchModeButton.clipsToBounds = true
        switchModeButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        
        let infoButton = UIButton()
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setImage(infoIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        infoButton.tintColor = .white
        infoButton.addTarget(self, action: #selector(displayInfo), for: .touchUpInside)
        infoButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: infoButton), UIBarButtonItem(customView: switchModeButton)]
        
    }
    
    func setUIButtonsProperty() {
        
        //        setBtnImgProp(button: displaySideNavBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextTopicBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextTenthTopicBtn ,topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextFiftiethTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousTenthTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousFiftiethTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: playSelectedBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: recordBtn,topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: closeShareMenuBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: cancelRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
    }
    
    func setBtnImage() {
        
        thinkTimeLbl.textColor = accentColor
        speakTimeLbl.textColor = accentColor
        
        
        thinkLbl.textColor = accentColor
        speakLbl.textColor = accentColor
        playSelectedActivityIndicator.color = accentColor
        exportSelectedActivityIndicator.color = accentColor
        
        setButtonBgImage(button: loadNextTopicBtn, bgImage: singleRightIcon , tintColor: accentColor)
        setButtonBgImage(button: loadNextTenthTopicBtn, bgImage: doubleRightIcon , tintColor: accentColor)
        setButtonBgImage(button: loadNextFiftiethTopicBtn, bgImage: tripleRightIcon , tintColor: accentColor)
        
        setButtonBgImage(button: loadPreviousTopicBtn, bgImage: singleLeftIcon , tintColor: accentColor)
        setButtonBgImage(button: loadPreviousTenthTopicBtn, bgImage: doubleLeftIcon , tintColor: accentColor)
        setButtonBgImage(button: loadPreviousFiftiethTopicBtn, bgImage: tripleLeftIcon , tintColor: accentColor)
        
        setButtonBgImage(button: cancelRecordingBtn, bgImage: closeIcon, tintColor: enabledRed)
        
        setButtonBgImage(button: closeShareMenuBtn, bgImage: closeIcon, tintColor: enabledRed)
        
        DispatchQueue.main.async {
            self.exportSelectedBtn.setTitleColor(accentColor, for: .normal)
        }
        
        setButtonBgImage(button: playSelectedBtn, bgImage: playBtnIcon, tintColor: accentColor)
    }
}
