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
    
    @IBOutlet weak var topicLbl: UILabel!
    
    @IBOutlet weak var topicNumberLbl: UILabel!
    
    let defaultThinkTime = 15
    let defaultSpeakTime = 45
   
    var thinkTime = 15
    var speakTime = 45

    var topicNumber = 0
    var topics: [String] = []
    
    var recording = false
    var blinking = true
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    var dateSortedRecordingList: Dictionary<String,Array<URL>> = [:]
    var mergeAudioURL: URL?

    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        updateURLList()
        
        recordingTableView.reloadData()
        
        readTopics()
        topicNumber = userDefaults.integer(forKey: "topicNumber")
        renderTopic(topicNumber: topicNumber)
        
    }
    
    
    func renderTopic(topicNumber: Int) {
        userDefaults.set(topicNumber, forKey: "topicNumber")
        
        UIView.animate(withDuration: 1) {
            
            self.topicLbl.text = self.topics[topicNumber]
            self.topicNumberLbl.text = "\(topicNumber)"
        }
       
    }
    
    func readTopics() {
        do{
            let fileURL = Bundle.main.url(forResource: "topics", withExtension: "csv")
            let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
            topics = content.components(separatedBy:"\n").map{$0}
            
        } catch {
            
        }
    }
    
    @IBAction func nextQuestionTapped(_ sender: UIButton) {
        let increment = sender.tag
        topicNumber = (topicNumber + increment < topics.count) ? topicNumber + increment : topics.count - 1
        
        renderTopic(topicNumber: topicNumber)
        
    }
    
    @IBAction func previousQuestionTapped(_ sender: UIButton) {
        let decrement = sender.tag
        topicNumber = (topicNumber - decrement > 0) ? topicNumber - decrement : 1
        
        renderTopic(topicNumber: topicNumber)

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

            let path =  "\(timestamp)_\(topicNumber)"+"."+recordingExtension

            let fullRecordingPath = (documents as NSString).appendingPathComponent(path)
            
            
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
                
                audioRecorder.record(forDuration: Double(defaultSpeakTime))
                
                
            } catch let error as NSError {
                print("Error with recording")
                print(error.localizedDescription)
            }
        } catch {
        }
    }

    func updateURLList() {
                
        dateSortedRecordingList.removeAll()
        
        let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
        
        if let files = FileManager.default.enumerator(atPath: "\(documents)") {

            for file in files {

                let recordingName = "\(file)"

                if recordingName.hasSuffix("."+recordingExtension) {

                    if (recordingName != mergedFileName) {
                        let fileName = recordingName.components(separatedBy: ".")
                        
                        let fileNameComponents = fileName[0].components(separatedBy: "_")
                        
                        let date = parseDate(timeStamp: fileNameComponents[0])
                        
                        let url = URL(fileURLWithPath: documents+"/"+"\(file)")
                        
                        var recordingURLs = dateSortedRecordingList[date]
                        
                        if recordingURLs == nil {
                            recordingURLs = [URL]()
                        }
                        
                        recordingURLs?.append(url)
                        dateSortedRecordingList[date] = recordingURLs
                    }
            
                }
            }
        }
    }
    
    func parseDate(timeStamp: String) -> String {
        
        guard let ts = Double(timeStamp) else {
            return "NIL"
        }
        
        let date = Date(timeIntervalSince1970: ts)
        let dateFormatter = DateFormatter()

        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    @objc func decrementThinkTime(timer: Timer) {
        if(thinkTime > 0) {
            thinkTime -= 1
            
            adjustThinkTimeBtn.text = "\(thinkTime)"
            
        } else {
            timer.invalidate()
            thinkTime = defaultThinkTime
            recordAudio()
            
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementSpeakTime), userInfo: nil, repeats: true)
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkRecordBtn), userInfo: nil, repeats: true)

        }
    }
    
    @objc func decrementSpeakTime(timer: Timer) {
        
        if(speakTime > 0) {
            speakTime -= 1
            adjustSpeakTimeBtn.text = "\(speakTime)"
        } else {
            timer.invalidate()
            speakTime = defaultSpeakTime
            
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
            adjustThinkTimeBtn.text = "\(defaultThinkTime)"
            adjustSpeakTimeBtn.text = "\(defaultSpeakTime)"
            recordBtn.setTitle("⭕️", for: .normal)
            recording = false
            blinking = false
            
            timer.invalidate()
            
            updateURLList()
            
            topicNumber += 1
            renderTopic(topicNumber: topicNumber)
            
            recordingTableView.reloadData()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateSortedRecordingList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return dateSortedRecordingList.sorted{ $0.0 > $1.0}[section].value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? SectionHeaderCell {
            
            let date = dateSortedRecordingList.sorted{ $0.0 > $1.0}[section].key
            cell.configureCell(date: date)
            cell.delegate = self
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell") as? RecordingCell {
            
            let recordings = dateSortedRecordingList.sorted{ $0.0 > $1.0 }[indexPath.section]
            
            cell.configureCell(url: recordings.value[indexPath.row])
            cell.delegate = self
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    
    }

    
    func mergeAudioFiles(date:String,completion: @escaping () -> ()) {
        
        do {
            try FileManager.default.removeItem(at: getMergedFileURL())
            print("Deleted Old File")
            
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        let composition = AVMutableComposition()
        
        guard let audioFileUrls = dateSortedRecordingList[date] else {
            return
        }

        for i in 0 ..< audioFileUrls.count {
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            let asset = AVURLAsset(url: (audioFileUrls[i]))
            
            let track = asset.tracks(withMediaType: AVMediaType.audio)[0]
            
            let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: track.timeRange.duration)
            
            do{
                try compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
                
                
                let delimiterPath = Bundle.main.path(forResource: beepSoundFileName, ofType: recordingExtension)
                
                if let path = delimiterPath {
                    let delimiterURL = URL(fileURLWithPath: path)
                    print(delimiterURL)
                    
                    let assetDelimiter = AVURLAsset(url: delimiterURL)
                    
                    let trackDelimiter = assetDelimiter.tracks(withMediaType: AVMediaType.audio)[0]
                    
                    let timeRangeDelimiter = CMTimeRange(start: CMTimeMake(0, 600), duration: trackDelimiter.timeRange.duration)
                    
                    try compositionAudioTrack.insertTimeRange(timeRangeDelimiter, of: trackDelimiter, at: composition.duration)
                }
                
            } catch let error as NSError {
                print("Error while inseting in composition for url: ",i+1)
                print(error.localizedDescription)
                
            }
        }
        
       
       
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: presetName)
        
        assetExport?.outputFileType = outputFileType
        
        assetExport?.outputURL = getMergedFileURL()
        
        assetExport?.exportAsynchronously(completionHandler:
            {
            
                switch assetExport!.status
                {
                case AVAssetExportSessionStatus.failed:
                    print("failed \(assetExport?.error ?? "FAILED" as! Error)")
                case AVAssetExportSessionStatus.cancelled:
                    print("cancelled \(assetExport?.error ?? "CANCELLED" as! Error)")
                case AVAssetExportSessionStatus.unknown:
                    print("unknown\(assetExport?.error ?? "UNKNOWN" as! Error)")
                case AVAssetExportSessionStatus.waiting:
                    print("waiting\(assetExport?.error ?? "WAITING" as! Error)")
                case AVAssetExportSessionStatus.exporting:
                    print("exporting\(assetExport?.error ?? "EXPORTING" as! Error)")
                default:
                    print("Audio Concatenation Complete")
                    completion()   
                }
            })
    }
    
}

