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
    
    var audioPlayer: AVAudioPlayer?
    weak var delegate: ViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var url: URL = URL(fileURLWithPath: "")
    
    func configureCell(url:URL,name: String) {
        self.url = url
        recordingNameLbl.text = name
    }
    
    @IBAction func playRecording(_ sender: Any) {
        print("Play")
        
        do
        {
           
            audioPlayer = try AVAudioPlayer(contentsOf: url)

            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.prepareToPlay()
            
            audioPlayer.play()
            
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func deleteRecording(_ sender: Any) {
        
        do{
            try FileManager.default.removeItem(at: url)
            delegate?.updateURLList()
            delegate?.recordingTableView.reloadData()
            
        } catch let error as NSError {
            print("Could Not Delete File")
            
            print(error.localizedDescription)
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
