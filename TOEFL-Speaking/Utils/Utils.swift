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
import Mute

var previouslyMergedURLList = [URL]()

func mergeAudioFiles(audioFileUrls: [URL],completion: @escaping () -> ()) {
    
    if previouslyMergedURLList == audioFileUrls {
        completion()
    } else {
        previouslyMergedURLList = audioFileUrls
        do {
            try FileManager.default.removeItem(at: getMergedFileURL())
            
        } catch let error as NSError {
            print("Error Deleting Merged Audio:\n\(error.domain)")
        }
        
        let composition = AVMutableComposition()
        
        var oldThinkTime: Int = 0
        
        for i in 0 ..< audioFileUrls.count {
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            let currentURL = audioFileUrls[i]
            
            let thinkTime = splitFileURL(url: "\(currentURL)").2
            
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
                    print("Merged recordings successfully")
                    completion()
                }
        })
        
    }
}

func deleteStoredRecording(recordingURL: URL) {
    do{
        try FileManager.default.removeItem(at: recordingURL)
        
    } catch let error as NSError {
        
        print("Could Not Delete File\n",error.localizedDescription)
        
    }
}


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

func setButtonBgImage(button: UIButton, bgImage: UIImage) {
    
    DispatchQueue.main.async {
        UIView.transition(with: button, duration: 0.3, options: .curveEaseIn, animations: {
            button.setImage(bgImage, for: .normal)
        }, completion: nil)
    }
}

func splitFileURL(url: String) -> (timeStamp:Int,topicNumber:Int,thinkTime:Int) {
    
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

func convertToDate(date: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.date(from: date)
}

func checkIfSilent() {
    
    Mute.shared.isPaused = false

    Mute.shared.checkInterval = 0.5
    
    Mute.shared.alwaysNotify = true
    
    Mute.shared.notify = { isMute in
        
        Mute.shared.isPaused = true
   
        if isMute {
            Toast.show(message: "Please turn silent mode off!", success: false)
        }
    }
}

func seperatorPathFor(thinkTime: Int) -> String? {
    
    switch  thinkTime {
    case 15:
        return getPath(fileName: independentT2S)
    case 20:
        return getPath(fileName: integratedBT2S)
    case 30:
        return getPath(fileName: integratedAT2S)
    default:
        return getPath(fileName: beepSoundFileName)
    }
}

func getPath(fileName: String ) -> String? {
    
    let path = Bundle.main.path(forResource: fileName, ofType: nil)
    return path
}

///Function to sort list of recording urls by file name (timestamp)
func sortUrlList(recordingsURLList: [URL]) -> [URL] {
    let sortedRecordingsURLList = recordingsURLList.sorted(by: {(url1,url2)-> Bool in
        let timestamp1 = splitFileURL(url: "\(url1)").0
        let timestamp2 = splitFileURL(url: "\(url2)").0
        return timestamp1 > timestamp2
    })
    return sortedRecordingsURLList
}

///Merge and return a new url of list of recordings or url of only recording in the list
func processMultipleRecordings(recordingsList: [URL]?,activityIndicator: UIActivityIndicatorView? ,completion: @escaping (URL) -> ()) {
    
    if var sortedRecordingsList = recordingsList {
        
        if let activityIndicator = activityIndicator {
            
            DispatchQueue.main.async {
                activityIndicator.startAnimating()
            }
        }
        
        sortedRecordingsList = sortUrlList(recordingsURLList: sortedRecordingsList)
        
        if sortedRecordingsList.count == 1 {
            
            completion(sortedRecordingsList[0])
            
        } else {
            mergeAudioFiles(audioFileUrls: sortedRecordingsList) {
                
                completion(getMergedFileURL())
            }
        }
    }
}

///Open share sheet and share a recording
func openShareSheet(url: URL,activityIndicator: UIActivityIndicatorView?, completion: @escaping()->()) {
    let activityVC = UIActivityViewController(activityItems: [url],applicationActivities: nil)
    
    DispatchQueue.main.async {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
                
            }
            
            activityVC.popoverPresentationController?.sourceView = topController.view
            
            topController.present(activityVC, animated: true, completion: {
                
                if let activityIndicator = activityIndicator {
                    activityIndicator.stopAnimating()
                }
            })
            
            activityVC.completionWithItemsHandler = { activity, success, items, error in
                
                if success {
                    Toast.show(message: "Shared successfully!", success: true)
                } else {
                    Toast.show(message: "Cancelled share!", success: false)
                }
                
                completion()
            }
        }
    }
}

///Get time in mins and seconds format from total seconds
func convertToMins(seconds: Double) -> String {
    let playbackTime = Int(round(seconds))
    let mins = Int(playbackTime / 60)
    let sec = playbackTime - (mins * 60)
    let minsAndSec = "\(mins):\(String(format: "%02d", sec))"
    return minsAndSec
}

///Draw a circle of given diameter and return it as image
func drawSliderThumb(diameter: CGFloat) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
    let img = renderer.image { ctx in
        ctx.cgContext.setFillColor(UIColor.white.cgColor)
    
        let rectangle = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        
        ctx.cgContext.setShadow(offset: CGSize(width: 20, height: 20 ), blur: 10.0, color: UIColor.purple.cgColor)
        ctx.cgContext.addEllipse(in: rectangle)
        ctx.cgContext.drawPath(using: .fill)
    }
    return img
}
