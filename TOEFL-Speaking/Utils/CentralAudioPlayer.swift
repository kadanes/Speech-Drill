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
        return playingRecordingID ?? ""
    }
    
    ///Return URL of recording
    func getPlayingRecordingUrl() -> String {
        if let url = playingRecordingURL {
             return "\(url)"
        } else {
            return ""
        }
    }
    
    ///Stop playback and return player to default state
    func stopPlaying() {
        isPlaying = false
        playingRecordingURL = nil
        playingRecordingID = nil
        //audioPlayer?.stop
        audioPlayer = nil
    }
    
    ///Play or Pause or Start a recording
    func playRecording(url: URL,id: String){

        if (url != playingRecordingURL || playingRecordingID != id ) {
            print("OLD ID AND URL: \n",playingRecordingURL,"\n",playingRecordingID)
            print("NEW ID AND URL: \n",url,"\n",id)
            
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
        playingRecordingID = nil
        isPlaying = false
    }
    
    func checkIfPlaying() -> Bool {
        return isPlaying
    }

    func checkIfPlaying(id: String) -> Bool {
        
        if playingRecordingID == id {
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
    
    ///Set the current playing audio time to new time
    func setPlaybackTime(playTime: Double) {
        audioPlayer?.stop()
        audioPlayer?.currentTime = playTime
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
}

