//
//  SectionHeaderCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 03/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation
class SectionHeaderCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: MainVC?

    var url = URL(fileURLWithPath: "")
    var date = ""
    var isPlaying = false
    
    var recordingsURL: URL?
    
    @IBOutlet weak var playAllBtn: UIButton!
    @IBOutlet weak var shareAllBtn: UIButton!
    @IBOutlet weak var sectionNameLbl: UILabel!
    @IBOutlet weak var hideSectionBtn: UIButton!
    @IBOutlet weak var mergingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var seekerView: UIView!
    @IBOutlet weak var headerCurrentPlayTimeLbl: UILabel!
    @IBOutlet weak var headerPlayingSeeker: UISlider!
    @IBOutlet weak var totalPlayTimeLbl: UILabel!
    
    private var playBackTimer: Timer?

    func setButtonImageProperties(button: UIButton,offset: CGFloat) {
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(buttonVerticalInset, buttonHorizontalInset + offset, buttonVerticalInset, buttonHorizontalInset + offset)
    }

    func updatePlayingState() {
        
        if let url = recordingsURL {
           isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: url, id: date)
        } else {
            
            let recordedURLS = sortUrlList(recordingsURLList: (delegate?.getAudioFilesList(date: date))!)

            if recordedURLS.count > 1 {
                
                recordingsURL = getMergedFileURL()
                
            isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: getMergedFileURL(), id: date)
                
            } else if recordedURLS.count == 1 {
                recordingsURL = recordedURLS[0]
                
                isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: recordedURLS[0], id: date)

            }
        }
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        if mergingActivityIndicator.isAnimating {
            return
        }
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator) { (shareURL) in
            
            openShareSheet(url: shareURL, activityIndicator: self.mergingActivityIndicator, completion: {})
        }
    }
    
    @IBAction func playRecordingTapped(_ sender: UIButton) {
        if mergingActivityIndicator.isAnimating {
            return
        }
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator){ (playURL) in
            
            self.recordingsURL = playURL
            
            self.updatePlayingState()
            
            if (self.delegate?.isRecording)! {
                return
            }
            CentralAudioPlayer.player.playRecording(url: playURL, id: self.date)
            DispatchQueue.main.async {
                self.mergingActivityIndicator.stopAnimating()
            }
            self.delegate?.reloadData()
        }
    }

    func configureCell(date:String) {
        sectionNameLbl.text = date
        self.date = date

        setButtonImageProperties(button: playAllBtn, offset: 0)
        setButtonImageProperties(button: shareAllBtn, offset: 0)
        mergingActivityIndicator.stopAnimating()

        updatePlayingState()
        updateToggleBtnIcon()
        configurePlayBackSeeker()
        
        if isPlaying {
            setButtonBgImage(button: playAllBtn, bgImage: pauseBtnIcon)
        } else {
            setButtonBgImage(button: playAllBtn, bgImage: playBtnIcon)
        }
    }
    
    @IBAction func toggleSection(_ sender: UIButton) {
        delegate?.toggleSection(date: date)
        updateToggleBtnIcon()
    }
    
    func updateToggleBtnIcon() {
        
        if ((delegate?.checkIfHidden(date: date))!) {
             hideSectionBtn.setImage(plusIcon, for: .normal)
            setButtonImageProperties(button: hideSectionBtn, offset: 2)
        } else {
            hideSectionBtn.setImage(minusIcon, for: .normal)
            setButtonImageProperties(button: hideSectionBtn, offset: 5)
        }
    }
    
    
    //MARK :- Playback Seeker
    func configurePlayBackSeeker() {
        if isPlaying {
            seekerView.isHidden = false
            headerPlayingSeeker.setThumbImage(drawSliderThumb(diameter: 15, backgroundColor: UIColor.white), for: .normal)
            headerPlayingSeeker.setThumbImage(drawSliderThumb(diameter: 25, backgroundColor: UIColor.yellow), for: .highlighted)
            
            let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
            let totalTime = CentralAudioPlayer.player.getPlayBackDuration();
            
            headerPlayingSeeker.maximumValue = Float(totalTime)
            headerPlayingSeeker.minimumValue = Float(0.0)
            headerPlayingSeeker.value = Float(currentTime)
            headerCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
            totalPlayTimeLbl.text = convertToMins(seconds: totalTime)
            
            playBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
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
        playBackTimer?.invalidate()
        sender.minimumTrackTintColor = UIColor.yellow
    }
    
    ///On value change play to new time
    @IBAction func headerUpdatePlaybackTimeWithSlider(_ sender: UISlider) {
        let playbackTime = Double(sender.value)
        headerCurrentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
        CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
        sender.minimumTrackTintColor = UIColor.yellow
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func headerStartPlaybackUIUpdate(_ sender: UISlider) {
        playBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        sender.minimumTrackTintColor = UIColor.white
    }
    
    func disableTimer() {
        playBackTimer?.invalidate()
        playBackTimer = nil
    }
}
