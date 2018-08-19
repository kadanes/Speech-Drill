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

    @IBOutlet weak var checkBoxBtn: CheckBoxButton!

    weak var delegate: ViewController?
    var topicNumber = 0
    var timeStamp = 0
    var url: URL?
    var isRecordingSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

   
    func configureCell(url:URL) {
        self.url = url
        getTopicNumber(url: "\(url)")
        recordingNameLbl.text = "Topic \(topicNumber)"
        
        setButtonImageProperties(button: deleteRecordingBtn)
        setButtonImageProperties(button: shareRecordingBtn)
        setButtonImageProperties(button: playRecordningBtn)
        
        setCheckBoxProperties()
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
        isRecordingSelected = true
    }
    
    func deselectCheckBox() {
        checkBoxBtn.setImage(nil, for: .normal)
        isRecordingSelected = false
    }
    
    func getTopicNumber(url: String) {

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
    
    @IBAction func shareRecordingPressed(_ sender: Any) {
        
        let activityVC = UIActivityViewController(activityItems: [url ?? URL(fileURLWithPath: "")],applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = delegate?.view
        
        delegate?.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func playRecording(_ sender: UIButton) {
        
        if let url = url {
            delegate?.playRecording(url: url, button: playPauseBtn)
            delegate?.renderTopic(topicNumber: topicNumber, saveDefault: false)
        }
        
    }
    
    @IBAction func deleteRecording(_ sender: Any) {
        
        do{
            try FileManager.default.removeItem(at: url!)
            
            delegate?.updateURLList()
            delegate?.recordingTableView.reloadData()
            
        } catch let error as NSError {
            print("Could Not Delete File")
            
            print(error.localizedDescription)
            
        }
    }
    
    @IBAction func selectRecordingTapped(_ sender: UIButton) {
        
        delegate?.renderTopic(topicNumber: topicNumber, saveDefault: false)
        
        if !isRecordingSelected {
            
            DispatchQueue.main.async {
                sender.setImage(checkMarkIcon, for: .normal)
                self.delegate?.stopPlaying()
            }
            
            delegate?.addToExportList(url: url!)
            
        } else {
            DispatchQueue.main.async {
                sender.setImage(nil, for: .normal)
            }
            
            delegate?.removeFromExportList(url: url!)
        }
        
        isRecordingSelected = !isRecordingSelected
        delegate?.toggleExportMenu()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
