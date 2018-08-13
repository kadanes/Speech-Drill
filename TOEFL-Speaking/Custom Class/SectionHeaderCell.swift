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
    
    var isMerged = false
    
    
    @IBOutlet weak var sectionNameLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        
        shareMergedAudio()
    }

    @IBAction func playRecordingTapped(_ sender: UIButton) {
        
        guard let list = delegate?.getAudioFilesList(date: date) else {return}
        delegate?.mergeAudioFiles(audioFileUrls: list, completion: {
            self.delegate?.playRecording(url: getMergedFileURL(), button: sender)
        })
    }
    
    func configureCell(date:String) {
        sectionNameLbl.text = date
        self.date = date
    }

    func shareMergedAudio() {
        
        let mergedAudioURL = getMergedFileURL()
        
        let activityVC = UIActivityViewController(activityItems: [mergedAudioURL],applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.delegate?.view
        
        self.delegate?.present(activityVC, animated: true, completion: nil)
    }
    
    
}
