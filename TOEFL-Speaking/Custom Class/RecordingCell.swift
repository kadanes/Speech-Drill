//
//  RecordingCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 02/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingCell: UITableViewCell,AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordingNameLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: RoundButton!
    
    var audioPlayer: AVAudioPlayer?
    weak var delegate: ViewController?
    var topicNumber = 0
    var timeStamp = 0
    var isPlaying = false
    var url: URL?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func configureCell(url:URL) {
        self.url = url
        getTopicNumber(url: "\(url)")
        recordingNameLbl.text = "Topic \(topicNumber)"
        
    }
    
    func getTopicNumber(url: String) {
        print(url)

        let urlComponents = url.components(separatedBy: "/")
        let fileName = urlComponents[urlComponents.count - 1]
        
        let fileNameComponents = fileName.components(separatedBy: ".")
        
        if fileNameComponents.indices.count > 0 {
            
            let recordingNameComponents = fileNameComponents[0].components(separatedBy: "_")
            
            if recordingNameComponents.count > 1 {
                if let topicNumber = Int(recordingNameComponents[1]) {
                    self.topicNumber = topicNumber
                }
            }
            
            if let timeStamp = Int(recordingNameComponents[0]) {
                self.timeStamp = timeStamp
            }
        }
    }
    
    @IBAction func playRecording(_ sender: Any) {
    
        if !isPlaying {
            
            do{
                print(url)
                
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer?.delegate = self
                
                isPlaying = true
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                playPauseBtn.setTitle("⏸", for: .normal)
                
            } catch let error as NSError {
                print(audioPlayer)
                print("Error Playing")
                print(error)
            }
            
            
        } else {
            isPlaying = false
            audioPlayer?.stop()
            playPauseBtn.setTitle("▶️", for: .normal)

        }
        
    }
    
    @IBAction func deleteRecording(_ sender: Any) {
        
        do{
            try FileManager.default.removeItem(at: url!)
            print("Removing Successful")
            
            delegate?.updateURLList()
            delegate?.recordingTableView.reloadData()
            
        } catch let error as NSError {
            print("Could Not Delete File")
            
            print(error.localizedDescription)
            
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Done")
        isPlaying = false
        playPauseBtn.setTitle("▶️", for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
