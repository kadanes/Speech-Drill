//
//  MainVC.swift
//  TOEFL Speaking
//
//  Created by Parth Tamane on 31/07/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation
import Mute

class MainVC: UIViewController {
   
    @IBOutlet weak var adjustThinkTimeBtn: UILabel!
    @IBOutlet weak var adjustSpeakTimeBtn: UILabel!
    
    
    @IBOutlet weak var thinkTimeChangeStackView: UIStackView!

    @IBOutlet weak var switchModesBtn: RoundButton!
    
    @IBOutlet weak var displayInfoBtn: UIButton!
    
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
    
    @IBOutlet weak var exportSelectedActivityIndicator: UIActivityIndicatorView!
    
     @IBOutlet weak var playSelectedActivityIndicator: UIActivityIndicatorView!
    
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
    
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    
    var dateSortedRecordingList: Dictionary<String,Array<URL>> = [:]
    
    var exportSelected = [URL]()

    var mergeAudioURL: URL?

    let userDefaults = UserDefaults.standard
    
    var thinkTimer: Timer?
    
    
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetRecordingState()

        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        updateURLList()
        
        readTopics()
        
        exportSelectedActivityIndicator.stopAnimating()
        
        topicNumber = userDefaults.integer(forKey: "topicNumber")
        
        renderTopic(topicNumber: topicNumber)
     
        setBtnImgProp(button: loadNextTopicBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextTenthTopicBtn ,topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadNextFiftiethTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousTenthTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        setBtnImgProp(button: loadPreviousFiftiethTopicBtn , topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: playSelectedBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: recordBtn,topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: closeShareMenuBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
    
        setBtnImgProp(button: cancelRecordingBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
        setBtnImgProp(button: displayInfoBtn, topPadding: buttonVerticalInset, leftPadding: buttonHorizontalInset)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        recordingTableView.reloadData()
    }
    
    func readTopics() {
        do{
            let fileURL = Bundle.main.url(forResource: "topics", withExtension: "csv")
            let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
            topics = content.components(separatedBy:"\n").map{$0}
            
        } catch {
            
        }
    }
    
    func renderTopic(topicNumber: Int) {
       
        userDefaults.set(topicNumber, forKey: "topicNumber")
        
        self.topicNumber = topicNumber
        
        UIView.animate(withDuration: 1) {
            
            self.topicLbl.text = self.topics[topicNumber]
            self.topicNumberLbl.text = "\(topicNumber)"
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
            renderTopic(topicNumber: topicNumber)
            
            defaultThinkTime = 15
            defaultSpeakTime = 45
            thinkTime = defaultThinkTime
            speakTime = defaultSpeakTime
            
        } else {
            
            self.switchModesBtn.setTitle("Test", for: .normal)
            self.thinkTimeChangeStackView.isHidden = false
            changeTopicBtnsStackView.isHidden = true
            
            topicLbl.text = "TEST MODE"
            
        }
        
        isTestMode = !isTestMode
        
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
    
    ///Increment current displayed topic number by 1
    func incrementTopicNumber() {
        
        topicNumber = topicNumber + 1 < topics.count ? topicNumber + 1 : topicNumber
    }
    
    ///Increment current displayed topic number base on button pressed
    @IBAction func nextQuestionTapped(_ sender: UIButton) {
        let increment = sender.tag
        topicNumber = (topicNumber + increment < topics.count) ? topicNumber + increment : topics.count - 1
        
        renderTopic(topicNumber: topicNumber)
        
    }
    
    ///Decrement current displayed topic number base on button pressed
    @IBAction func previousQuestionTapped(_ sender: UIButton) {
        let decrement = sender.tag
        topicNumber = (topicNumber - decrement > 0) ? topicNumber - decrement : 1
        
        renderTopic(topicNumber: topicNumber)

    }
    
    ///Start recording of speech
    @IBAction func startRecordingPressed(_ sender: Any) {
        
        CentralAudioPlayer.player.stopPlaying()
        
        if (!isRecording) {
            isRecording = true
            
            cancelRecordingBtn.isHidden = false
            
            thinkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementThinkTime), userInfo: nil, repeats: true)
        }
    }
    
    ///Stop recording if within think time
    @IBAction func cancelRecordingTapped(_ sender: Any) {
        
        if (thinkTime > 0) {
            
            cancelRecordingBtn.isHidden = true

            thinkTimer?.invalidate()
            resetRecordingState()
        }
    }
    
    ///Function to reduce and render think time
    @objc func decrementThinkTime(timer: Timer) {
        if(thinkTime > 0) {
            thinkTime -= 1
            
            adjustThinkTimeBtn.text = "\(thinkTime)"
            
        } else {
            
            timer.invalidate()
            cancelRecordingBtn.isHidden = true
            
            thinkTime = defaultThinkTime
            
            do{
                let alertSound = URL(fileURLWithPath: getPath(fileName: "speak_now.mp3")!)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound)
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                
                while (audioPlayer?.isPlaying)! {
                    
                }
            } catch let error as NSError {
                print("Error Playing Speak Now:\n",error.localizedDescription)
            }
            
            recordAudio()
            
            let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementSpeakTime), userInfo: nil, repeats: true)
            let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkRecordBtn), userInfo: nil, repeats: true)
            
        }
    }
    
    ///Function to reduce and render speak time
    @objc func decrementSpeakTime(timer: Timer) {
        
        if(speakTime > 0) {
            speakTime -= 1
            adjustSpeakTimeBtn.text = "\(speakTime)"
        } else {
            
            timer.invalidate()
            speakTime = defaultSpeakTime
            
        }
    }
    
    ///Function to make recording logo blink
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
    
    ///Reset display of think and speak time
    func resetRecordingState() {
        
        setButtonBgImage(button: recordBtn, bgImage: recordIcon)
        adjustThinkTimeBtn.text = "\(defaultThinkTime)"
        adjustSpeakTimeBtn.text = "\(defaultSpeakTime)"
        
        isRecording = false
        blinking = false
    }
    
    ///Update local list with newly added recording urls
    func updateURLList() {
                
        dateSortedRecordingList.removeAll()
        
        let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
        
        if let files = FileManager.default.enumerator(atPath: "\(documents)") {

            for file in files {

                let recordingName = "\(file)"

                if recordingName.hasSuffix("."+recordingExtension) {

                    if (recordingName != mergedFileName) {
                        
                        let timeStamp = splitFileURL(url: recordingName).0
                        
                        let date = parseDate(timeStamp: timeStamp)
                        
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
    
    ///Fetch a list of recordings urls for a day
    func getAudioFilesList(date: String) -> [URL] {
        
        guard let urlList = dateSortedRecordingList[date] else {return [URL]()}
        
        return urlList
    }
    
    ///Show or Hide export menu
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
    
    ///Add a recording url to list of recordings to export
    func addToExportList(url: URL) {
        CentralAudioPlayer.player.stopPlaying()
        exportSelected.append(url)
    }
    
    ///Remove a recording url to list of recordings to export
    func removeFromExportList(url: URL) {
        CentralAudioPlayer.player.stopPlaying()
        exportSelected = exportSelected.filter {$0 != url}
    }
    
    ///Remove all selected recordings and reset UI
    func clearSelected() {
        exportSelected.removeAll()
        toggleExportMenu()
        recordingTableView.reloadData()
    }
    
    ///Export selected recordings
    @IBAction func exportSelectedTapped(_ sender: UIButton) {
        
        if (playSelectedActivityIndicator.isAnimating) {
            return
        }
        
        processMultipleRecordings(recordingsList: exportSelected, activityIndicator: exportSelectedActivityIndicator) { (exportURL) in
            CentralAudioPlayer.player.stopPlaying()

            openShareSheet(url: exportURL, activityIndicator: self.exportSelectedActivityIndicator){
                self.clearSelected()
                
            }
        }
    }
    
    ///Play selected recordings
    @IBAction func playSelectedAudioTapped(_ sender: UIButton) {
        
        if isRecording || exportSelectedActivityIndicator.isAnimating {return}
        
        processMultipleRecordings(recordingsList: exportSelected, activityIndicator: playSelectedActivityIndicator) { (playURL) in
            
            DispatchQueue.main.async {
                self.playSelectedActivityIndicator.stopAnimating()
            }
            
            CentralAudioPlayer.player.playRecording(url: playURL, id: selectedAudioId , button: sender, iconId: "y")
        }
        
    }
    
    ///Hide export menu
    @IBAction func cancelSelectedTapped(_ sender: UIButton) {
        clearSelected()
        CentralAudioPlayer.player.stopPlaying()
    }
}

extension MainVC: AVAudioRecorderDelegate {
    
    func recordAudio() {
        
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
            
            let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
            
            let timestamp = Int(round((NSDate().timeIntervalSince1970)))
            
            var path = ""
            
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
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        Toast.show(message: "Recorded successfully!", success: true)
        
        updateURLList()
        
        if !isTestMode {
            
            incrementTopicNumber()
            renderTopic(topicNumber: topicNumber)
        }
        
        recordingTableView.reloadData()
        //Possible fix for check box bg properties not reflecting
        recordingTableView.reloadData()

        resetRecordingState()
    }
}

extension MainVC:UITableViewDataSource,UITableViewDelegate {
    
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
            
            let url = sortUrlList(recordingsURLList: recordings.value)[indexPath.row]
            
            cell.configureCell(url: url)
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
