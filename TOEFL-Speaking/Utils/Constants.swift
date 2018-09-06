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

let testModeId = 999
let mergedFileName = "MergedAudio.m4a"
let beepSoundFileName = "beep2.m4a"
let recordingExtension = "m4a"

let independentT2S = "independent.mp3"
let integratedAT2S = "integrated_a.mp3"
let integratedBT2S = "integrated_b.mp3"
let speakNowT2S = "speak_now.mp3"

let outputFileType = AVFileType.m4a
let presetName = AVAssetExportPresetAppleM4A

func getMergedFileUrl() -> URL {
    let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    
    let mergeAudioURL = documentDirectoryURL.appendingPathComponent(mergedFileName)!
    
    return mergeAudioURL
}


let sectionHeaderHeight: CGFloat = 40
let expandedSectionHeaderHeight: CGFloat = 80
let buttonVerticalInset: CGFloat = sectionHeaderHeight/4
let buttonHorizontalInset: CGFloat = 5
let recordingCellHeight: CGFloat = 50
let expandedRecordingCellHeight: CGFloat = 90
let normalThumbDiameter: CGFloat = 10
let highlightedThumbDiameter: CGFloat = 25


let recordingCellId = "recordingCell"
let headerCellId = "headerCell"
//Buttons

let playBtnIcon = UIImage(named: "playg.png")!
let pauseBtnIcon = UIImage(named: "pauseg.png")!
let deleteBtnIcon = UIImage(named: "delete.png")!
let checkMarkIcon = UIImage(named: "check.png")!
let recordIcon = drawSliderThumb(diameter: 40, backgroundColor: enabledRed)
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
let plusIcon = UIImage(named: "plus.png")!
let minusIcon = UIImage(named: "minus.png")!
//let sliderThumbIcon = UIImage(named: "slider-thumb.png")

//Recording ID
let selectedAudioId = "SelectedAudio"


//UI Colors

//#E6E6E6
let enabledGray = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
let disabledGray = UIColor.darkGray
//#8E0000
let enabledRed = UIColor.red
let disabledRed =  UIColor(red:0.56, green:0.00, blue:0.00, alpha:1.0)
let accentColor = UIColor.yellow
//#008080
//let accentColor = UIColor(red:0.00, green:0.50, blue:0.50, alpha:1.0)
