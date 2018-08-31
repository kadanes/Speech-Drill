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
            
            setButtonBgImage(button: playPauseButton!, bgImage: getPlayBtnIcon(colorId: oldPlayPauseIconId))
            isPlaying = false
            playingRecordingURL = nil
            audioPlayer?.stop()
        }
    }
    
    ///Play or Pause or Start a recording
    func playRecording(url: URL,id: String, button: UIButton, iconId: String){
        
//        print("Passed: ",url,"\n",id)
//        print("Stored: ",playingRecordingURL,"\n",playedRecordingID)

        if (url != playingRecordingURL || playedRecordingID != id ) {
            
            
            if (playPauseButton == nil ) {
                playPauseButton = button
            }
            
            //setButtonBgImage(button: playPauseButton!, bgImage: getPlayBtnIcon(colorId: oldPlayPauseIconId))
            
            playPauseButton = button
            oldPlayPauseIconId = iconId
            
            //setButtonBgImage(button: playPauseButton!, bgImage: getPauseBtnIcon(colorId: iconId))
            
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
            print("Pausing")
            audioPlayer?.pause()
            isPlaying = false
            //setButtonBgImage(button: button, bgImage: getPlayBtnIcon(colorId: iconId))
            
        } else if (!isPlaying) {
            print("Playing")
            checkIfSilent()
            audioPlayer?.play()
            isPlaying = true
            //setButtonBgImage(button: button, bgImage: getPauseBtnIcon(colorId: iconId))
        }
    }
    
    ///Reset ui after playing recording(s)
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        playingRecordingURL = nil
        playedRecordingID = nil
        isPlaying = false
        
        setButtonBgImage(button: playPauseButton!, bgImage: getPlayBtnIcon(colorId: oldPlayPauseIconId))
    }
    
    func checkIfPlaying(url: URL,id: String) -> Bool {
    
        if (playingRecordingURL ==  url && playedRecordingID == id) {
            return isPlaying
        }
        return false;
    }
    
    
    
    
    func getPlayBtnIcon(colorId: String) -> UIImage{
        switch colorId {
        case "g":
            return playBtnIcon
        case "y":
            return playBtnYellowIcon
        default:
            return playBtnIcon
            
        }
    }
    
    func getPauseBtnIcon(colorId: String) -> UIImage{
        switch colorId {
        case "g":
            return pauseBtnIcon
        case "y":
            return pauseBtnYellowIcon
        default:
            return pauseBtnIcon
        }
    }
    
}

