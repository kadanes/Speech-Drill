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
import CallKit
import CoreTelephony

class MainVC: UIViewController {
   
    @IBOutlet weak var adjustThinkTimeBtn: UILabel!
    @IBOutlet weak var adjustSpeakTimeBtn: UILabel!
    
    @IBOutlet weak var thinkTimeChangeStackViewSeperator: UIView!
    
    @IBOutlet weak var thinkTimeChangeStackViewContainer: UIView!
    
    @IBOutlet weak var thinkTimeChangeStackView: UIStackView!

    @IBOutlet weak var switchModesBtn: RoundButton!
    
    @IBOutlet weak var displayInfoBtn: UIButton!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cancelRecordingBtn: UIButton!
    
    @IBOutlet weak var topicTxtView: UITextView!
    
    @IBOutlet weak var topicNumberLbl: UILabel!
    
    @IBOutlet weak var changeTopicBtnsStackView: UIStackView!
    
    @IBOutlet weak var loadNextTopicBtn: RoundButton!
    @IBOutlet weak var loadNextTenthTopicBtn: RoundButton!
    @IBOutlet weak var loadNextFiftiethTopicBtn: RoundButton!
    
    @IBOutlet weak var loadPreviousTopicBtn: RoundButton!
    @IBOutlet weak var loadPreviousTenthTopicBtn: RoundButton!
    @IBOutlet weak var loadPreviousFiftiethTopicBtn: RoundButton!
    
    @IBOutlet weak var recordingTableView: UITableView!
    
    //Export Menu
    @IBOutlet weak var exportMenuView: UIView!
    @IBOutlet weak var exportMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var exportSelectedBtn: UIButton!
    @IBOutlet weak var exportSelectedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playSelectedBtn: UIButton!
    @IBOutlet weak var playSelectedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exportMenuStackView: UIStackView!
    @IBOutlet weak var closeShareMenuBtn: UIButton!
    @IBOutlet weak var exportSeekerView: UIView!
    @IBOutlet weak var exportCurrentPlayTimeLbl: UILabel!
    @IBOutlet weak var exportPlayingSeeker: UISlider!
    @IBOutlet weak var totalPlayTimeLbl: UILabel!
    
    var isTestMode = false
    var defaultThinkTime = 15
    var defaultSpeakTime = 45
    var thinkTime = 15
    var speakTime = 45

    var topicNumber = 0
    var topics: [String] = []
    
    var isPlaying = false
    var isRecording = false
    var isThinking = false
    var blinking = true
    var cancelledRecording = false
    var currentRecordingURL: URL?
    
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    
    var recordingUrlsDict: Dictionary<String,Array<URL>> = [:]
    
    var hiddenSections = [String]()
    var visibleSections = [String]()
    
    private var recordingUrlsListToExport = [URL]()
    
    let userDefaults = UserDefaults.standard
    
    var thinkTimer: Timer?
    var speakTimer: Timer?
    var blinkTimer: Timer?
    weak var exportPlayBackTimer: Timer?
    
    private var audioPlayer: AVAudioPlayer?
    
    var callObserver = CXCallObserver()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        callObserver.setDelegate(self, queue: nil)
        
        resetRecordingState()

        updateURLList()
        readTopics()
        topicNumber = userDefaults.integer(forKey: "topicNumber")
        renderTopic(topicNumber: topicNumber)
        
        exportSelectedActivityIndicator.stopAnimating()
        
        setUIButtonsProperty()
        setHiddenVisibleSectionList()
        toggleExportMenu()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        recordingTableView.reloadData()
    }
    
    func setUIButtonsProperty() {
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
    
    func readTopics() {
        do{
            let fileURL = Bundle.main.url(forResource: "topics", withExtension: "csv")
            let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
            topics = content.components(separatedBy:"\n").map{$0}
        } catch {
            
        }
    }
    
    func renderTopic(topicNumber: Int) {
        var topicNumberToShow = 1
        if ( topicNumber > topics.count - 1) {
            topicNumberToShow = topics.count - 1
        } else {
            topicNumberToShow = topicNumber
        }
        topicTxtView.setContentOffset(.zero, animated: true)
        userDefaults.set(topicNumberToShow, forKey: "topicNumber")
        self.topicNumber = topicNumberToShow
        topicTxtView.text = topics[topicNumberToShow]
        topicNumberLbl.text = "\(topicNumberToShow)"
    }
    
    @IBAction func switchModesTapped(_ sender: UIButton) {
        let pulse = Pulsing(numberOfPulses: 1, radius: sender.layer.bounds.width, position: sender.center)
        sender.layer.addSublayer(pulse)
        switchModes()
    }
    
    func switchModes() {
        
        if isRecording {return}
        
        if isTestMode {
            thinkTimeChangeStackViewContainer.isHidden = true
            thinkTimeChangeStackViewSeperator.isHidden = true
            
            switchModesBtn.setTitle("Practice", for: .normal)
            changeTopicBtnsStackView.isHidden = false
            renderTopic(topicNumber: self.topicNumber)
            defaultThinkTime = 15
            defaultSpeakTime = 45
            thinkTime = defaultThinkTime
            speakTime = defaultSpeakTime
            
        } else {
            thinkTimeChangeStackViewContainer.isHidden = false
            thinkTimeChangeStackViewSeperator.isHidden = false
            
            self.switchModesBtn.setTitle("Test", for: .normal)
            self.changeTopicBtnsStackView.isHidden = true
            self.topicTxtView.text = "TEST MODE"
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

        if checkIfRecordingIsOn() {return}
       
        let pulse = Pulsing(numberOfPulses: 1, radius: sender.layer.bounds.width, position: CGPoint(x: sender.bounds.width/2, y: sender.bounds.height/2))
        sender.layer.addSublayer(pulse)
       

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
        let pulse = Pulsing(numberOfPulses: 1, radius: sender.layer.bounds.width, position: CGPoint(x:sender.bounds.width/2, y:sender.bounds.height/2))
        sender.layer.addSublayer(pulse)
        
        let increment = sender.tag
        topicNumber = (topicNumber + increment < topics.count) ? topicNumber + increment : topics.count - 1
        renderTopic(topicNumber: topicNumber)
    }
    
    ///Decrement current displayed topic number base on button pressed
    @IBAction func previousQuestionTapped(_ sender: UIButton) {
        let pulse = Pulsing(numberOfPulses: 1, radius: sender.layer.bounds.width, position: CGPoint(x:sender.bounds.width/2, y:sender.bounds.height/2))
        sender.layer.addSublayer(pulse)
        
        let decrement = sender.tag
        topicNumber = (topicNumber - decrement >= 1) ? topicNumber - decrement : 1
        renderTopic(topicNumber: topicNumber)
    }
    
    ///Start recording of speech
    @IBAction func startRecordingPressed(_ sender: Any) {
        
        CentralAudioPlayer.player.stopPlaying()
        
        if (!checkIfRecordingIsOn()) {
            
            cancelRecordingBtn.isHidden = false
            thinkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementThinkTime), userInfo: nil, repeats: true)
        }
    }
    
    ///Stop recording 
    @IBAction func cancelRecordingTapped(_ sender: Any) {
        cancelRecording()
    }
    
    func cancelRecording() {
        if isRecording {
            
            audioRecorder.stop()
            resetRecordingState()
            cancelledRecording = true
            
            if let url = currentRecordingURL {
                deleteStoredRecording(recordingURL: url)
                reloadData()
            }
        } else {
            resetRecordingState()
        }
    }
    
    ///Function to reduce and render think time
    @objc func decrementThinkTime(timer: Timer) {
        if(thinkTime > 0) {
            isThinking = true
            thinkTime -= 1
            adjustThinkTimeBtn.text = "\(thinkTime)"
        } else {
            
            timer.invalidate()
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
            
            isThinking = false
            recordAudio()
            
            speakTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementSpeakTime), userInfo: nil, repeats: true)
            blinkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkRecordBtn), userInfo: nil, repeats: true)
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
        
        thinkTime = defaultThinkTime
        speakTime = defaultSpeakTime
        
        setButtonBgImage(button: recordBtn, bgImage: recordIcon)
        adjustThinkTimeBtn.text = "\(defaultThinkTime)"
        adjustSpeakTimeBtn.text = "\(defaultSpeakTime)"
        cancelRecordingBtn.isHidden = true

        thinkTimer?.invalidate()
        speakTimer?.invalidate()
        blinkTimer?.invalidate()
        
        isRecording = false
        isThinking = false
        blinking = false
    }
    
    ///Check if user is recording a topic
    func checkIfRecordingIsOn()->Bool{
        return isThinking || isRecording
    }
    
    ///Update local list with newly added recording urls
    func updateURLList() {
                
        recordingUrlsDict.removeAll()
        
        let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
        
        if let files = FileManager.default.enumerator(atPath: "\(documents)") {

            for file in files {

                let recordingName = "\(file)"

                if recordingName.hasSuffix("."+recordingExtension) {

                    if (recordingName != mergedFileName) {
                        
                        let timeStamp = splitFileURL(url: recordingName).0
                        
                        let date = parseDate(timeStamp: timeStamp)
                        
                        let url = URL(fileURLWithPath: documents+"/"+"\(file)")
                        
                        var recordingURLs = recordingUrlsDict[date]
                        
                        if recordingURLs == nil {
                            recordingURLs = [URL]()
                        }
                        
                        if (url == currentRecordingURL && !isRecording || url != currentRecordingURL){
                            recordingURLs?.append(url)
                        }
                        
                        if (recordingURLs?.count)! > 0 {
                            recordingUrlsDict[date] = recordingURLs
                        }
                        
                    }
                }
            }
        }
    }
    
    func setHiddenVisibleSectionList() {
        let dateSortedKeys = recordingUrlsDict.keys.sorted { (date1, date2) -> Bool in
            guard let convertedDate1 = convertToDate(date: date1) else { return false }
            guard let convertedDate2 = convertToDate(date: date2) else { return false }
            return convertedDate1 > convertedDate2
        }
        if dateSortedKeys.count == 0 {return}

        if visibleSections.count == 0 {
            visibleSections.append(dateSortedKeys[0])
            for ind in 1..<dateSortedKeys.count {
                hiddenSections.append(dateSortedKeys[ind])
            }
        } else {
            if !visibleSections.contains(dateSortedKeys[0]) {
                showSection(date: dateSortedKeys[0])
            }
        }
    }
    
    func toggleSection(date: String) {
        if visibleSections.contains(date) {
            hideSection(date: date)
        } else {
            showSection(date: date)
        }
        reloadData()
        
        if visibleSections.contains(date) {
            DispatchQueue.main.async {
                let dateSortedKeys = self.recordingUrlsDict.keys.sorted { (date1, date2) -> Bool in
                    guard let convertedDate1 = convertToDate(date: date1) else { return false }
                    guard let convertedDate2 = convertToDate(date: date2) else { return false }
                    return convertedDate1 > convertedDate2
                }
                
                guard let sectionInd = dateSortedKeys.index(of : date) else { return }
                let indexPath = IndexPath(row: 0, section: sectionInd)
                self.recordingTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }

    func hideSection(date: String) {
        visibleSections = visibleSections.filter {$0 != date}
        hiddenSections.append(date)
    }
    
    func showSection(date: String) {
        hiddenSections = hiddenSections.filter{$0 != date}
        visibleSections.append(date)
    }
    
    func checkIfHidden(date:String) -> Bool {
        return hiddenSections.contains(date)
    }
    
    ///Fetch a list of recordings urls for a day
    func getAudioFilesList(date: String) -> [URL] {
        guard let urlList = recordingUrlsDict[date] else {return [URL]()}
        return urlList
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
                path =  "\(timestamp)_\(testModeId)_\(thinkTime)."+recordingExtension
            } else {
                path =  "\(timestamp)_\(topicNumber)_\(thinkTime)."+recordingExtension
            }
            
            let fullRecordingPath = (documents as NSString).appendingPathComponent(path)
            
            let url = NSURL.fileURL(withPath: fullRecordingPath)
            
            currentRecordingURL = url
            
            let recordSettings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ] as [String : Any]
            
            do{
                isRecording = true
                audioRecorder = try AVAudioRecorder(url:url, settings: recordSettings)
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                audioRecorder.record(forDuration: Double(defaultSpeakTime))
            
            } catch let error as NSError {
                resetRecordingState()
               
                print("Error with recording")
                print(error.localizedDescription)
            }
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !cancelledRecording{
            Toast.show(message: "Recorded successfully!", success: true)
            if !isTestMode {
                incrementTopicNumber()
                renderTopic(topicNumber: topicNumber)
            }
        } else {
            cancelledRecording = false
        }
        
        resetRecordingState()
        updateURLList()
        setHiddenVisibleSectionList()
        reloadData()
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        cancelRecording()
    }
}

extension MainVC:UITableViewDataSource,UITableViewDelegate {
    
    func reloadData() {
        updateURLList()
        DispatchQueue.main.async {
             self.recordingTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recordingUrlsDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedRecordingUrls = sortDict(recordingUrlsDict: recordingUrlsDict)
        if (visibleSections.contains(sortedRecordingUrls[section].key)){
            return sortedRecordingUrls[section].value.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId) as? SectionHeaderCell {
            let date = sortDict(recordingUrlsDict: recordingUrlsDict)[section].key
            cell.delegate = self
            cell.configureCell(date: date)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let dateSortedKeys = recordingUrlsDict.keys.sorted { (date1, date2) -> Bool in
            guard let convertedDate1 = convertToDate(date: date1) else { return false }
            guard let convertedDate2 = convertToDate(date: date2) else { return false }
            return convertedDate1 > convertedDate2
        }
        
        let date = dateSortedKeys[section]
        var isSectionRecordingsPlaying = false
        
        if recordingUrlsDict[date]?.count == 1 {
            guard let url = recordingUrlsDict[date]?[0] else { return sectionHeaderHeight }
            isSectionRecordingsPlaying = CentralAudioPlayer.player.checkIfPlaying(url: url, id: date)
        } else {
             isSectionRecordingsPlaying = CentralAudioPlayer.player.checkIfPlaying(url: getMergedFileURL(), id: date)
        }
       
        if isSectionRecordingsPlaying {
            return expandedSectionHeaderHeight
        }
        return sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let recordings = sortDict(recordingUrlsDict: recordingUrlsDict)[indexPath.section]
        let url = sortUrlList(recordingsURLList: recordings.value)[indexPath.row]
        let timeStamp = splitFileURL(url: "\(url)").timeStamp
       
        let isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: url, id: "\(timeStamp)")
        if isPlaying {
            return expandedRecordingCellHeight
        }
        return recordingCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: recordingCellId) as? RecordingCell {
            
            let recordings = sortDict(recordingUrlsDict: recordingUrlsDict)[indexPath.section]
            let url = sortUrlList(recordingsURLList: recordings.value)[indexPath.row]
            
            cell.configureCell(url: url)
            cell.delegate = self
            
            if(recordingUrlsListToExport.contains(url)) {
                cell.selectCheckBox()
            } else {
                cell.deselectCheckBox()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    ///Stoppping the running timers in recording cell
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: recordingCellId) as? RecordingCell{
            cell.disableTimer()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId) as? RecordingCell{
            cell.disableTimer()
        }
    }
}

//MARK :- Check for call interrupt
extension MainVC: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        if call.hasEnded == true {
            print("Disconnected")
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
             cancelRecording()
        }
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
        }
    }
}

//MARK:- Export Menu
extension MainVC {
    
    ///Show or Hide export menu
    func toggleExportMenu() {
        if recordingUrlsListToExport.count > 0 {
            DispatchQueue.main.async {
                self.exportMenuStackView.isHidden = false
                self.exportSelectedBtn.setTitle("Export \(self.recordingUrlsListToExport.count) recording(s)", for: .normal)
                self.toggleSeeker()
            }
        } else {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = true
                self.exportMenuStackView.isHidden = true
            }
        }
    }
    
    func toggleSeeker() {
        isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: selectedAudioId)
        if isPlaying {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = false
            }
            configureExportMenuPlayBackSeeker()
            setButtonBgImage(button: playSelectedBtn, bgImage: pauseBtnYellowIcon)
        } else {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = true
            }
            setButtonBgImage(button: playSelectedBtn, bgImage: playBtnYellowIcon)
            if let _ = exportPlayBackTimer {
                exportPlayBackTimer?.invalidate()
                exportPlayBackTimer = nil
            }
        }
    }
    
    ///Add a recording url to list of recordings to export
    func addToExportList(url: URL) {
        CentralAudioPlayer.player.stopPlaying()
        recordingUrlsListToExport.append(url)
        toggleExportMenu()
    }
    
    ///Remove a recording url to list of recordings to export
    func removeFromExportList(url: URL) {
        CentralAudioPlayer.player.stopPlaying()
        recordingUrlsListToExport = recordingUrlsListToExport.filter {$0 != url}
        toggleExportMenu()
    }
    
    ///Remove all selected recordings and reset UI
    func clearSelected() {
        recordingUrlsListToExport.removeAll()
        toggleExportMenu()
        reloadData()
    }
    
    ///Export selected recordings
    @IBAction func exportSelectedTapped(_ sender: UIButton) {
        if (playSelectedActivityIndicator.isAnimating) {
            return
        }
        
        processMultipleRecordings(recordingsList: recordingUrlsListToExport, activityIndicator: exportSelectedActivityIndicator) { (exportURL) in
            CentralAudioPlayer.player.stopPlaying()
            openShareSheet(url: exportURL, activityIndicator: self.exportSelectedActivityIndicator){
                self.clearSelected()
            }
        }
    }
    
    ///Play selected recordings
    @IBAction func playSelectedAudioTapped(_ sender: UIButton) {
        
        if isRecording || exportSelectedActivityIndicator.isAnimating {return}
        
        processMultipleRecordings(recordingsList: recordingUrlsListToExport, activityIndicator: playSelectedActivityIndicator) { (playURL) in
            
            DispatchQueue.main.async {
                self.playSelectedActivityIndicator.stopAnimating()
            }
            
            CentralAudioPlayer.player.playRecording(url: playURL, id: selectedAudioId)
            self.isPlaying = CentralAudioPlayer.player.checkIfPlaying(url: playURL, id: selectedAudioId)
            if (self.isPlaying) {
                setButtonBgImage(button: sender, bgImage: pauseBtnYellowIcon)
            } else {
                setButtonBgImage(button: sender, bgImage: playBtnYellowIcon)
            }
            self.toggleSeeker()
        }
    }
    
    ///Hide export menu
    @IBAction func cancelSelectedTapped(_ sender: UIButton) {
        CentralAudioPlayer.player.stopPlaying()
        clearSelected()
    }
    
    ///Set properties of playback seeker view
    func configureExportMenuPlayBackSeeker() {
        if isPlaying {
            
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = false
                self.exportPlayingSeeker.setThumbImage(drawSliderThumb(diameter: normalThumbDiameter, backgroundColor: UIColor.white), for: .normal)
                self.exportPlayingSeeker.setThumbImage(drawSliderThumb(diameter: highlightedThumbDiameter, backgroundColor: UIColor.yellow), for: .highlighted)
                
                let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
                let totalTime = CentralAudioPlayer.player.getPlayBackDuration();
                
                self.exportPlayingSeeker.maximumValue = Float(totalTime)
                self.exportPlayingSeeker.minimumValue = Float(0.0)
                self.exportPlayingSeeker.value = Float(currentTime)
                self.exportCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
                self.totalPlayTimeLbl.text = convertToMins(seconds: totalTime)
                
                self.exportPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateExportPlaybackTime), userInfo: nil, repeats: true)
            }
        } else {
            DispatchQueue.main.async {
                self.exportSeekerView.isHidden = true
            }
        }
    }
    
    @objc func updateExportPlaybackTime(timer: Timer) {
        
        if !CentralAudioPlayer.player.checkIfPlaying(id: selectedAudioId) {
            timer.invalidate()
            toggleSeeker()
        }
        let currentTime = CentralAudioPlayer.player.getPlayBackCurrentTime();
        
        DispatchQueue.main.async {
            self.exportCurrentPlayTimeLbl.text = convertToMins(seconds: currentTime)
            self.exportPlayingSeeker.value = Float(currentTime)
        }
    }
    
    ///On slider touchdown invalidate the update timer
    @IBAction func headerStopPlaybackUIUpdate(_ sender: UISlider) {
        exportPlayBackTimer?.invalidate()
        exportPlayBackTimer = nil
        sender.minimumTrackTintColor = UIColor.yellow
    }
    
    ///On value change play to new time
    @IBAction func headerUpdatePlaybackTimeWithSlider(_ sender: UISlider) {
        let playbackTime = Double(sender.value)
        DispatchQueue.main.async {
            self.exportCurrentPlayTimeLbl.text = convertToMins(seconds: playbackTime)
            CentralAudioPlayer.player.setPlaybackTime(playTime: playbackTime)
            sender.minimumTrackTintColor = UIColor.yellow
        }
    }
    
    ///On touch up fire the playback time update timer
    @IBAction func headerStartPlaybackUIUpdate(_ sender: UISlider) {
        exportPlayBackTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateExportPlaybackTime), userInfo: nil, repeats: true)
        DispatchQueue.main.async {
            sender.minimumTrackTintColor = UIColor.white
        }
    }
}

