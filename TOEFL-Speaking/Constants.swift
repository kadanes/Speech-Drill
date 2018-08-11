//
//  Constants.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 11/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import AVFoundation

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
