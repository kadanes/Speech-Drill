//
//  Constants.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 11/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

let mergedFileName = "MergedAudio.m4a"
let beepSoundFileName = "beep2"
let recordingExtension = "m4a"

let outputFileType = AVFileType.m4a
let presetName = AVAssetExportPresetAppleM4A

func getMergedFileURL() -> URL {
    let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    
    let mergeAudioURL = documentDirectoryURL.appendingPathComponent(mergedFileName)!
    
    return mergeAudioURL
}


let sectionHeaderHeight: CGFloat = 40.0
let buttonVerticalInset: CGFloat = sectionHeaderHeight/4
let buttonHorizontalInset: CGFloat = 5

let recordingCellHeight: CGFloat = 60.0



//Buttons

let playBtnIcon = UIImage(named: "playg.png")!
let pauseBtnIcon = UIImage(named: "pauseg.png")!
let deleteBtnIcon = UIImage(named: "delete.png")!
let checkMarkIcon = UIImage(named: "check.png")!
let recordIcon = UIImage(named: "recordf.png")!
let emailIcon = UIImage(named: "email.png")!
let githubIcon = UIImage(named: "github.png")!
let doubleLeftIcon = UIImage(named: "dleft.png")!
let singleLeftIcon = UIImage(named: "sleft.png")!
let tripleLeftIcon = UIImage(named: "tleft.png")!
let doubleRightIcon = UIImage(named: "dright.png")!
let singleRightIcon = UIImage(named: "sright.png")!
let tripleRightIcon = UIImage(named: "tright.png")!
let closeIcon = UIImage(named: "close.png")!
let boxIcon = UIImage(named: "box.png")!
let deleteIcon = UIImage(named: "delete.png")!
let checkIcon = UIImage(named: "check.png")!
let infoIcon = UIImage(named: "info.png")!
let shareIcon = UIImage(named: "share.png")!
let singleShareIcon = UIImage(named: "sshareg.png")!



