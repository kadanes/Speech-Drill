//
//  SectionHeaderCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 03/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation
class SectionHeaderCell: UITableViewCell,AVAudioPlayerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    weak var delegate: ViewController?
    var audioPlayer: AVAudioPlayer?
    var isPlaying = false
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
        
        
        if (!isPlaying) {
            
            isPlaying = true
            sender.setTitle("⏸", for: .normal)
            
            delegate?.mergeAudioFiles(date: date, completion: {
                do{
                    self.audioPlayer = try AVAudioPlayer(contentsOf: getMergedFileURL())
                    self.audioPlayer?.delegate = self
                    
                    self.isPlaying = true
                    guard let audioPlayer = self.audioPlayer else { return }
                    
                    audioPlayer.play()
                    
                } catch let error as NSError {
                    
                    print("Error Playing")
                    print(error)
                }
                
            })
            
        } else {
            isPlaying = false
            audioPlayer?.stop()
            sender.setTitle("▶️", for: .normal)
        }
    
    }
    
    func configureCell(date:String) {
        sectionNameLbl.text = date
        self.date = date
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playPauseBtn.setTitle("▶️", for: .normal)
        
    }
    
    func shareMergedAudio() {
        
        let mergedAudioURL = getMergedFileURL()
        
        let activityVC = UIActivityViewController(activityItems: [mergedAudioURL],applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = self.delegate?.view
        
        self.delegate?.present(activityVC, animated: true, completion: nil)
    }
    
    
}
