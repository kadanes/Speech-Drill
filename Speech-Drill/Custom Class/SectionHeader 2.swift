//
//  SectionHeaderXIB.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 08/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

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
        let pulse = Pulsing(numberOfPulses: 1, diameter: sender.layer.bounds.width, position: CGPoint(x:sender.layer.bounds.width/2,y: sender.layer.bounds.height/2))
        sender.layer.addSublayer(pulse)
    }
    
    func addTapGestureToHeader() {
        let tapToggleGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection))
        tapToggleGesture.numberOfTapsRequired = 1
        sectionNameLbl.isUserInteractionEnabled = true
        sectionNameLbl.addGestureRecognizer(tapToggleGesture)
    }
    
    @objc func toggleSection() {
        delegate?.toggleSection(date: date)
    }
    
    func setBtnImage() {
        
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
        setBtnPropWithCutomOffset(button: playAllBtn, offset: 0)
        setBtnPropWithCutomOffset(button: shareAllBtn, offset: 0)
        
        if ((delegate?.checkIfHidden(date: date))!) {
            setBtnPropWithCutomOffset(button: hideSectionBtn, offset: 2)
        } else {
            setBtnPropWithCutomOffset(button: hideSectionBtn, offset: 5)
        }
    }
    
    
    func setBtnPropWithCutomOffset(button: UIButton,offset: CGFloat) {
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(buttonVerticalInset, buttonHorizontalInset + offset, buttonVerticalInset, buttonHorizontalInset + offset)
    }
    
    ///Check if contents of this section are playing
    func updatePlayingState() {
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: date)
    }
    
    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        if (delegate?.checkIfRecordingIsOn())! || checkIfMerging() {
            return
        }
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator) {
            openShareSheet(url: getMergedFileUrl(), activityIndicator: self.mergingActivityIndicator, completion: {})
        }
    }
    
    @IBAction func playRecordingTapped(_ sender: UIButton) {
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
        toggleSection()
    }
   
}


 //MARK :- Playback Seeker
extension SectionHeader {

    func configureHeaderPlayBackSeeker() {
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
        headerPlayBackTimer?.invalidate()
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On value change play to new time
    @IBAction func headerUpdatePlaybackTimeWithSlider(_ sender: UISlider) {
        let playbackTime = Double(sender.value)
        headerCurrentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
        CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func headerStartPlaybackUIUpdate(_ sender: UISlider) {
        headerPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        sender.minimumTrackTintColor = UIColor.white
    }
    
    func disableTimer() {
        headerPlayBackTimer?.invalidate()
        headerPlayBackTimer = nil
    }
}
