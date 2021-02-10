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
private var assetExport: AVAssetExportSession?

func checkIfMerging() -> Bool {
    logger.info("Checking if currently merging? \(isMerging)")
    
    return isMerging
}

func checkIfMerging(audioFileUrls: [URL]) -> Bool {
    logger.info("Checking if currently merging urls \(audioFileUrls)")
    
    return sortUrlList(recordingsUrlList: audioFileUrls)  == sortUrlList(recordingsUrlList: previouslyMergedUrlsList)  && isMerging
}

///Check if the urls in list being merged belongs to this date
func checkIfMerging(date: String) -> Bool {
    logger.info("Checking if currently merging for date \(date)")

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

func getMergedFileUrl() -> URL {
    logger.info("Getting merged file url")
    
    let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
    let mergeAudioURL = documentDirectoryURL.appendingPathComponent(mergedFileName)!
    
    return mergeAudioURL
}

func mergeAudioFiles(audioFileUrls: [URL],completion: @escaping () -> ()) {
    logger.info("Merging audio in urls from passed list")
    
    if previouslyMergedUrlsList == audioFileUrls {
        logger.debug("New url list matches old url list")
        completion()
    } else {
        isMerging = true
        previouslyMergedUrlsList = audioFileUrls
       
        let deleteStatus = deleteStoredRecording(recordingURL: getMergedFileUrl())
        
        if deleteStatus == .Failed { return }
        
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
                logger.error("Error while inserting recordig number \(i+1). Error: \(error)")
            }
        }
        
        assetExport = AVAssetExportSession(asset: composition, presetName: presetName)
        
        assetExport?.outputFileType = outputFileType
        
        assetExport?.outputURL = getMergedFileUrl()
        
        
        let exportMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if let assetExport = assetExport {
                let progress = assetExport.progress
                if progress < 0.99 {
                     //Toast.show(message: "\(round(progress*100))% merging done...", type: .Info)
                    
                    ProgressBar.bar.updateWidth(progress: progress)
                }
            }
        }
        
        assetExport?.exportAsynchronously(completionHandler:
            {
               
                switch assetExport!.status
                {
                case AVAssetExportSessionStatus.failed:
                    logger.error("failed \(assetExport?.error ?? "FAILED" as! Error)")
                case AVAssetExportSessionStatus.cancelled:
                    logger.warn("cancelled \(assetExport?.error ?? "CANCELLED" as! Error)")
                case AVAssetExportSessionStatus.unknown:
                    logger.error("unknown\(assetExport?.error ?? "UNKNOWN" as! Error)")
                case AVAssetExportSessionStatus.waiting:
                    logger.info("waiting\(assetExport?.error ?? "WAITING" as! Error)")
                case AVAssetExportSessionStatus.exporting:
                    logger.info("exporting\(assetExport?.error ?? "EXPORTING" as! Error)")
                default:
                    Toast.show(message: "Merged \(audioFileUrls.count) recordings!", type: .Info)
                    exportMonitorTimer.invalidate()
                    ProgressBar.bar.updateWidth(progress: 0)
                    
                    isMerging = false
                    completion()
                }
        })
    }
}

