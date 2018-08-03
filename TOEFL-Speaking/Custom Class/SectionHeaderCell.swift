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
    
    @IBOutlet weak var sectionNameLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
        url = (delegate?.mergeAudioFiles(date: sectionNameLbl.text!))!
        
    }
    @IBAction func playRecordingTapped(_ sender: UIButton) {
        url = (delegate?.mergeAudioFiles(date: sectionNameLbl.text!))!
        
        let fileManager = FileManager.default
        while !fileManager.fileExists(atPath: url.path) {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = true
        
        if !isPlaying {
            
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                
                isPlaying = true
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.play()

                sender.setTitle("⏸", for: .normal)
                
            } catch let error as NSError {
                
                print("Error Playing")
                print(error)
            }
            
        } else {
            
            isPlaying = false
            audioPlayer?.stop()
            sender.setTitle("▶️", for: .normal)
            deleteFile(url: url)
        }
    }
    
    func configureCell(date:String) {
        sectionNameLbl.text = date
        activityIndicator.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        playPauseBtn.setTitle("▶️", for: .normal)
        deleteFile(url: url)
        
    }
    
    func deleteFile(url:URL) {
        
        do{
            try FileManager.default.removeItem(at: url)
            print("Removing Successful")
            
        } catch let error as NSError {
            print("Could Not Delete File")
            
            print(error.localizedDescription)
            
        }
    }

}
