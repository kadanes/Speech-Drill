//
//  RecordingCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 02/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingCell: UITableViewCell {
    
    @IBOutlet weak var recordingNameLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: RoundButton!
    
    @IBOutlet weak var deleteRecordingBtn: RoundButton!
    @IBOutlet weak var shareRecordingBtn: RoundButton!
    @IBOutlet weak var playRecordningBtn: RoundButton!

    @IBOutlet weak var confirmDeleteBtn: RoundButton!
    
    @IBOutlet weak var cancelDeleteBtn: RoundButton!
    
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    @IBOutlet weak var seekerView: UIView!
    @IBOutlet weak var currentPlayTimeLbl: UILabel!
    @IBOutlet weak var playingSeeker: UISlider!
    @IBOutlet weak var totalPlayTimeLbl: UILabel!
    
    weak var delegate: MainVC?

    var topicNumber = 0
    var timeStamp = 0
    var thinkTime = 15

    var isRecordningSelected = false
    var recordingURL: URL?
    var isPlaying = false
    var isMerging = false
    
    private var recordingPlayBackTimer: Timer?
    
    func configureCell(url:URL) {
        
        self.recordingURL = url
        getFileDetails()
        updatePlayingState()

        setTopicLblTxt()
        isMerging = checkIfMerging()
        setBtnImage()
        setBtnProperty()
        hideDeleteMenu()
        configureRecordingPlayBackSeeker()
        
    }
    
    
    @IBAction func startPulsing(_ sender: UIButton) {
        let pulse = Pulsing(numberOfPulses: 1, diameter: sender.layer.bounds.width, position: CGPoint(x:sender.layer.bounds.width/2,y: sender.layer.bounds.height/2))
        sender.layer.addSublayer(pulse)
    }
    
    
    ///Set topic label to topic number or speaking topic type
    func setTopicLblTxt() {
        if topicNumber != testModeId  {
            recordingNameLbl.text = "Topic \(topicNumber)"
        } else {
            var labelText = ""
            switch thinkTime {
            case 15:
                labelText = "Independent"
            case 20:
                labelText = "Integrated B"
            case 30:
                labelText = "Integrated A"
            default:
                labelText = "NA"
            }
            recordingNameLbl.text = labelText
        }
    }
    
    func setBtnImage() {
        
        let date = parseDate(timeStamp: timeStamp)
        let isRecordingUsedInMerging = checkIfMerging(date: date)
        
        if isRecordingUsedInMerging {
             setButtonBgImage(button: deleteRecordingBtn, bgImage: deleteIcon, tintColor: disabledRed)
        } else {
             setButtonBgImage(button: deleteRecordingBtn, bgImage: deleteIcon, tintColor: enabledRed)
        }
        
        if isPlaying {
            setButtonBgImage(button: playPauseBtn, bgImage: pauseBtnIcon, tintColor: enabledGray)
        } else {
            setButtonBgImage(button: playPauseBtn, bgImage: playBtnIcon, tintColor: enabledGray)
        }
        
        if isMerging {
            setButtonBgImage(button: shareRecordingBtn, bgImage: singleShareIcon, tintColor: disabledGray)
        } else {
            setButtonBgImage(button: shareRecordingBtn, bgImage: singleShareIcon, tintColor: enabledGray)
        }
        
        setButtonBgImage(button: confirmDeleteBtn, bgImage: checkIcon, tintColor: confirmGreen)
        setButtonBgImage(button: cancelDeleteBtn, bgImage: closeIcon, tintColor: confirmGreen)
        
    }
    
    func setBtnProperty() {
        setBtnImgProp(button: deleteRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: shareRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: playRecordningBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: confirmDeleteBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: cancelDeleteBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset+5)
        
        if let checkBoxBg = checkBoxBtn.subviews.first as? UIImageView {
            checkBoxBg.contentMode = .scaleAspectFit
        }
    }

    func selectCheckBox() {
        isRecordningSelected = true
        setButtonBgImage(button: checkBoxBtn, bgImage: checkIcon, tintColor: accentColor)
    }
    
    func deselectCheckBox() {
        isRecordningSelected = false
        checkBoxBtn.setImage(nil, for: .normal)
    }
    
    ///Split file name and store its timestamp,topic number and think time
    func getFileDetails() {
        (timeStamp,topicNumber,thinkTime) = splitFileURL(url: recordingURL!)
    }
    
    func updatePlayingState() {
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: "\(timeStamp)")
    }
    
    @IBAction func shareRecordingPressed(_ sender: Any) {
        
        if (delegate?.checkIfRecordingIsOn())! || isMerging { return }
        
        CentralAudioPlayer.player.stopPlaying()
        openShareSheet(url: recordingURL!, activityIndicator: nil, completion:{})
    }
    
    @IBAction func playRecording(_ sender: UIButton) {
        if (delegate?.checkIfRecordingIsOn())! {
            return
        }
        
        if let url = recordingURL {
            if topicNumber == testModeId {
                delegate?.setToTestMode()
            } else {
                delegate?.setToPracticeMode()
                delegate?.renderTopic(topicNumber: topicNumber)
            }
            
            CentralAudioPlayer.player.playRecording(url: url, id: "\(timeStamp)")
            
            //delegate?.reloadData()
            delegate?.reloadRow(url: recordingURL!)
//            var previousPlayingId = CentralAudioPlayer.player.getPlayingRecordingId()
//
//
//
//            if previousPlayingId == "" {
//
//                delegate?.reloadRow(url: recordingURL!)
//                return
//            }
//
//            if previousPlayingId != selectedAudioId || checkIfDate(date: previousPlayingId) {
//               previousPlayingId = CentralAudioPlayer.player.getPlayingRecordingUrl()
//            }
//            delegate?.togglePlayIconsFor(previouslyPlayingId: previousPlayingId, nowPlayingId: "\(recordingURL!)")
        }
    }
    
    func configureRecordingPlayBackSeeker() {
        if isPlaying {
            seekerView.isHidden = false
            playingSeeker.setThumbImage(drawSliderThumb(diameter: normalThumbDiameter, backgroundColor: UIColor.white), for: .normal)
            playingSeeker.setThumbImage(drawSliderThumb(diameter: highlightedThumbDiameter, backgroundColor: accentColor), for: .highlighted)
    
            let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime()
            let totalTime = CentralAudioPlayer.player.getPlayBackDuration()
            
            playingSeeker.maximumValue = Float(totalTime)
            playingSeeker.minimumValue = Float(0.0)
            playingSeeker.value = Float(currentTime)
            currentPlayTimeLbl.text = convertToMins(seconds: currentTime)
            totalPlayTimeLbl.text = convertToMins(seconds: totalTime)
            
            recordingPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        } else {
             seekerView.isHidden = true
        }
    }
    
    @objc func updatePlaybackTime(timer: Timer) {
        let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
        currentPlayTimeLbl.text = convertToMins(seconds: currentTime)
        playingSeeker.value = Float(currentTime)
        updatePlayingState()
        if !isPlaying {
            timer.invalidate()
//            delegate?.reloadData()
            delegate?.reloadRow(url: recordingURL!)
        }
    }
    
    ///On slider touchdown invalidate the update timer
    @IBAction func stopPlaybackUIUpdate(_ sender: UISlider) {
        recordingPlayBackTimer?.invalidate()
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On value change play to new time
    @IBAction func updatePlaybackTimeWithSlider(_ sender: UISlider) {
        let playbackTime = Double(sender.value)
        currentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
        CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func startPlaybackUIUpdate(_ sender: UISlider) {
        recordingPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        sender.minimumTrackTintColor = UIColor.white
    }
    
    func showDeleteMenu() {
        
//        UIView.animate(withDuration: 0.3) {
//
//            self.deleteRecordingBtn.imageView?.tintColor = disabledRed
//            self.confirmDeleteBtn.isHidden = false
//            self.cancelDeleteBtn.isHidden = false
//            self.playPauseBtn.isHidden = true
//            self.shareRecordingBtn.isHidden = true
//        }
        
        UIView.animate(withDuration: 0.15, animations: {
            self.playPauseBtn.isHidden = true
            
            self.confirmDeleteBtn.isHidden = false
        }) { (completed) in
            if completed {
                UIView.animate(withDuration: 0.15, animations: {
                    self.shareRecordingBtn.isHidden = true
                    self.cancelDeleteBtn.isHidden = false
                    self.deleteRecordingBtn.imageView?.tintColor = enabledRed
                    
                })
            }
        }
    }

    func hideDeleteMenu() {
        self.playPauseBtn.isHidden = false
        self.cancelDeleteBtn.isHidden = true
        self.shareRecordingBtn.isHidden = false
        self.deleteRecordingBtn.imageView?.tintColor = enabledRed
        self.confirmDeleteBtn.isHidden = true
    }
    func hideDeleteMenuAnimated() {
        
        UIView.animate(withDuration: 0.15, animations: {
            
            self.shareRecordingBtn.isHidden = false
            self.cancelDeleteBtn.isHidden = true

        }) { (completed) in
            if completed {
                UIView.animate(withDuration: 0.15, animations: {
                    self.confirmDeleteBtn.isHidden = true
                    self.playPauseBtn.isHidden = false
                    self.deleteRecordingBtn.imageView?.tintColor = enabledRed
                })
            }
        }
    }
    
    @IBAction func deleteRecording(_ sender: Any) {
        showDeleteMenu()
    }
    
    @IBAction func confirmDelete(_ sender: Any) {
        let date = parseDate(timeStamp: timeStamp)
        let isRecordingUsedInMerging = checkIfMerging(date: date)
        if isRecordingUsedInMerging { return }
        
        CentralAudioPlayer.player.stopPlaying()
        if let url = recordingURL {
            let deleted = deleteStoredRecording(recordingURL: url)
            if deleted == .Success {
                delegate?.deleteRow(with: url)
            }
        }
    }
    
    @IBAction func cancelDelete(_ sender: Any) {
        hideDeleteMenuAnimated()
    }
    
    @IBAction func selectRecordingTapped(_ sender: UIButton) {
        if !(isRecordningSelected) {
            setButtonBgImage(button: sender, bgImage: checkIcon, tintColor: accentColor)
            delegate?.addToExportList(url: recordingURL!)
        } else {
            setButtonBgImage(button: sender, bgImage: UIImage(), tintColor: .clear)
            delegate?.removeFromExportList(url: recordingURL!)
        }
        isRecordningSelected = !isRecordningSelected
    }
    
    func disableTimer() {
        recordingPlayBackTimer?.invalidate()
        recordingPlayBackTimer = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
