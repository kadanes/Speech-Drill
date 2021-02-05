//
//  MainVCActions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAnalytics
import AVFoundation

//MARK:- MainVC Actions
extension MainVC {
    
    @IBAction func displaySideNavTapped(_ sender: Any) {
        Analytics.logEvent(AnalyticsEvent.ShowSideNav.rawValue, parameters: nil)
        cancelRecording()
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func startPulsing(_ sender: UIButton) {
        let pulse = Pulsing(numberOfPulses: 1, diameter: sender.layer.bounds.width, position: CGPoint(x:sender.layer.bounds.width/2,y: sender.layer.bounds.height/2))
        sender.layer.addSublayer(pulse)
    }
    
    @objc func displayInfo() {
        
        if isPlaying || checkIfRecordingIsOn() {
            return
        }
        
        var infoText = ""
        switch thinkTime {
        case 15:
            infoText = "This is the first type of speaking question in the test. You have to talk on a topic by giving your personal opinion. You will have 15 seconds to prepare and 45 seconds to answer. You can practice with the provided topics or use the test mode to record speaking questions from mock tests."
        case 30:
            infoText = "This is an integrated speaking task. It comes after independent speaking. In this question you have to read a short passage for around 45 seconds. Then you will listen to a talk about it after which you have to answer a question asked related to what you read and heard. You will get 30 seconds to prepare and 60 seconds to answer. Use this mode to record answers from mock tests."
        case 20:
            infoText = "This is the second integrated speaking task. In this you will listen to a short conversation between 2 students or a professor giving a lecture. Then you have to answer a question related to it. Use this mode to record answers from mock tests."
            
        default:
            infoText = ""
        }
        
        let alert = UIAlertController(title: "Question Information", message: infoText, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .cancel) { _ in }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func switchModesTapped(_ sender: UIButton) {
        switchModes()
    }
    
    @IBAction func changeThinkTimeTapped(_ sender: RoundButton) {
        
        Analytics.logEvent(AnalyticsEvent.SetThinkTime.rawValue, parameters: [IntegerAnalyticsPropertites.ThinkTime.rawValue : sender.tag as NSObject])
        
        if checkIfRecordingIsOn() {return}
        
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
        //        displayInfo()
    }
    
    ///Increment current displayed topic number base on button pressed
    @IBAction func nextQuestionTapped(_ sender: UIButton) {
        Analytics.logEvent(AnalyticsEvent.ShowNextTopic.rawValue, parameters: [IntegerAnalyticsPropertites.NumberOfTopics.rawValue : sender.tag as NSObject ])
        
        let increment = sender.tag
        topicNumber = (topicNumber + increment < topics.count) ? topicNumber + increment : topics.count - 1
        renderTopic(topicNumber: topicNumber)
    }
    
    ///Decrement current displayed topic number base on button pressed
    @IBAction func previousQuestionTapped(_ sender: UIButton) {
        Analytics.logEvent(AnalyticsEvent.ShowPreviousTopic.rawValue, parameters: [IntegerAnalyticsPropertites.NumberOfTopics.rawValue : sender.tag as NSObject ])
        
        let decrement = sender.tag
        topicNumber = (topicNumber - decrement >= 1) ? topicNumber - decrement : 1
        renderTopic(topicNumber: topicNumber)
    }
    
    ///Start recording of speech
    @IBAction func startRecordingPressed(_ sender: Any) {
        
        Analytics.logEvent(AnalyticsEvent.RecordTopic.rawValue, parameters:nil)
        
        CentralAudioPlayer.player.stopPlaying()
        
        if (!checkIfRecordingIsOn()) {
            
            cancelRecordingBtn.isHidden = false
            
            DispatchQueue.main.async {
                //                self.thinkTimeInfoView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                self.speakTimeLbl.textColor = .white
                self.speakLbl.textColor = .white
            }
            
            thinkTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decrementThinkTime), userInfo: nil, repeats: true)
        }
    }
    
    ///Stop recording
    @IBAction func cancelRecordingTapped(_ sender: Any) {
        Analytics.logEvent(AnalyticsEvent.CancelRecording.rawValue, parameters: nil)
        cancelRecording()
    }
    
    ///Function to reduce and render think time
    @objc func decrementThinkTime(timer: Timer) {
        if(thinkTime > 0) {
            isThinking = true
            thinkTime -= 1
//            thinkTimeLbl.text = "\(thinkTime)"
            thinkTimeLbl.text = String(format: "%02d", thinkTime)
            
        } else {
            
            timer.invalidate()
            thinkTime = defaultThinkTime
            
            if !reducedTime {
                do {
                    let alertSound = URL(fileURLWithPath: getPath(fileName: "speak_now.mp3")!)
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                    try AVAudioSession.sharedInstance().setActive(true)
                    try audioPlayer = AVAudioPlayer(contentsOf: alertSound)
                    
                    DispatchQueue.main.async {
                        let duration = (self.audioPlayer?.duration)!/2
                        UIView.animate(withDuration: duration, animations: {
                            //                            self.thinkTimeInfoView.backgroundColor = .clear
                            self.thinkTimeLbl.textColor = .white
                            self.thinkLbl.textColor = .white
                        })
                        UIView.animate(withDuration: duration, animations: {
                            //                            self.speakTimeInfoView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
                            self.speakTimeLbl.textColor = accentColor
                            self.speakLbl.textColor = accentColor
                        })
                    }
                    
                    audioPlayer!.prepareToPlay()
                    audioPlayer!.play()
                    
                    while (audioPlayer?.isPlaying)! {
                        
                    }
                } catch let error as NSError {
                    print("Error Playing Speak Now:\n",error.localizedDescription)
                }
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
//            speakTimeLbl.text = "\(speakTime)"
            speakTimeLbl.text = String(format: "%02d", speakTime)
        } else {
            timer.invalidate()
            speakTime = defaultSpeakTime
            DispatchQueue.main.async {
                //                self.speakTimeInfoView.backgroundColor = .clear
                self.thinkTimeLbl.textColor = accentColor
                self.thinkLbl.textColor = accentColor
            }
        }
    }
    
    ///Function to make recording logo blink
    @objc func blinkRecordBtn(timer: Timer) {
        if speakTime > 0 {
            if !blinking {
                setButtonBgImage(button: recordBtn, bgImage: recordIcon, tintColor: .red)
                blinking = true
            } else {
                recordBtn.setImage(nil, for: .normal)
                blinking = false
            }
        } else {
            timer.invalidate()
        }
    }
}
