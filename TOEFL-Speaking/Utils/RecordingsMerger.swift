//
//  RecordingsMerger.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 02/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import AVFoundation

private var previouslyMergedUrlsList = [URL]()
private var isMerging = false

func checkIfMerging() -> Bool {
    return isMerging
}

func checkIfMerging(audioFileUrls: [URL]) -> Bool {
    return sortUrlList(recordingsUrlList: audioFileUrls)  == sortUrlList(recordingsUrlList: previouslyMergedUrlsList)  && isMerging
}

///Check if the urls in list being merged belongs to this date
func checkIfMerging(date: String) -> Bool {
    if previouslyMergedUrlsList.count == 0 {
        return false
    }
    
    let firstUrl = previouslyMergedUrlsList[0]
    let mergingUrlsTimestamp = splitFileURL(url: firstUrl).timeStamp
    let mergingUrlsDate = parseDate(timeStamp: mergingUrlsTimestamp)
    
    if mergingUrlsDate == date {
        return isMerging
    } else {
        return false
    }
}

func mergeAudioFiles(audioFileUrls: [URL],completion: @escaping () -> ()) {
    if previouslyMergedUrlsList == audioFileUrls {
        completion()
    } else {
        isMerging = true
        previouslyMergedUrlsList = audioFileUrls
        do {
            try FileManager.default.removeItem(at: getMergedFileUrl())
        } catch let error as NSError {
            print("Error Deleting Merged Audio:\n\(error.domain)")
        }
        
        let composition = AVMutableComposition()
        
        var oldThinkTime: Int = 0
        
        for i in 0 ..< audioFileUrls.count {
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            let currentURL = audioFileUrls[i]
            
            let thinkTime = splitFileURL(url: currentURL).2
            
            let asset = AVURLAsset(url: currentURL)
            
            let track: AVAssetTrack = asset.tracks(withMediaType: AVMediaType.audio)[0]
            
            let timeRange: CMTimeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: track.timeRange.duration)
            
            do{
                
                let delimiterPath: String?
                
                if oldThinkTime != thinkTime {
                    
                    delimiterPath = seperatorPathFor(thinkTime: thinkTime)
                    oldThinkTime = thinkTime
                    
                } else {
                    
                    delimiterPath = seperatorPathFor(thinkTime: 0)
                }
                
                if let path = delimiterPath {
                    
                    let delimiterURL = URL(fileURLWithPath: path)
                    
                    let assetDelimiter = AVURLAsset(url: delimiterURL)
                    
                    let trackDelimiter: AVAssetTrack = assetDelimiter.tracks(withMediaType: AVMediaType.audio)[0]
                    
                    let timeRangeDelimiter: CMTimeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: trackDelimiter.timeRange.duration)
                    
                    try compositionAudioTrack.insertTimeRange(timeRangeDelimiter, of: trackDelimiter, at: composition.duration)
                    
                }
                try compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
                
                
            } catch let error as NSError {
                print("Error while inserting ",i+1)
                print(error.localizedDescription)
                
            }
        }
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: presetName)
        
        assetExport?.outputFileType = outputFileType
        
        assetExport?.outputURL = getMergedFileUrl()
        
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
                    print("Merged recordings successfully")
                    isMerging = false
                    completion()
                }
        })
    }
}
