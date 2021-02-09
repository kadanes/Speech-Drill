//
//  MainVCAudioRecorder.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import AVFoundation

extension MainVC: AVAudioRecorderDelegate {
    
    func recordAudio() {
        logger.info()
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
                AVLinearPCMBitDepthKey: 16,
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
        logger.info()
        if !cancelledRecording{
            Toast.show(message: "Recorded successfully!",type: .Success)
            if let url = currentRecordingURL {
                insertRow(with: url)
            }
            if !isTestMode {
                incrementTopicNumber()
                renderTopic(topicNumber: topicNumber)
            }
        } else {
            cancelledRecording = false
        }
        
        resetRecordingState()
        setHiddenVisibleSectionList()
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        logger.info()
        cancelRecording()
    }
    
    ///Reset display of think and speak time
    func resetRecordingState() {
        logger.info()
        if reducedTime {
            defaultSpeakTime = 2
            defaultThinkTime = 2
        }
        
        thinkTime = defaultThinkTime
        speakTime = defaultSpeakTime
        
        setButtonBgImage(button: recordBtn, bgImage: recordIcon, tintColor: .red)
        thinkTimeLbl.text = "\(defaultThinkTime)"
        speakTimeLbl.text = "\(defaultSpeakTime)"
        cancelRecordingBtn.isHidden = true
        
        thinkTimer?.invalidate()
        speakTimer?.invalidate()
        blinkTimer?.invalidate()
        
        isRecording = false
        isThinking = false
        blinking = false
        
        DispatchQueue.main.async {
            //            self.speakTimeInfoView.backgroundColor = .clear
            //            self.thinkTimeInfoView.backgroundColor = .clear
            self.thinkTimeLbl.textColor = accentColor
            self.thinkLbl.textColor = accentColor
            self.speakTimeLbl.textColor = accentColor
            self.speakLbl.textColor = accentColor
        }
    }
    
    ///Check if user is recording a topic
    func checkIfRecordingIsOn() -> Bool {
        logger.info()
        return isThinking || isRecording
    }
    
    func cancelRecording() {
        logger.info()
        if isRecording {
            audioRecorder.stop()
            resetRecordingState()
            cancelledRecording = true
            if let url = currentRecordingURL {
                let _ = deleteStoredRecording(recordingURL: url)
                reloadData()
            }
        } else {
            resetRecordingState()
        }
    }
    
}
