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
    weak var delegate: ViewController?

    var url = URL(fileURLWithPath: "")
    var date = ""
    
    @IBOutlet weak var playAllBtn: UIButton!
    
    @IBOutlet weak var shareAllBtn: UIButton!
    
    @IBOutlet weak var sectionNameLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        
        shareMergedAudio()
    }

    @IBAction func playRecordingTapped(_ sender: UIButton) {
        
        guard let list = delegate?.getAudioFilesList(date: date) else {return}
        mergeAudioFiles(audioFileUrls: list, completion: {

            CentralAudioPlayer.player.playRecording(url: getMergedFileURL(), id: self.date, button: sender, iconId: "g")
            
        })
    }
    
    func configureCell(date:String, isPlaying: Bool) {
        sectionNameLbl.text = date
        self.date = date
        
        setButtonImageProperties(button: playAllBtn)
        setButtonImageProperties(button: shareAllBtn)
        
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

    func shareMergedAudio() {
        
        let mergedAudioURL = getMergedFileURL()
        
        let activityVC = UIActivityViewController(activityItems: [mergedAudioURL],applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.delegate?.view
        
        self.delegate?.present(activityVC, animated: true, completion: nil)
    }
    
    
}
