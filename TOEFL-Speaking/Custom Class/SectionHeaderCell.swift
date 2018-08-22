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
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBOutlet weak var mergingActivityIndicator: UIActivityIndicatorView!
    
    func setButtonImageProperties(button: UIButton) {
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(buttonVerticalInset, buttonHorizontalInset, buttonVerticalInset, buttonHorizontalInset)
    }

    func updatePlayingState() {
        
        if let url = recordingsURL {
           isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: url, id: date)
        } else {
            isPlaying = false
        }
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator) { (shareURL) in
            
            openShareSheet(url: shareURL, activityIndicator: self.mergingActivityIndicator, completion: {})
        }
    }
    
    @IBAction func playRecordingTapped(_ sender: UIButton) {
        
        updatePlayingState()
        
        if isPlaying || (delegate?.isRecording)! {
            
            CentralAudioPlayer.player.playRecording(url: getMergedFileURL(), id: self.date, button: sender, iconId: "g")
            
            return
        }
        
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator){ (playURL) in
            
            self.recordingsURL = playURL
        
            CentralAudioPlayer.player.playRecording(url: playURL, id: self.date, button: sender, iconId: "g")
            
            DispatchQueue.main.async {
                self.mergingActivityIndicator.stopAnimating()

            }
        }
    }
    

    func configureCell(date:String) {
        sectionNameLbl.text = date
        self.date = date
        
        setButtonImageProperties(button: playAllBtn)
        setButtonImageProperties(button: shareAllBtn)
        mergingActivityIndicator.stopAnimating()

        updatePlayingState()
        
        if isPlaying {
            setButtonBgImage(button: playPauseBtn, bgImage: pauseBtnIcon)
        } else {
            setButtonBgImage(button: playPauseBtn, bgImage: playBtnIcon)
        }
    }
}
