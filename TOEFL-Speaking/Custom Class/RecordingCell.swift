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
    
    private var playBackTimer: Timer?
    
    func configureCell(url:URL) {
        
        self.recordingURL = url
        
        getFileDetails(url: "\(url)")
        
        if topicNumber != testModeId  {
            recordingNameLbl.text = "Topic \(topicNumber+1)"
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
        
        setButtonImageProperties(button: deleteRecordingBtn)
        setButtonImageProperties(button: shareRecordingBtn)
        setButtonImageProperties(button: playRecordningBtn)
        
        setCheckBoxProperties()
        updatePlayingState()
        configurePlayBackSeeker()
        
        if isPlaying {
            setButtonBgImage(button: playPauseBtn, bgImage: pauseBtnIcon)
        } else {
            setButtonBgImage(button: playPauseBtn, bgImage: playBtnIcon)
        }
    }
    
    func setButtonImageProperties(button: UIButton) {
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(buttonVerticalInset, buttonHorizontalInset, buttonVerticalInset, buttonHorizontalInset)
    }
    
    func setCheckBoxProperties() {
        
        if let checkBoxBg = checkBoxBtn.subviews.first as? UIImageView {
            checkBoxBg.contentMode = .scaleAspectFit
        }
    }
    
    func selectCheckBox() {
        checkBoxBtn.setImage(checkMarkIcon, for: .normal)
    }
    
    func deselectCheckBox() {
        checkBoxBtn.setImage(nil, for: .normal)
    }
    
    func getFileDetails(url: String) {

       (timeStamp,topicNumber,thinkTime) = splitFileURL(url: url)
    }
    
    func updatePlayingState() {
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: recordingURL!, id: "\(timeStamp)")
    }
    
    @IBAction func shareRecordingPressed(_ sender: Any) {
        CentralAudioPlayer.player.stopPlaying()
        openShareSheet(url: recordingURL!, activityIndicator: nil, completion:{})
    }
    
    @IBAction func playRecording(_ sender: UIButton) {
        if (delegate?.isRecording)! {
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
            delegate?.reloadData()
        }
    }
    
    func configurePlayBackSeeker() {
        if isPlaying {
            seekerView.isHidden = false
            playingSeeker.setThumbImage(drawSliderThumb(diameter: 15, backgroundColor: UIColor.white), for: .normal)
            playingSeeker.setThumbImage(drawSliderThumb(diameter: 25, backgroundColor: UIColor.yellow), for: .highlighted)
    
            let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
            let totalTime = CentralAudioPlayer.player.getPlayBackDuration();
            
            playingSeeker.maximumValue = Float(totalTime)
            playingSeeker.minimumValue = Float(0.0)
            playingSeeker.value = Float(currentTime)
            currentPlayTimeLbl.text = convertToMins(seconds: currentTime)
            totalPlayTimeLbl.text = convertToMins(seconds: totalTime)
            
            playBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
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
            delegate?.reloadData()
        }
    }
    
    ///On slider touchdown invalidate the update timer
    @IBAction func stopPlaybackUIUpdate(_ sender: UISlider) {
        playBackTimer?.invalidate()
        sender.minimumTrackTintColor = UIColor.yellow
    }
    
    ///On value change play to new time
    @IBAction func updatePlaybackTimeWithSlider(_ sender: UISlider) {
        let playbackTime = Double(sender.value)
        currentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
        CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
        sender.minimumTrackTintColor = UIColor.yellow
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func startPlaybackUIUpdate(_ sender: UISlider) {
        playBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlaybackTime), userInfo: nil, repeats: true)
        sender.minimumTrackTintColor = UIColor.white
    }

    @IBAction func deleteRecording(_ sender: Any) {
        CentralAudioPlayer.player.stopPlaying()
        if let url = recordingURL {
            deleteStoredRecording(recordingURL: url)
            delegate?.reloadData()
        }
    }
    
    @IBAction func selectRecordingTapped(_ sender: UIButton) {
        if !(isRecordningSelected) {
            setButtonBgImage(button: sender, bgImage: checkMarkIcon)
            delegate?.addToExportList(url: recordingURL!)
        } else {
            setButtonBgImage(button: sender, bgImage: UIImage())
            delegate?.removeFromExportList(url: recordingURL!)
        }
        isRecordningSelected = !isRecordningSelected
        delegate?.toggleExportMenu()
    }
    
    func disableTimer() {
        playBackTimer?.invalidate()
        playBackTimer = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
