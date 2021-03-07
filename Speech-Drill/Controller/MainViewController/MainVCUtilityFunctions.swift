//
//  MainVCUtilityFunctions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import UIKit

//MARK:- Utility Functions
extension MainVC {
    
    func countNumberOfRecordings() -> Int {
        logger.info("Counting number of recordings")
        
        let datedRecordingsCount = recordingUrlsDict.values.map { $0.count }
        let recordingsCount = datedRecordingsCount.reduce(0, { $0 + $1 })
        return recordingsCount
    }
    
    
    ///Update local list with newly added recording urls
    func updateUrlList() {
        logger.info("Updating url list")

        recordingUrlsDict.removeAll()
        
        let documents = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0]
        
        if let files = FileManager.default.enumerator(atPath: "\(documents)") {
            
            for file in files  {
                
                guard let fileUrl = URL(string: "\(file)") else { break }
                
                let recordingName = "\(file)"
                
                if recordingName.hasSuffix("."+recordingExtension) {
                    
                    if (recordingName != mergedFileName) {
                        
                        let timeStamp = splitFileURL(url: fileUrl).0
                        
                        let date = parseDate(timeStamp: timeStamp)
                        
                        let url = URL(fileURLWithPath: documents+"/"+"\(file)")
                        
                        var recordingURLs = recordingUrlsDict[date, default: [URL]()]
                        
                        //                        if recordingURLs == nil {
                        //                            recordingURLs = [URL]()
                        //                        }
                        
                        if (url == currentRecordingURL && !isRecording || url != currentRecordingURL){
                            recordingURLs.append(url)
                        }
                        
                        if (recordingURLs.count) > 0 {
                            recordingUrlsDict[date] = recordingURLs
                        }
                        
                    }
                }
            }
        }
        
        logger.debug("Number of recordings: \(countNumberOfRecordings())")
        userDefaults.setValue(countNumberOfRecordings(), forKey: recordingsCountKey)
        saveCurrentNumberOfSavedRecordings()
    }
    
    ///Fetch a list of recordings urls for a day
    func getAudioFilesList(date: String) -> [URL] {
        logger.info("Getting list or recordings urls for \(date)")
        
        return recordingUrlsDict[date, default: [URL]()]
    }
    
    func readTopics() {
        logger.info("Reading topics")
        
        do{
            let fileURL = Bundle.main.url(forResource: "topics", withExtension: "csv")
            let content = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
            topics = content.components(separatedBy:"\n").map{$0}
        } catch {
            
        }
    }
    
    ///Increment current displayed topic number by 1
    func incrementTopicNumber() {
        logger.info("Incrementing topic number")
        
        topicNumber = min(topicNumber + 1, topics.count)
        //topicNumber + 1 < topics.count ? topicNumber + 1 : topicNumber
    }
    
    func renderTopic(topicNumber: Int) {
        logger.info("Rendering topic number \(topicNumber)")
        
        var topicNumberToShow = 1
        if ( topicNumber > topics.count - 1) {
            topicNumberToShow = topics.count - 1
        } else {
            topicNumberToShow = topicNumber
        }
        userDefaults.set(topicNumberToShow, forKey: "topicNumber")
        self.topicNumber = topicNumberToShow
        topicTxtView.text = topics[topicNumberToShow]
        topicNumberLbl.text = "\(topicNumberToShow)"
    }
    
    
    func switchModes() {
        logger.info("Switching recording modes")
        
        if checkIfRecordingIsOn() {return}
        
        title = isTestMode ? "Practice Mode" : "Test Mode"
        
        switchModeButton.setImage(isTestMode ? practiceModeIcon.withRenderingMode(.alwaysTemplate) : testModeIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        switchModeButton.tintColor = .white
        
        if isTestMode {
            
            Analytics.logEvent(AnalyticsEvent.ToggleSpeakingMode.rawValue, parameters: [StringAnalyticsProperties.ModeName.rawValue: "practice" as NSObject])
            
            //            UIView.animate(withDuration: 0.2) {
            //                self.thinkTimeChangeStackViewContainer.isHidden = true
            //            } completion: { (completed) in
            //                self.topicsContainer.isHidden = false
            //            }
            
            UIView.animate(withDuration: 0.3) {
                self.thinkTimeChangeStackViewContainer.isHidden = true
                self.topicsContainer.isHidden = false
            }
            
            renderTopic(topicNumber: self.topicNumber)
            defaultThinkTime = 15
            defaultSpeakTime = 45
            thinkTime = defaultThinkTime
            speakTime = defaultSpeakTime
            
        } else {
            Analytics.logEvent(AnalyticsEvent.ToggleSpeakingMode.rawValue, parameters: [StringAnalyticsProperties.ModeName.rawValue: "test" as NSObject])
            
            
            //            UIView.animate(withDuration: 0.2) {
            //                self.thinkTimeChangeStackViewContainer.isHidden = false
            //                self.topicsContainer.isHidden = true
            //            }
            
            UIView.animate(withDuration: 0.3) {
                self.thinkTimeChangeStackViewContainer.isHidden = false
                self.topicsContainer.isHidden = true
            }
            
            //            thinkTimeChangeStackViewSeperator.isHidden = false
            //            self.switchModesBtn.setTitle("Test", for: .normal)
            //            self.changeTopicBtnsStackView.isHidden = true
            //            self.topicTxtView.text = "TEST MODE"
        }
        isTestMode = !isTestMode
        resetRecordingState()
    }
    
    func setToTestMode() {
        logger.info("Setting to test mode")
        
        isTestMode = false
        switchModes()
    }
    
    func setToPracticeMode() {
        logger.info("Setting to practice mode")
        
        isTestMode = true
        switchModes()
    }
    
}
