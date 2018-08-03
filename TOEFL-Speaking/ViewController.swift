//
//  ViewController.swift
//  TOEFL Speaking
//
//  Created by Parth Tamane on 31/07/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVAudioPlayerDelegate,AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource {
   

    @IBOutlet weak var adjustThinkTimeBtn: UILabel!
    @IBOutlet weak var adjustSpeakTimeBtn: UILabel!
    
    @IBOutlet weak var recordBtn: UIButton!
    
    @IBOutlet weak var recordingTableView: UITableView!
    
    
    var thinkTime = 15
    var speakTime = 45
    var recording = false
    var blinking = true
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    var recordingList: [Dictionary<String,URL>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        updateURLList()
        
        recordingTableView.reloadData()
        
        
    }
    
    @IBAction func adjustThinkTimePressed(_ sender: Any) {
        
    }
    
    @IBAction func adjustSpeakTimePressed(_ sender: Any) {
    }
    
    @IBAction func startRecordingPressed(_ sender: Any) {
        
        if (!recording) {
            recording = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementThinkTime), userInfo: nil, repeats: true)
        }
    }


    func recordAudio() {

        do {
            let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            
            let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
            
            let timestamp = Int(round((NSDate().timeIntervalSince1970)))
//            let path =  "/recordings/\(timestamp)"+".m4a"
            let path =  "\(timestamp)"+".m4a"

            let fullRecordingPath = (documents as NSString).appendingPathComponent(path)
            
            print(fullRecordingPath)
            
            let url = NSURL.fileURL(withPath: fullRecordingPath)
            
            let recordSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ] as [String : Any]
            
            do{
                audioRecorder = try AVAudioRecorder(url:url, settings: recordSettings)
                audioRecorder.delegate = self
                
                audioRecorder.prepareToRecord()
                
                audioRecorder.record(forDuration: 45)
                
            } catch let error as NSError {
                print("Error with recording")
                print(error.localizedDescription)
            }
        } catch {
        }
    }

    
    func updateURLList() {
        
        recordingList.removeAll(keepingCapacity: false)
        
        let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
        
        if let files = FileManager.default.enumerator(atPath: "\(documents)") {
    
            for file in files {
                
                let recordingName = "\(file)"
                
                if recordingName.hasSuffix(".m4a") {
                    
                    let splitFile = recordingName.components(separatedBy: ".")
                    
                    let date = parseDate(timeStamp: splitFile[0])
                    
                    let url = URL(fileURLWithPath: documents+"/"+"\(file)")
                    
                    let recordingDetails = [date: url]
                    
                    recordingList.append(recordingDetails)
                }
                
            }
        }
        
        print(recordingList)
    }
    
    func parseDate(timeStamp: String) -> String {
        
        let ts = Double(timeStamp)!
        
        let date = Date(timeIntervalSince1970: ts)
        let dateFormatter = DateFormatter()

        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy(hh:mm)"
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    @objc func decrementThinkTime(timer: Timer) {
        if(thinkTime > 0) {
            thinkTime -= 1
            
            adjustThinkTimeBtn.text = "\(thinkTime)"
            
        } else {
            timer.invalidate()
            thinkTime = 15
            recordAudio()
            
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementSpeakTime), userInfo: nil, repeats: true)

        }
    }
    
    @objc func decrementSpeakTime(timer: Timer) {
        
        if(speakTime > 0) {
            speakTime -= 1
            adjustSpeakTimeBtn.text = "\(speakTime)"
            let _ = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(blinkRecordBtn), userInfo: nil, repeats: true)
        } else {
            timer.invalidate()
            speakTime = 45
            
        }
    }
    
    
    
    @objc func blinkRecordBtn(timer: Timer) {
        if speakTime > 0 {
            if !blinking {
                recordBtn.setTitle("🔴", for: .normal)
                blinking = true
            } else {
                recordBtn.setTitle("", for: .normal)
                blinking = false
            }
        } else {
            adjustThinkTimeBtn.text = "15"
            adjustSpeakTimeBtn.text = "45"
            recordBtn.setTitle("⭕️", for: .normal)

            recording = false
            blinking = false
            
            timer.invalidate()
            
            updateURLList()
            
            recordingTableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return recordingList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell") as? RecordingCell {
            let recordingDetails = recordingList[indexPath.row]
        
            for recordingDetail in recordingDetails {
                
                cell.configureCell(url: recordingDetail.value, name: recordingDetail.key)
                cell.delegate = self
            }
        
            return cell
            
        } else {
            return UITableViewCell()
        }
    
    }

}

