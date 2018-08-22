//
//  Utils.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


func openURL(url: URL?) {
    
    guard let url = url else {return }
    
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}


func setBtnImgProp(button: UIButton, topPadding: CGFloat, leftPadding: CGFloat) {
    button.imageView?.contentMode = .scaleAspectFit
    button.contentEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding, leftPadding)
}


func splitFileURL(url: String) -> (Int,Int,Int) {
    
    let urlComponents = url.components(separatedBy: "/")
    
    let fileName = urlComponents[urlComponents.count - 1]
    
    let fileNameComponents = fileName.components(separatedBy: ".")
    
    var timeStamp: Int = 0
    var topicNumber: Int = 0
    var thinkTime: Int = 0
    
    if fileNameComponents.indices.count > 0 {
        
        let recordingNameComponents = fileNameComponents[0].components(separatedBy: "_")
        
        if let thinkTimeUW = Int(recordingNameComponents[2]) {
            thinkTime = thinkTimeUW
        }
        
        if let topicNumberUW = Int(recordingNameComponents[1]) {
            topicNumber = topicNumberUW
        }
        
        if let timeStampUW = Int(recordingNameComponents[0]) {
            timeStamp = timeStampUW
        }
        
    }
    
    return (timeStamp,topicNumber,thinkTime)
}

func parseDate(timeStamp: Int) -> String {
    
    let ts = Double(timeStamp)
    
    let date = Date(timeIntervalSince1970: ts)
    let dateFormatter = DateFormatter()
    
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let strDate = dateFormatter.string(from: date)
    
    return strDate
}

func mergeAudioFiles(audioFileUrls: [URL],completion: @escaping () -> ()) {
    
    do {
        try FileManager.default.removeItem(at: getMergedFileURL())
        
    } catch let error as NSError {
        print("Error Deleting Merged Audio:\n\(error.domain)")
    }
    
    let composition = AVMutableComposition()
    
    
    for i in 0 ..< audioFileUrls.count {
        
        let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        
        let asset = AVURLAsset(url: (audioFileUrls[i]))
        
        let track = asset.tracks(withMediaType: AVMediaType.audio)[0]
        
        let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: track.timeRange.duration)
        
        do{
            try compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
            
            let delimiterPath = Bundle.main.path(forResource: beepSoundFileName, ofType: recordingExtension)
            
            if let path = delimiterPath {
                let delimiterURL = URL(fileURLWithPath: path)
                print(delimiterURL)
                
                let assetDelimiter = AVURLAsset(url: delimiterURL)
                
                let trackDelimiter = assetDelimiter.tracks(withMediaType: AVMediaType.audio)[0]
                
                let timeRangeDelimiter = CMTimeRange(start: CMTimeMake(0, 600), duration: trackDelimiter.timeRange.duration)
                
                try compositionAudioTrack.insertTimeRange(timeRangeDelimiter, of: trackDelimiter, at: composition.duration)
            }
            
        } catch let error as NSError {
            print("Error while inseting in composition for url: ",i+1)
            print(error.localizedDescription)
            
        }
    }
    
    let assetExport = AVAssetExportSession(asset: composition, presetName: presetName)
    
    assetExport?.outputFileType = outputFileType
    
    assetExport?.outputURL = getMergedFileURL()
    
    assetExport?.exportAsynchronously(completionHandler:
        {
            
            switch assetExport!.status
            {
            case AVAssetExportSessionStatus.failed:
                print("failed \(assetExport?.error ?? "FAILED" as! Error)")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport?.error ?? "CANCELLED" as! Error)")
            case AVAssetExportSessionStatus.unknown:
                print("unknown\(assetExport?.error ?? "UNKNOWN" as! Error)")
            case AVAssetExportSessionStatus.waiting:
                print("waiting\(assetExport?.error ?? "WAITING" as! Error)")
            case AVAssetExportSessionStatus.exporting:
                print("exporting\(assetExport?.error ?? "EXPORTING" as! Error)")
            default:
                print("Audio Concatenation Complete")
                completion()
            }
    })
}


func setButtonBgImage(button: UIButton, bgImage: UIImage) {
    
    DispatchQueue.main.async {
        button.setImage(bgImage, for: .normal)
    }
}

