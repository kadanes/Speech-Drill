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
         isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: getMergedFileURL(), id: date)
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        
        shareMergedAudio()
    }

    @IBAction func playRecordingTapped(_ sender: UIButton) {
        
        updatePlayingState()
        
        if isPlaying || (delegate?.isRecording)! {
            
            
            CentralAudioPlayer.player.playRecording(url: getMergedFileURL(), id: self.date, button: sender, iconId: "g")
            
            return
        }
        
        guard var list = delegate?.getAudioFilesList(date: date) else {return}
        
        list = sortUrlList(recordingsURLList: list)
        
        mergingActivityIndicator.startAnimating()
        
        mergeAudioFiles(audioFileUrls: list, completion: {

            CentralAudioPlayer.player.playRecording(url: getMergedFileURL(), id: self.date, button: sender, iconId: "g")
            DispatchQueue.main.async {
                self.mergingActivityIndicator.stopAnimating()
            }
        })
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
    
    
    func shareMergedAudio() {
        
        let mergedAudioURL = getMergedFileURL()
        
        let activityVC = UIActivityViewController(activityItems: [mergedAudioURL],applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.delegate?.view
        
        self.delegate?.present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            
            if success {
                Toast.show(message: "Shared successfully!", success: true)
            } else {
                Toast.show(message: "Cancelled share!", success: false)
            }
        }
    }

}
