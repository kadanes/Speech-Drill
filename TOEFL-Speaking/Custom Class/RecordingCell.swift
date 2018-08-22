//
//  RecordingCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 02/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingCell: UITableViewCell {
    
    @IBOutlet weak var recordingNameLbl: UILabel!
    
    @IBOutlet weak var playPauseBtn: RoundButton!
    
    @IBOutlet weak var deleteRecordingBtn: RoundButton!
    @IBOutlet weak var shareRecordingBtn: RoundButton!
    @IBOutlet weak var playRecordningBtn: RoundButton!

    @IBOutlet weak var checkBoxBtn: UIButton!

    weak var delegate: ViewController?

    var topicNumber = 0
    var timeStamp = 0
    var thinkTime = 15

    var isRecordningSelected = false
    var url: URL?
    

    func configureCell(url:URL, isPlaying: Bool) {
        
        self.url = url
        
        getFileDetails(url: "\(url)")
        
        if topicNumber != 0  {
            recordingNameLbl.text = "Topic \(topicNumber)"
        } else {
            
            var labelText = ""
            switch thinkTime {
                case 15:
                labelText = "Independent"
                case 20:
                labelText = "Integrated B"
                case 30:
                labelText = "Integrated A"
                default:
                labelText = "Improper Think Time"
            }
            
            recordingNameLbl.text = labelText
            
        }
        
        setButtonImageProperties(button: deleteRecordingBtn)
        setButtonImageProperties(button: shareRecordingBtn)
        setButtonImageProperties(button: playRecordningBtn)
        
        setCheckBoxProperties()
        
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
    
    func setCheckBoxProperties() {
        
        if let checkBoxBg = checkBoxBtn.subviews.first as? UIImageView {
            checkBoxBg.contentMode = .scaleAspectFit
        }
        
    }
    
    func selectCheckBox() {
        checkBoxBtn.setImage(checkMarkIcon, for: .normal)
    }
    
    func deselectCheckBox() {
        checkBoxBtn.setImage(nil, for: .normal)
    }
    
    func getFileDetails(url: String) {

       (timeStamp,topicNumber,thinkTime) = splitFileURL(url: url)
    }
    
    @IBAction func shareRecordingPressed(_ sender: Any) {
        
        let activityVC = UIActivityViewController(activityItems: [url ?? URL(fileURLWithPath: "")],applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = delegate?.view
        
        delegate?.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func playRecording(_ sender: UIButton) {
        
        if  (delegate?.isRecording)! {return}
        
        if let url = url {
            
            if topicNumber == 0 {
                delegate?.setToTestMode()
            } else {
                delegate?.setToPracticeMode()
            }
            
            CentralAudioPlayer.player.playRecording(url: url, id: "\(timeStamp)", button: playPauseBtn, iconId: "g")
            
            delegate?.renderTopic(topicNumber: topicNumber, saveDefault: true)
        }
        
    }
    
    @IBAction func deleteRecording(_ sender: Any) {
        
        do{
            try FileManager.default.removeItem(at: url!)
            
            delegate?.updateURLList()
            delegate?.recordingTableView.reloadData()
            
        } catch let error as NSError {
            
            print("Could Not Delete File\n",error.localizedDescription)
            
        }
    }
    
    @IBAction func selectRecordingTapped(_ sender: UIButton) {
        
//        delegate?.renderTopic(topicNumber: topicNumber, saveDefault: false)
        
        if !(isRecordningSelected) {
            
            setButtonBgImage(button: sender, bgImage: checkMarkIcon)
            CentralAudioPlayer.player.stopPlaying()
            delegate?.addToExportList(url: url!)
            
        } else {

            setButtonBgImage(button: sender, bgImage: UIImage())

            delegate?.removeFromExportList(url: url!)
        }
        
        isRecordningSelected = !isRecordningSelected
        delegate?.toggleExportMenu()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
