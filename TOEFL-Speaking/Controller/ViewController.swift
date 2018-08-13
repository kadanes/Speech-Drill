//
//  ViewController.swift
//  TOEFL Speaking
//
//  Created by Parth Tamane on 31/07/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
   

    @IBOutlet weak var adjustThinkTimeBtn: UILabel!
    @IBOutlet weak var adjustSpeakTimeBtn: UILabel!
    
    @IBOutlet weak var recordBtn: UIButton!
    
    @IBOutlet weak var recordingTableView: UITableView!
    
    @IBOutlet weak var topicLbl: UILabel!
    
    @IBOutlet weak var topicNumberLbl: UILabel!
    
   
    @IBOutlet weak var exportSelectedBtn: UIButton!
    
    @IBOutlet weak var exportMenuHeight: NSLayoutConstraint!
    
    @IBOutlet weak var exportMenuStackView: UIStackView!
    
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
    
    
    var dateSortedRecordingList: Dictionary<String,Array<URL>> = [:]
    
    var exportSelected = [URL]()

    var mergeAudioURL: URL?

    
    let userDefaults = UserDefaults.standard
    
    
    var playingRecordingURL: URL?
    var playPauseButton: UIButton?
    var isPlaying = false
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        updateURLList()
        
        recordingTableView.reloadData()
        
        readTopics()
        topicNumber = userDefaults.integer(forKey: "topicNumber")
        renderTopic(topicNumber: topicNumber, saveDefault: true)
        
    }
    
    
    func renderTopic(topicNumber: Int, saveDefault: Bool) {
        if saveDefault{
            userDefaults.set(topicNumber, forKey: "topicNumber")
        }
        
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
        
        renderTopic(topicNumber: topicNumber, saveDefault: true)
        
    }
    
    @IBAction func previousQuestionTapped(_ sender: UIButton) {
        let decrement = sender.tag
        topicNumber = (topicNumber - decrement > 0) ? topicNumber - decrement : 1
        
        renderTopic(topicNumber: topicNumber, saveDefault: true)

    }
    
    
    @IBAction func startRecordingPressed(_ sender: Any) {
        
        if (!recording) {
            recording = true
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementThinkTime), userInfo: nil, repeats: true)
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
            renderTopic(topicNumber: topicNumber, saveDefault: true)
            
            recordingTableView.reloadData()
        }
        
    }
    
    func getAudioFilesList(date: String) -> [URL] {
        
        guard let urlList = dateSortedRecordingList[date] else {return [URL]()}
        
        return urlList
    }
    
    func mergeAudioFiles(audioFileUrls: [URL],completion: @escaping () -> ()) {
        
        do {
            try FileManager.default.removeItem(at: getMergedFileURL())
            print("Deleted Old File")
            
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        
        let composition = AVMutableComposition()
        
        
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
    
    
    func toggleExportMenu() {
        if exportSelected.count > 0 {
            exportMenuHeight.constant = 40
            exportMenuStackView.isHidden = false

            exportSelectedBtn.setTitle("Export \(exportSelected.count) recordings", for: .normal)
            
        } else {
            exportMenuHeight.constant = 0
            exportMenuStackView.isHidden = true
        }
    }
    
    
    func addToExportList(url: URL) {
        exportSelected.append(url)
    }
    
    func removeFromExportList(url: URL) {
        exportSelected = exportSelected.filter {$0 != url}
    }
    
    func clearSelected() {
        exportSelected.removeAll()
        toggleExportMenu()
        recordingTableView.reloadData()
    }
    
    @IBAction func exportSelectedTapped(_ sender: UIButton) {
        
        mergeAudioFiles(audioFileUrls: exportSelected) {
            
            let activityVC = UIActivityViewController(activityItems: [getMergedFileURL()],applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = self.view
            
            self.present(activityVC, animated: true, completion: {
                
            })
            
            activityVC.completionWithItemsHandler = { activity, success, items, error in
            
                self.clearSelected()
            }
        }
    }
    
    @IBAction func cancelSelectedTapped(_ sender: UIButton) {
        clearSelected()
    }
    
}

extension ViewController: AVAudioPlayerDelegate {
    
    
    func stopPlaying() {
       
        
        DispatchQueue.main.async {
             self.playPauseButton?.setTitle("▶️", for: .normal)
        }
        
        isPlaying = false
        playingRecordingURL = nil
        audioPlayer?.stop()
    }
    
    func playRecording(url: URL, button: UIButton){
        
        
        if (url != playingRecordingURL) {
            
            if (playPauseButton == nil ) {
                playPauseButton = button
            }
            
            DispatchQueue.main.async {
                self.playPauseButton!.setTitle("▶️", for: .normal)
                self.playPauseButton = button
                self.playPauseButton!.setTitle("⏸", for: .normal)
            }
           
            isPlaying = true
            playingRecordingURL = url
            
            do{
                
                audioPlayer = try AVAudioPlayer(contentsOf: playingRecordingURL!)
                audioPlayer?.delegate = self
                
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            } catch let error as NSError {
                
                print(error.localizedDescription)
            }
            
        } else if (isPlaying) {
            
            audioPlayer?.pause()
            isPlaying = false
            
            DispatchQueue.main.async {
                self.playPauseButton!.setTitle("▶️", for: .normal)
            }
            
        } else if (!isPlaying) {

            audioPlayer?.play()
            isPlaying = true
            
            DispatchQueue.main.async {
                self.playPauseButton!.setTitle("⏸", for: .normal)
            }
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        playingRecordingURL = nil
        isPlaying = false
        
        DispatchQueue.main.async {
            self.playPauseButton!.setTitle("▶️", for: .normal)
        }
    }
    
    
    @IBAction func playSelectedAudioTapped(_ sender: UIButton) {
        
        mergeAudioFiles(audioFileUrls: exportSelected) {
            self.playRecording(url: getMergedFileURL(), button: sender)
        }
        
    }
  
}

extension ViewController: AVAudioRecorderDelegate {
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
}



extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
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
        return sectionHeaderHeight
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return recordingCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell") as? RecordingCell {
            
            let recordings = dateSortedRecordingList.sorted{ $0.0 > $1.0 }[indexPath.section]
            
            let url = recordings.value[indexPath.row]
            cell.configureCell(url: url )
            cell.delegate = self
            
            if(exportSelected.contains(url)) {
                cell.selectCheckBox()
            } else {
                cell.deselectCheckBox()
            }
            
            
            return cell
            
        } else {
            return UITableViewCell()
        }
        
    }

}
