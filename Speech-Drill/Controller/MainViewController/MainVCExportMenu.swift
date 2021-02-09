//
//  MainVCExportMenu.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics

//MARK:- Export Menu
extension MainVC {
    
    ///Show or Hide export menu
    func toggleExportMenu() {
        logger.info()
        if recordingUrlsListToExport.count > 0 {
            DispatchQueue.main.async {
                self.exportMenuStackView.isHidden = false
                self.exportSelectedBtn.setTitle("Export \(self.recordingUrlsListToExport.count) recording(s)", for: .normal)
                self.toggleSeeker()
            }
        } else {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = true
                self.exportMenuStackView.isHidden = true
            }
        }
    }
    
    func toggleSeeker() {
        logger.info()
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: selectedAudioId)
        if isPlaying {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = false
            }
            configureExportMenuPlayBackSeeker()
            setButtonBgImage(button: playSelectedBtn, bgImage: pauseBtnIcon, tintColor: accentColor)
        } else {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = true
            }
            setButtonBgImage(button: playSelectedBtn, bgImage: playBtnIcon, tintColor: accentColor)
            if let _ = exportPlayBackTimer {
                exportPlayBackTimer?.invalidate()
                exportPlayBackTimer = nil
            }
        }
    }
    
    ///Add a recording url to list of recordings to export
    func addToExportList(url: URL) {
        logger.info()
        CentralAudioPlayer.player.stopPlaying()
        recordingUrlsListToExport.append(url)
        toggleExportMenu()
    }
    
    ///Remove a recording url to list of recordings to export
    func removeFromExportList(url: URL) {
        logger.info()
        CentralAudioPlayer.player.stopPlaying()
        recordingUrlsListToExport = recordingUrlsListToExport.filter {$0 != url}
        toggleExportMenu()
    }
    
    ///Remove all selected recordings and reset UI
    func clearSelected() {
        logger.info()
        recordingUrlsListToExport.removeAll()
        toggleExportMenu()
        reloadData()
    }
    
    ///Export selected recordings
    @IBAction func exportSelectedTapped(_ sender: UIButton) {
        logger.info()
        Analytics.logEvent(AnalyticsEvent.ShareRecordings.rawValue, parameters: [StringAnalyticsProperties.RecordingsType.rawValue : RecordingsType.Selected.rawValue as NSObject, IntegerAnalyticsPropertites.NumberOfTopics.rawValue : recordingUrlsListToExport.count as NSObject])
        
        if checkIfRecordingIsOn() || checkIfMerging() {
            return
        }
        
        processMultipleRecordings(recordingsList: recordingUrlsListToExport, activityIndicator: exportSelectedActivityIndicator) {
            CentralAudioPlayer.player.stopPlaying()
            openShareSheet(url: getMergedFileUrl(), activityIndicator: self.exportSelectedActivityIndicator){
                self.clearSelected()
            }
        }
    }
    
    ///Play selected recordings
    @IBAction func playSelectedAudioTapped(_ sender: UIButton) {
        logger.info()
        Analytics.logEvent(AnalyticsEvent.PlayRecordings.rawValue, parameters: [StringAnalyticsProperties.RecordingsType.rawValue : RecordingsType.Selected.rawValue as NSObject, IntegerAnalyticsPropertites.NumberOfTopics.rawValue : recordingUrlsListToExport.count as NSObject])
        
        if checkIfRecordingIsOn() || checkIfMerging() { return }
        
        processMultipleRecordings(recordingsList: recordingUrlsListToExport, activityIndicator: playSelectedActivityIndicator) {
            
            DispatchQueue.main.async {
                self.playSelectedActivityIndicator.stopAnimating()
            }
            
            CentralAudioPlayer.player.playRecording(url: getMergedFileUrl(), id: selectedAudioId)
            self.isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: selectedAudioId)
            if (self.isPlaying) {
                setButtonBgImage(button: sender, bgImage: pauseBtnIcon, tintColor: accentColor)
            } else {
                setButtonBgImage(button: sender, bgImage: playBtnIcon, tintColor: accentColor)
            }
            self.toggleSeeker()
        }
    }
    
    ///Hide export menu
    @IBAction func cancelSelectedTapped(_ sender: UIButton) {
        logger.info()
        CentralAudioPlayer.player.stopPlaying()
        clearSelected()
    }
    
    ///Set properties of playback seeker view
    func configureExportMenuPlayBackSeeker() {
        logger.info()
        if isPlaying {
            
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = false
                self.exportPlayingSeeker.setThumbImage(drawSliderThumb(diameter: normalThumbDiameter, backgroundColor: UIColor.white), for: .normal)
                self.exportPlayingSeeker.setThumbImage(drawSliderThumb(diameter: highlightedThumbDiameter, backgroundColor: accentColor), for: .highlighted)
                
                let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
                let totalTime = CentralAudioPlayer.player.getPlayBackDuration();
                
                self.exportPlayingSeeker.maximumValue = Float(totalTime)
                self.exportPlayingSeeker.minimumValue = Float(0.0)
                self.exportPlayingSeeker.value = Float(currentTime)
                self.exportCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
                self.totalPlayTimeLbl.text = convertToMins(seconds: totalTime)
                
                self.exportPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateExportPlaybackTime), userInfo: nil, repeats: true)
            }
        } else {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = true
            }
        }
    }
    
    @objc func updateExportPlaybackTime(timer: Timer) {
        logger.info()
        if !CentralAudioPlayer.player.checkIfPlaying(id: selectedAudioId) {
            timer.invalidate()
            toggleSeeker()
        }
        let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
        
        DispatchQueue.main.async {
            self.exportCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
            self.exportPlayingSeeker.value = Float(currentTime)
        }
    }
    
    ///On slider touchdown invalidate the update timer
    @IBAction func headerStopPlaybackUIUpdate(_ sender: UISlider) {
        logger.info()
        exportPlayBackTimer?.invalidate()
        exportPlayBackTimer = nil
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On value change play to new time
    @IBAction func headerUpdatePlaybackTimeWithSlider(_ sender: UISlider) {
        logger.info()
        let playbackTime = Double(sender.value)
        DispatchQueue.main.async {
            self.exportCurrentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
            CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
            sender.minimumTrackTintColor = accentColor
        }
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func headerStartPlaybackUIUpdate(_ sender: UISlider) {
        logger.info()
        exportPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateExportPlaybackTime), userInfo: nil, repeats: true)
        DispatchQueue.main.async {
            sender.minimumTrackTintColor = UIColor.white
        }
    }
}
