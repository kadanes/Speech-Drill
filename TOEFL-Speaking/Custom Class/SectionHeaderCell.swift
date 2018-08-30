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
    
    func setButtonImageProperties(button: UIButton) {
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(buttonVerticalInset, buttonHorizontalInset, buttonVerticalInset, buttonHorizontalInset)
    }

    func updatePlayingState() {
        
        if let url = recordingsURL {
            print("1) URL:",recordingsURL," ID:",date)
           isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: url, id: date)
            print(isPlaying)
        } else {
            
            let recordedURLS = sortUrlList(recordingsURLList: (delegate?.getAudioFilesList(date: date))!)

            if recordedURLS.count > 1 {
                
                recordingsURL = getMergedFileURL()
                print("2) URL:",recordingsURL," ID:",date)
                
            isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: getMergedFileURL(), id: date)
                print(isPlaying)

                
            } else if recordedURLS.count == 1 {
                recordingsURL = recordedURLS[0]
                print("2) URL:",recordingsURL," ID:",date)

                isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: recordedURLS[0], id: date)
                print(isPlaying)

            }
            
        }
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        
        processMultipleRecordings(recordingsList: delegate?.getAudioFilesList(date: date), activityIndicator: mergingActivityIndicator) { (shareURL) in
            
            openShareSheet(url: shareURL, activityIndicator: self.mergingActivityIndicator, completion: {})
        }
    }
    
    @IBAction func playRecordingTapped(_ sender: UIButton) {
        
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
        
        setButtonImageProperties(button: playAllBtn)
        setButtonImageProperties(button: shareAllBtn)
        
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
            hideSectionBtn.setTitle("💢", for: .normal)
        } else {
            hideSectionBtn.setTitle("⛔️", for: .normal)
        }
    }
    
}
