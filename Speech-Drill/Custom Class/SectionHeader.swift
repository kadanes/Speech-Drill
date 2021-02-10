//
//  SectionHeaderXIB.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 08/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import Firebase

class SectionHeader:UITableViewHeaderFooterView{
    
    weak var delegate: MainVC?
    
    var url = URL(fileURLWithPath: "")
    var date = ""
    var isPlaying = false
    var isMerging = false
    
    var recordingsUrl: URL?
    
    @IBOutlet weak var playAllBtn: UIButton!
    @IBOutlet weak var shareAllBtn: UIButton!
    @IBOutlet weak var sectionNameLbl: UILabel!
    @IBOutlet weak var hideSectionBtn: UIButton!
    @IBOutlet weak var mergingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var seekerView: UIView!
    @IBOutlet weak var headerCurrentPlayTimeLbl: UILabel!
    @IBOutlet weak var headerPlayingSeeker: UISlider!
    @IBOutlet weak var totalPlayTimeLbl: UILabel!
    
    @IBOutlet weak var sectionSeperator: UIView!
    
    private var headerPlayBackTimer: Timer?
    
    
    func configureCell(date:String) {
        
        sectionNameLbl.text = date
        self.date = date
        configureCell()
    }
    private func configureCell() {
        addTapGestureToHeader()
        isMerging = checkIfMerging(audioFileUrls: (delegate?.getAudioFilesList(date: date))!)
        if  isMerging{
            mergingActivityIndicator.startAnimating()
        } else {
            mergingActivityIndicator.stopAnimating()
        }
        
        updatePlayingState()
        isMerging = checkIfMerging()
        setBtnImage()
        setBtnProperty()
        configureHeaderPlayBackSeeker()
    }
    
    @IBAction func startPulsing(_ sender: UIButton) {
        logger.info("Starting pulsing in section header")
        let pulse = Pulsing(numberOfPulses: 1, diameter: sender.layer.bounds.width, position: CGPoint(x:sender.layer.bounds.width/2,y: sender.layer.bounds.height/2))
        sender.layer.addSublayer(pulse)
    }
    
    func addTapGestureToHeader() {
        logger.info("Adding tap gesture to header")
        let tapToggleGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection))
        tapToggleGesture.numberOfTapsRequired = 1
        sectionNameLbl.isUserInteractionEnabled = true
        sectionNameLbl.addGestureRecognizer(tapToggleGesture)
    }
    
    @objc func toggleSection() {
        logger.event("Toggle selection of section with date \(date)")
        Analytics.logEvent(AnalyticsEvent.ToggleSection.rawValue, parameters: [StringAnalyticsProperties.ToggleSectionFrom.rawValue : ToggleSectionFrom.Label.rawValue as NSObject])
        delegate?.toggleSection(date: date)
    }
    
    func setBtnImage() {
        logger.info("Setting button images for recordings section header")
        
        if isPlaying {
            setButtonBgImage(button: playAllBtn, bgImage: pauseBtnIcon, tintColor: enabledGray)
        } else {
            setButtonBgImage(button: playAllBtn, bgImage: playBtnIcon, tintColor: enabledGray)
        }
        
        if isMerging {
            playAllBtn.imageView?.tintColor = disabledGray
            setButtonBgImage(button: shareAllBtn, bgImage: shareIcon , tintColor: disabledGray)
        } else {
            playAllBtn.imageView?.tintColor = enabledGray
            setButtonBgImage(button: shareAllBtn, bgImage: shareIcon , tintColor: enabledGray)
        }
        
        if ((delegate?.checkIfHidden(date: date))!) {
            setButtonBgImage(button: hideSectionBtn, bgImage: plusIcon, tintColor: enabledGray)
        } else {
            setButtonBgImage(button: hideSectionBtn, bgImage: minusIcon, tintColor: enabledGray)
        }
    }
    
    func setBtnProperty() {
        logger.info("Setting button properties for recordings section header")
        
        setBtnPropWithCutomOffset(button: playAllBtn, offset: 0)
        setBtnPropWithCutomOffset(button: shareAllBtn, offset: 0)
        
        if ((delegate?.checkIfHidden(date: date))!) {
            setBtnPropWithCutomOffset(button: hideSectionBtn, offset: 2)
        } else {
            setBtnPropWithCutomOffset(button: hideSectionBtn, offset: 5)
        }
    }
    
    
    func setBtnPropWithCutomOffset(button: UIButton,offset: CGFloat) {
        logger.info("Setting button properties for recordings section header")
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(buttonVerticalInset, buttonHorizontalInset + offset, buttonVerticalInset, buttonHorizontalInset + offset)
    }
    
    ///Check if contents of this section are playing
    func updatePlayingState() {
        logger.info("Updating playing state for recordings header")
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: date)
    }
    
    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        logger.event("Tapped share recordings from section header")
        
        var count = 0
        if let _ = delegate?.getAudioFilesList(date: date).count  {
            count = (delegate?.getAudioFilesList(date: date).count)!
        }
        
        Analytics.logEvent(AnalyticsEvent.ShareRecordings.rawValue, parameters: [StringAnalyticsProperties.RecordingsType.rawValue : RecordingsType.Section.rawValue as NSObject, IntegerAnalyticsPropertites.NumberOfTopics.rawValue : count as NSObject])
        
        if (delegate?.checkIfRecordingIsOn())! || checkIfMerging() {
            return
        }
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator) {
            openShareSheet(url: getMergedFileUrl(), activityIndicator: self.mergingActivityIndicator, completion: {})
        }
    }
    
    @IBAction func playRecordingTapped(_ sender: UIButton) {
        logger.event("Tapped play recordings from section header")
        
        var count = 0
        if let _ = delegate?.getAudioFilesList(date: date).count  {
            count = (delegate?.getAudioFilesList(date: date).count)!
        }
        
        Analytics.logEvent(AnalyticsEvent.PlayRecordings.rawValue, parameters: [StringAnalyticsProperties.RecordingsType.rawValue : RecordingsType.Section.rawValue as NSObject, IntegerAnalyticsPropertites.NumberOfTopics.rawValue : count as NSObject])
        
        if (delegate?.checkIfRecordingIsOn())! || checkIfMerging() {
            return
        }
        //        delegate?.reloadData()
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator){
            
            self.recordingsUrl = getMergedFileUrl()
            CentralAudioPlayer.player.playRecording(url: getMergedFileUrl(), id: self.date)
            self.delegate?.reloadData()
        }
    }
    
    @IBAction func toggleSectionTapped(_ sender: UIButton) {
        logger.event("Toggled recordings section header")
        
        Analytics.logEvent(AnalyticsEvent.ToggleSection.rawValue, parameters: [StringAnalyticsProperties.ToggleSectionFrom.rawValue : ToggleSectionFrom.Button.rawValue as NSObject])
        toggleSection()
    }
    
}

//MARK :- Playback Seeker
extension SectionHeader {
    
    func configureHeaderPlayBackSeeker() {
        logger.info("Configuring playback seeker for recordings header for date \(date)")
        
        if isPlaying {
            
            seekerView.isHidden = false
            headerPlayingSeeker.setThumbImage(drawSliderThumb(diameter: normalThumbDiameter, backgroundColor: UIColor.white), for: .normal)
            headerPlayingSeeker.setThumbImage(drawSliderThumb(diameter: highlightedThumbDiameter, backgroundColor: accentColor), for: .highlighted)
            
            let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
            let totalTime = CentralAudioPlayer.player.getPlayBackDuration();
            
            headerPlayingSeeker.maximumValue = Float(totalTime)
            headerPlayingSeeker.minimumValue = Float(0.0)
            headerPlayingSeeker.value = Float(currentTime)
            headerCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
            totalPlayTimeLbl.text = convertToMins(seconds: totalTime)
            
            headerPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        } else {
            seekerView.isHidden = true
        }
    }
    
    @objc func updatePlaybackTime(timer: Timer) {
        logger.info("Updating playback time for recordings header for date \(date)")
        
        let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
        headerCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
        headerPlayingSeeker.value = Float(currentTime)
        updatePlayingState()
        if !isPlaying {
            timer.invalidate()
            delegate?.reloadData()
        }
    }
    
    ///On slider touchdown invalidate the update timer
    @IBAction func headerStopPlaybackUIUpdate(_ sender: UISlider) {
        logger.event("Updating recordings header playback ui for date \(date) on seeker touch down")
        headerPlayBackTimer?.invalidate()
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On value change play to new time
    @IBAction func headerUpdatePlaybackTimeWithSlider(_ sender: UISlider) {
        logger.event("Updating recordings header playback ui for date \(date) on seeker slide")
        let playbackTime = Double(sender.value)
        headerCurrentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
        CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func headerStartPlaybackUIUpdate(_ sender: UISlider) {
        logger.event("Updating recordings header playback ui for date \(date) on seeker touch up")
        headerPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        sender.minimumTrackTintColor = UIColor.white
    }
    
    func disableTimer() {
        logger.event("Disabling playback timer for recordings header for date \(date)")
        headerPlayBackTimer?.invalidate()
        headerPlayBackTimer = nil
    }
}
