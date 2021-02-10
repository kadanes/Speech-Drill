//
//  RecordingCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 02/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Speech

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
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        checkBoxBtn.setImage(boxIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        checkBoxBtn.imageView?.tintColor = .white
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
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
    
    //    fileprivate func transcribeFile() {
    //
    //        // 1
    //        guard let recognizer = SFSpeechRecognizer() else {
    //            print("Speech recognition not available for specified locale")
    //            return
    //        }
    //
    //        if !recognizer.isAvailable {
    //            print("Speech recognition not currently available")
    //            return
    //        }
    //
    //        // 2
    //        let request = SFSpeechURLRecognitionRequest(url: recordingURL!)
    //
    //        // 3
    //        recognizer.recognitionTask(with: request) {
    //            [unowned self] (result, error) in
    //            guard let result = result else {
    //                print("There was an error transcribing that file")
    //                return
    //            }
    //
    //            // 4
    //            if result.isFinal {
    //                print(result.bestTranscription.formattedString)
    //            }
    //        }
    //    }
    
    //    @IBAction func transcribeRecording(_ sender: Any) {
    //        SFSpeechRecognizer.requestAuthorization {
    //            [unowned self] (authStatus) in
    //            switch authStatus {
    //            case .authorized:
    //                self.transcribeFile()
    //            case .denied:
    //                print("Speech recognition authorization denied")
    //            case .restricted:
    //                print("Not available on this device")
    //            case .notDetermined:
    //                print("Not determined")
    //            }
    //        }
    //    }
    
    
    @IBAction func startPulsing(_ sender: UIButton) {
        logger.info("Pulsing recording cell button")
        
        let pulse = Pulsing(numberOfPulses: 1, diameter: sender.layer.bounds.width, position: CGPoint(x:sender.layer.bounds.width/2,y: sender.layer.bounds.height/2))
        sender.layer.addSublayer(pulse)
    }
    
    
    ///Set topic label to topic number or speaking topic type
    func setTopicLblTxt() {
        logger.info("Setting recording name based on recording type")
        
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
        logger.info("Setting button images")
        
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
            //            setButtonBgImage(button: shareRecordingBtn, bgImage: singleShareIcon, tintColor: disabledGray)
            setButtonBgImage(button: shareRecordingBtn, bgImage: shareIcon, tintColor: disabledGray)
        } else {
            //            setButtonBgImage(button: shareRecordingBtn, bgImage: singleShareIcon, tintColor: enabledGray)
            setButtonBgImage(button: shareRecordingBtn, bgImage: shareIcon, tintColor: enabledGray)
        }
        
        setButtonBgImage(button: confirmDeleteBtn, bgImage: checkIcon, tintColor: confirmGreen)
        setButtonBgImage(button: cancelDeleteBtn, bgImage: closeIcon, tintColor: confirmGreen)        
        checkBoxBtn.setBackgroundImage(boxIcon, for: .normal)
    }
    
    func setBtnProperty() {
        logger.info("Setting button properties")
        
        setBtnImgProp(button: deleteRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: shareRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: playRecordningBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: confirmDeleteBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: cancelDeleteBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset+5)
    }
    
    func selectCheckBox() {
        logger.event("Selecting check box")
        
        isRecordningSelected = true
        setButtonBgImage(button: checkBoxBtn, bgImage: checkIcon, tintColor: accentColor)
    }
    
    func deselectCheckBox() {
        logger.event("Deselecting check box")
        
        isRecordningSelected = false
        checkBoxBtn.setImage(nil, for: .normal)
    }
    
    ///Split file name and store its timestamp,topic number and think time
    func getFileDetails() {
        logger.info("Getting file details for recording url: \(String(describing: recordingURL))")
        (timeStamp,topicNumber,thinkTime) = splitFileURL(url: recordingURL!)
    }
    
    func updatePlayingState() {
        logger.info("Updating playing state of recording at \(timeStamp)")
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: "\(timeStamp)")
    }
    
    @IBAction func shareRecordingPressed(_ sender: Any) {
        logger.event("Share recording tapped")
        
        Analytics.logEvent(AnalyticsEvent.ShareRecordings.rawValue, parameters: [StringAnalyticsProperties.RecordingsType.rawValue : RecordingsType.Single.rawValue as NSObject, IntegerAnalyticsPropertites.NumberOfTopics.rawValue : 1 as NSObject])
        
        if (delegate?.checkIfRecordingIsOn())! || isMerging { return }
        
        CentralAudioPlayer.player.stopPlaying()
        openShareSheet(url: recordingURL!, activityIndicator: nil, completion:{})
    }
    
    @IBAction func playRecording(_ sender: UIButton) {
        logger.event("Play recording tapped")
        
        Analytics.logEvent(AnalyticsEvent.PlayRecordings.rawValue, parameters: [StringAnalyticsProperties.RecordingsType.rawValue : RecordingsType.Single.rawValue as NSObject, IntegerAnalyticsPropertites.NumberOfTopics.rawValue : 1 as NSObject])
        
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
            delegate?.reloadRow(url: recordingURL!)
        }
    }
    
    func configureRecordingPlayBackSeeker() {
        logger.info("Configuring playback seeker icon")
        
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
        logger.debug("Updating playback time")
        
        let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
        currentPlayTimeLbl.text = convertToMins(seconds: currentTime)
        playingSeeker.value = Float(currentTime)
        updatePlayingState()
        if !isPlaying {
            timer.invalidate()
            delegate?.reloadRow(url: recordingURL!)
        }
    }
    
    ///On slider touchdown invalidate the update timer
    @IBAction func stopPlaybackUIUpdate(_ sender: UISlider) {
        logger.event("Stopping playback for recording \(String(describing: recordingURL))")
        recordingPlayBackTimer?.invalidate()
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On value change play to new time
    @IBAction func updatePlaybackTimeWithSlider(_ sender: UISlider) {
        logger.event("Updating playback time using seeker")
        let playbackTime = Double(sender.value)
        currentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
        CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
        sender.minimumTrackTintColor = accentColor
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func startPlaybackUIUpdate(_ sender: UISlider) {
        logger.event("Starting playback ui updates")
        recordingPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        sender.minimumTrackTintColor = UIColor.white
    }
    
    func showDeleteMenu() {
        logger.event("Presenting delete menu for recoridng \(String(describing: recordingURL))")
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
        logger.event("Hiding delete menu for recoridng \(String(describing: recordingURL))")
        self.playPauseBtn.isHidden = false
        self.cancelDeleteBtn.isHidden = true
        self.shareRecordingBtn.isHidden = false
        self.deleteRecordingBtn.imageView?.tintColor = enabledRed
        self.confirmDeleteBtn.isHidden = true
    }
    
    func hideDeleteMenuAnimated() {
        logger.event("Hiding delete menu with animation for recoridng \(String(describing: recordingURL))")
        
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
        logger.event("Delete recording tapped for recording \(String(describing: recordingURL))")
        Analytics.logEvent(AnalyticsEvent.ShowDeleteMenu.rawValue, parameters: nil)
        showDeleteMenu()
    }
    
    @IBAction func confirmDelete(_ sender: Any) {
        logger.event("Confirm delete tapped for recording \(String(describing: recordingURL))")
        Analytics.logEvent(AnalyticsEvent.ConfirmDelete.rawValue, parameters: nil)
        let date = parseDate(timeStamp: timeStamp)
        let isRecordingUsedInMerging = checkIfMerging(date: date)
        if isRecordingUsedInMerging { return }
        
        CentralAudioPlayer.player.stopPlaying()
        if let url = recordingURL {
            let deleted = deleteStoredRecording(recordingURL: url)
            if deleted == .Success {
                delegate?.deleteRow(with: url)
                let userDefaults = UserDefaults.standard
                var newRecordingsCount = userDefaults.integer(forKey: recordingsCountKey) - 1
                newRecordingsCount = max(newRecordingsCount, 0)
                userDefaults.setValue(newRecordingsCount, forKey: recordingsCountKey)
                saveCurrentNumberOfSavedRecordings()
            }
        }
    }
    
    @IBAction func cancelDelete(_ sender: Any) {
        logger.event("Cancel delete tapped for recording \(String(describing: recordingURL))")
        Analytics.logEvent(AnalyticsEvent.CancelDelete.rawValue, parameters: nil)
        hideDeleteMenuAnimated()
    }
    
    @IBAction func selectRecordingTapped(_ sender: UIButton) {
        logger.event("Select tapped for recording \(String(describing: recordingURL))")
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
        logger.event("Disabling playback timer for \(String(describing: recordingURL))")
        recordingPlayBackTimer?.invalidate()
        recordingPlayBackTimer = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
