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
    
    
    @IBOutlet weak var thinkTimeChangeStackView: UIStackView!

    @IBOutlet weak var switchModesBtn: RoundButton!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cancelRecordingBtn: UIButton!
    
    @IBOutlet weak var topicLbl: UILabel!
    
    @IBOutlet weak var topicNumberLbl: UILabel!
    
    @IBOutlet weak var changeTopicBtnsStackView: UIStackView!
    
    @IBOutlet weak var loadNextTopicBtn: RoundButton!
    @IBOutlet weak var loadNextTenthTopicBtn: RoundButton!
    @IBOutlet weak var loadNextFiftiethTopicBtn: RoundButton!
    
    @IBOutlet weak var loadPreviousTopicBtn: RoundButton!
    @IBOutlet weak var loadPreviousTenthTopicBtn: RoundButton!
    @IBOutlet weak var loadPreviousFiftiethTopicBtn: RoundButton!
    
    
    @IBOutlet weak var recordingTableView: UITableView!
    
    @IBOutlet weak var exportSelectedBtn: UIButton!
    
    @IBOutlet weak var exportMenuHeight: NSLayoutConstraint!
    
    @IBOutlet weak var exportMenuStackView: UIStackView!
    
    @IBOutlet weak var playSelectedBtn: UIButton!
    
    @IBOutlet weak var closeShareMenuBtn: UIButton!
    
    var isTestMode = false
    
    var defaultThinkTime = 15
    var defaultSpeakTime = 45

    var thinkTime = 15
    var speakTime = 45

    var topicNumber = 0
    var topics: [String] = []
    
    var isRecording = false
    var blinking = true
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    
    var dateSortedRecordingList: Dictionary<String,Array<URL>> = [:]
    
    var exportSelected = [URL]()

    var mergeAudioURL: URL?

    let userDefaults = UserDefaults.standard
    
    var playingRecordingURL: URL?
    var playPauseButton: UIButton?
    var isPlaying = false
    var audioPlayer: AVAudioPlayer?
    
    var thinkTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetRecordingState()

        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        updateURLList()
        
        readTopics()
        
        topicNumber = userDefaults.integer(forKey: "topicNumber")
        
        renderTopic(topicNumber: topicNumber, saveDefault: true)
     
        setBtnImgProp(button: loadNextTopicBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextTenthTopicBtn ,topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextFiftiethTopicBtn , topPadding: buttonVerticalInset + 3, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousTenthTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousFiftiethTopicBtn , topPadding: buttonVerticalInset + 3, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: playSelectedBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: recordBtn,topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: closeShareMenuBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
    
        setBtnImgProp(button: cancelRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        recordingTableView.reloadData()
    }
    
    func renderTopic(topicNumber: Int, saveDefault: Bool) {
        if saveDefault{
            userDefaults.set(topicNumber, forKey: "topicNumber")
        }
        
        self.topicNumber = topicNumber
        
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
    
    @IBAction func changeThinkTimeTapped(_ sender: RoundButton) {

        if isRecording {return}
        
        switch sender.tag {
            
            case 15:
                defaultThinkTime = 15
                defaultSpeakTime = 45
            case 20:
                defaultThinkTime = 20
                defaultSpeakTime = 60
            case 30:
                defaultThinkTime = 30
                defaultSpeakTime = 60
            default:
                defaultThinkTime = 15
                defaultSpeakTime = 45
        }
        
        speakTime = defaultSpeakTime
        thinkTime = defaultThinkTime
        
        resetRecordingState()
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
        
        stopPlaying()
        
        if (!isRecording) {
            isRecording = true
            
            cancelRecordingBtn.isHidden = false
            
            thinkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementThinkTime), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func cancelRecordingTapped(_ sender: Any) {
        
        if (thinkTime > 0) {
            
            cancelRecordingBtn.isHidden = true

            thinkTimer?.invalidate()
            resetRecordingState()
        }
    }
    
    
    @IBAction func switchModesTapped(_ sender: UIButton) {
       switchModes()
    }
    
    func switchModes() {
        
        if isRecording {return}
        
        if isTestMode {

            self.switchModesBtn.setTitle("Practice", for: .normal)
            self.thinkTimeChangeStackView.isHidden = true
            changeTopicBtnsStackView.isHidden = false
        
            renderTopic(topicNumber: topicNumber, saveDefault: true)
            
        } else {
            
            self.switchModesBtn.setTitle("Test", for: .normal)
            self.thinkTimeChangeStackView.isHidden = false
            changeTopicBtnsStackView.isHidden = true
            
            topicLbl.text = "TEST MODE"
        }
        
        isTestMode = !isTestMode
        
        defaultThinkTime = 15
        defaultSpeakTime = 45
        thinkTime = defaultThinkTime
        speakTime = defaultSpeakTime
        
        resetRecordingState()
        
    }
    
    func setToTestMode() {
        isTestMode = false
        switchModes()
    }

    func setToPracticeMode() {
        isTestMode = true
        switchModes()
    }
    
    @objc func decrementThinkTime(timer: Timer) {
        if(thinkTime > 0) {
            thinkTime -= 1
            
            adjustThinkTimeBtn.text = "\(thinkTime)"
            
        } else {
            timer.invalidate()
            cancelRecordingBtn.isHidden = true
            
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
                setButtonBgImage(button: recordBtn, bgImage: recordIcon)
                blinking = true
            } else {
                recordBtn.setImage(nil, for: .normal)
                blinking = false
            }
        } else {
            
            timer.invalidate()
            
        }
        
    }
    
    func resetRecordingState() {
        
        setButtonBgImage(button: recordBtn, bgImage: recordIcon)

        adjustThinkTimeBtn.text = "\(defaultThinkTime)"
        adjustSpeakTimeBtn.text = "\(defaultSpeakTime)"
        
        isRecording = false
        blinking = false
        
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
    
    func setBtnImgProp(button: UIButton, topPadding: CGFloat, leftPadding: CGFloat) {
        button.imageView?.contentMode = .scaleAspectFit
        button.contentEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding, leftPadding)
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
    
    func getAudioFilesList(date: String) -> [URL] {
        
        guard let urlList = dateSortedRecordingList[date] else {return [URL]()}
        
        return urlList
    }
    
    func mergeAudioFiles(audioFileUrls: [URL],completion: @escaping () -> ()) {
        
        do {
            try FileManager.default.removeItem(at: getMergedFileURL())
            
        } catch let error as NSError {
            print("Error Deleting Merged Audio:\n\(error.domain)")
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

            exportSelectedBtn.setTitle("Export \(exportSelected.count) recording(s)", for: .normal)
            
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
       
        if (playPauseButton != nil) {
            setButtonBgImage(button: self.playPauseButton!, bgImage: playBtnIcon)
            isPlaying = false
            playingRecordingURL = nil
            audioPlayer?.stop()
        }
    }
    
    func playRecording(url: URL, button: UIButton){
        
        if isRecording { return }
        
        if (url != playingRecordingURL) {
            
            if (playPauseButton == nil ) {
                playPauseButton = button
            }
            
            setButtonBgImage(button: self.playPauseButton!, bgImage: playBtnIcon)
            playPauseButton = button
            setButtonBgImage(button: self.playPauseButton!, bgImage: pauseBtnIcon)
        
            isPlaying = true
            playingRecordingURL = url
            
            do{
                
                audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: playingRecordingURL!)
                audioPlayer?.delegate = self
                
                guard let audioPlayer = audioPlayer else { return }
    
                audioPlayer.prepareToPlay()
    
                audioPlayer.play()
                
            } catch let error as NSError {
                print("Error Playing\n",error.localizedDescription)
                
            }
            
        } else if (isPlaying) {
            
            audioPlayer?.pause()
            isPlaying = false
            setButtonBgImage(button: self.playPauseButton!, bgImage: playBtnIcon)
            
        } else if (!isPlaying) {

            audioPlayer?.play()
            isPlaying = true
            setButtonBgImage(button: self.playPauseButton!, bgImage: pauseBtnIcon)
        }
    }
    
    func setButtonBgImage(button: UIButton, bgImage: UIImage) {
        
        DispatchQueue.main.async {
            button.setImage(bgImage, for: .normal)
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        playingRecordingURL = nil
        isPlaying = false
        setButtonBgImage(button: self.playPauseButton!, bgImage: playBtnIcon)
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
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
            
            let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
            
            let timestamp = Int(round((NSDate().timeIntervalSince1970)))
            
            var path = ""
            
            print("Is test mode: \(isTestMode)")
            
            if isTestMode {
                
                path =  "\(timestamp)_0_\(thinkTime)."+recordingExtension

            } else {
                path =  "\(timestamp)_\(topicNumber)_\(thinkTime)."+recordingExtension
            }
            
            
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
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        updateURLList()
        
        topicNumber += 1
        renderTopic(topicNumber: topicNumber, saveDefault: true)
        recordingTableView.reloadData()
        recordingTableView.reloadData()

        resetRecordingState()
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
            
            let recordings = dateSortedRecordingList.sorted{$0.0 > $1.0}[indexPath.section]
            
            let url = recordings.value.sorted(by: { (url1, url2) -> Bool in
                
                var timeStamp1: Int
                var timeStamp2: Int
                
                (timeStamp1,_,_) = splitFileURL(url: "\(url1)")
                (timeStamp2,_,_) = splitFileURL(url: "\(url2)")
                
                return timeStamp1 > timeStamp2
                
            })[indexPath.row]
            
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
