//
//  swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 21/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CentralAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private var playingRecordingURL: URL?
    private var playingRecordingID: String?
    
    private var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession!
    
    static let player = CentralAudioPlayer()
    
    private override init() {
    }
    
    
    ///Return ID of currently playing recording 
    func getPlayingRecordingId() -> String {
        logger.info("Getting id of currently playing recording")
        return playingRecordingID ?? ""
    }
    
    ///Return URL of recording
    func getPlayingRecordingUrl() -> String {
        logger.info("Getting url string of currently playing recording")
        if let url = playingRecordingURL {
            return "\(url)"
        } else {
            return ""
        }
    }
    
    ///Stop playback and return player to default state
    func stopPlaying() {
        logger.info("Stopping recording playback")
        isPlaying = false
        playingRecordingURL = nil
        playingRecordingID = nil
        //audioPlayer?.stop
        audioPlayer = nil
    }
    
    ///Play or Pause or Start a recording
    func playRecording(url: URL, id: String){
        logger.info("Playing recording from url and id")
        
        if (url != playingRecordingURL || playingRecordingID != id ) {
            
            isPlaying = true
            
            playingRecordingURL = url
            playingRecordingID = id
            
            do{
                checkIfSilent()
                
                audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(AVAudioSessionCategoryAmbient)
                try audioSession.setActive(true)
                
                audioPlayer = try AVAudioPlayer(contentsOf: playingRecordingURL!)
                audioPlayer?.delegate = self
                
                guard let audioPlayer = audioPlayer else { return }
                
                audioPlayer.prepareToPlay()
                
                audioPlayer.play()
                
            } catch let error as NSError {
                logger.error("Error playing recording with url \(url) and id \(id): \(error)")
            }
            
        } else if (isPlaying) {
            
            audioPlayer?.pause()
            isPlaying = false
            
        } else if (!isPlaying) {
            
            checkIfSilent()
            audioPlayer?.play()
            isPlaying = true
        }
    }
    
    ///Reset ui after playing recording(s)
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        logger.info("Restting after playing recording")
        playingRecordingURL = nil
        playingRecordingID = nil
        isPlaying = false
    }
    
    func checkIfPlaying() -> Bool {
        logger.info("Checking if is playing recording")
        return isPlaying
    }
    
    func checkIfPlaying(id: String) -> Bool {
        logger.info("Checking if is playing recording of id \(id)")
        
        if playingRecordingID == id {
            return isPlaying
        }
        return false;
    }
    
    func getPlayBackDuration() -> Double {
        logger.info("Getting playback duration")
        
        if let playBackDuration = audioPlayer?.duration {
            return playBackDuration
        }
        logger.warn("Could not get correct playback duration")
        return 0.0
    }
    
    func getPlayBackCurrentTime() -> Double {
        logger.info("Getting currently ellapsed playback time")
        
        if let playBackCurrentTime = audioPlayer?.currentTime {
            return playBackCurrentTime
        }
        
        logger.warn("Could not get correct currently ellapsed playback time")
        return 0.0
    }
    
    ///Set the current playing audio time to new time
    func setPlaybackTime(playTime: Double) {
        logger.info("Setting playback time to \(playTime)")
        audioPlayer?.stop()
        audioPlayer?.currentTime = playTime
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
}
