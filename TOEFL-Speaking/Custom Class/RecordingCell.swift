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

    weak var delegate: MainVC?

    var topicNumber = 0
    var timeStamp = 0
    var thinkTime = 15

    var isRecordningSelected = false
    var recordingURL: URL?
    var isPlaying = false
    
    func configureCell(url:URL) {
        
        self.recordingURL = url
        
        getFileDetails(url: "\(url)")
        
        if topicNumber != 0  {
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
                labelText = "Improper Think Time"
            }
            
            recordingNameLbl.text = labelText
            
        }
        
        setButtonImageProperties(button: deleteRecordingBtn)
        setButtonImageProperties(button: shareRecordingBtn)
        setButtonImageProperties(button: playRecordningBtn)
        
        setCheckBoxProperties()
        updatePlayingState()
        
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
            
            if topicNumber == 0 {
                delegate?.setToTestMode()
            } else {
                delegate?.setToPracticeMode()
            }
            
            CentralAudioPlayer.player.playRecording(url: url, id: "\(timeStamp)", button: playPauseBtn, iconId: "g")
            
            delegate?.renderTopic(topicNumber: topicNumber)
            
            delegate?.reloadData()

        }
    }
    
    @IBAction func deleteRecording(_ sender: Any) {
        
        do{
            try FileManager.default.removeItem(at: recordingURL!)
            
            delegate?.updateURLList()
            delegate?.recordingTableView.reloadData()
            
        } catch let error as NSError {
            
            print("Could Not Delete File\n",error.localizedDescription)
            
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
