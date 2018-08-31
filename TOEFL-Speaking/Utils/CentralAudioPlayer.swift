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
    
    var playingRecordingURL: URL?
    var playedRecordingID: String?
    
    var playPauseButton: UIButton?
    var oldPlayPauseIconId = "g"
    
    var isPlaying = false
    var audioPlayer: AVAudioPlayer?
    var audioSession: AVAudioSession!
    
    static let player = CentralAudioPlayer()
    
    private override init() {
    }
    
    func stopPlaying() {
        
        if (playPauseButton != nil) {
            
            isPlaying = false
            playingRecordingURL = nil
            playedRecordingID = nil
            audioPlayer?.stop()
        }
    }
    
    ///Play or Pause or Start a recording
    func playRecording(url: URL,id: String){
  

        if (url != playingRecordingURL || playedRecordingID != id ) {
            
            isPlaying = true
            
            playingRecordingURL = url
            playedRecordingID = id
            
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
                print("Error Playing\n",error.localizedDescription)
                
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
        
        playingRecordingURL = nil
        playedRecordingID = nil
        isPlaying = false
        
    }
    
    func checkIfPlaying(url: URL,id: String) -> Bool {
    
        if (playingRecordingURL ==  url && playedRecordingID == id) {
            return isPlaying
        }
        return false;
    }
    
    func getPlayBackDuration() -> Double{
        if let playBackDuration = audioPlayer?.duration {
            return playBackDuration
        }
        return 0.0
    }
    
    func getPlayBackCurrentTime() -> Double{
        if let playBackCurrentTime = audioPlayer?.currentTime {
            return playBackCurrentTime
        }
        return 0.0
    }
    
    func setPlaybackTime(playTime: Double) {
       
       audioPlayer?.currentTime = playTime
        
    }
}

