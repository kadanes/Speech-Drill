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
            
            CentralAudioPlayer.player.playRecording(url: playURL, id: self.date, button: self.playAllBtn, iconId: "g")
            
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
        updateToggleBtnIcon()
        
        mergingActivityIndicator.stopAnimating()
        
        updatePlayingState()
        updateToggleBtnIcon()
    
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
    
}
