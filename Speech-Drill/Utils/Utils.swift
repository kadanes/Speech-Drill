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

func deleteStoredRecording(recordingURL: URL) -> DeleteResult {
    
    let fileManager = FileManager()
    
    let path = "\(recordingURL)".replacingOccurrences(of: "file:///", with: "/")
    
    if fileManager.fileExists(atPath: path) {
        do{
            try FileManager.default.removeItem(at: recordingURL)
            return .Success
        } catch let error as NSError {
            print("Could Not Delete File\n",error.localizedDescription)
            return .Failed
        }
    } else {
       return .FileNotFound
    }
}

func findAndUpdateSection(date: String, recordingUrlsDict:Dictionary<String,Array<URL>>, completion: @escaping (Int,Array<URL>)->()) {
    
    let sortedRecordingUrlsDict = sortDict(recordingUrlsDict: recordingUrlsDict)
    
    for section in 0..<sortedRecordingUrlsDict.count {
        if sortedRecordingUrlsDict[section].key == date {
            var urls = sortedRecordingUrlsDict[section].value
            urls = sortUrlList(recordingsUrlList: urls)
            
            completion(section,urls)
            
        }
    }
    
}

func openURL(url: URL?) {
    guard let url = url else { return }
//    if UIApplication.shared.canOpenURL(url) {
//    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)

}

func setBtnImgProp(button: UIButton, topPadding: CGFloat, leftPadding: CGFloat) {
    button.imageView?.contentMode = .scaleAspectFit
    button.contentEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding, leftPadding)
}

func setButtonBgImage(button: UIButton, bgImage: UIImage,tintColor color: UIColor) {
    let buttonImg = bgImage.withRenderingMode(.alwaysTemplate)
    DispatchQueue.main.async {
        UIView.transition(with: button, duration: 0.3, options: .curveEaseIn, animations: {
            button.setImage(buttonImg, for: .normal)
            button.tintColor = color
        }, completion: nil)
    }
}

func splitFileURL(url: URL) -> (timeStamp:Int,topicNumber:Int,thinkTime:Int) {
    
    let urlStr = "\(url)"
    
    let urlComponents = urlStr.components(separatedBy: "/")
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

func checkIfDate(date: String) -> Bool {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "dd/MM/yyyy"

    if dateFormatterGet.date(from: date) != nil {
        return true
    } else {
        return false
    }
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
            print("Muted")
            Toast.show(message: "Please turn silent mode off!", type: .Failure)
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

///Get the path for a file locally stored in app. Pass file name with extension
func getPath(fileName: String ) -> String? {
    let path = Bundle.main.path(forResource: fileName, ofType: nil)
    return path
}

///Function to sort list of recording urls by file name (timestamp)
func sortUrlList(recordingsUrlList: [URL]) -> [URL] {
    let sortedRecordingsUrlList = recordingsUrlList.sorted(by: {(url1,url2)-> Bool in
        let timestamp1 = splitFileURL(url: url1).0
        let timestamp2 = splitFileURL(url: url2).0
        return timestamp1 > timestamp2
    })
    return sortedRecordingsUrlList
}

///Sort doctionary of recording urls by date
func sortDict(recordingUrlsDict: Dictionary<String,Array<URL>>) -> [(key:String,value:Array<URL>)] {
    return recordingUrlsDict.sorted { (arg0, arg1) -> Bool in
        let (date1, _) = arg0
        let (date2, _) = arg1
        guard let convertedDate1 = convertToDate(date: date1) else { return false }
        guard let convertedDate2 = convertToDate(date: date2) else { return false }
        return convertedDate1 > convertedDate2
    }
}

///Merge and return a new url of list of recordings or url of only recording in the list
func processMultipleRecordings(recordingsList: [URL]?,activityIndicator: UIActivityIndicatorView? ,completion: @escaping () -> ()) {
    
    if var sortedRecordingsList = recordingsList {
        if let activityIndicator = activityIndicator {
            DispatchQueue.main.async {
                activityIndicator.startAnimating()
            }
        }
        
        sortedRecordingsList = sortUrlList(recordingsUrlList: sortedRecordingsList)
        if sortedRecordingsList.count == 1 {
            
            let deleteStatus = deleteStoredRecording(recordingURL: getMergedFileUrl())
            
            if deleteStatus == .Success || deleteStatus == .FileNotFound {
                
                let url = sortedRecordingsList[0]
                
                let fileManager = FileManager()
                
                do {
                    try fileManager.copyItem(at: url, to: getMergedFileUrl())
                    completion()
                } catch let error as NSError {
                    print("Error copying file")
                    print(error.localizedFailureReason ?? "ERROR COPYING")
                }
            }
        
        } else {
            mergeAudioFiles(audioFileUrls: sortedRecordingsList) {
                completion()
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
                    Toast.show(message: "Shared successfully!", type: .Success)
                } else {
                    Toast.show(message: "Cancelled share!", type: .Failure)
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

func getAppstoreVersion() -> String? {
    let infoDictionary = Bundle.main.infoDictionary
    let appID = infoDictionary!["CFBundleIdentifier"] as! String
    guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)") else {
        print("Bad Appstore URL")
        return nil
        
    }
    guard let data = try? Data(contentsOf: url) else {
        print("App data not found")
        return nil
        
    }
    
    let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any]
    if let resultCount = lookup!["resultCount"] as? Int, resultCount == 1 {
        if let results = lookup!["results"] as? [[String:Any]] {
            if let appStoreVersion = results[0]["version"] as? String{
                return appStoreVersion
            }
        }
    }
    return nil
}

func getInstalledVersion() -> String? {
    let infoDictionary = Bundle.main.infoDictionary
    let currentVersion = infoDictionary!["CFBundleShortVersionString"] as? String
    return currentVersion
}

func getBuildNumber() -> String {
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
        return build
    }
    return ""
}


func validateTextView(textView: UITextView) -> Bool {
    guard let text = textView.text,
        !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
        return false
    }
    return true
}

func isCallKitSupported() -> Bool {
    let userLocale = NSLocale.current
    
    guard let regionCode = userLocale.regionCode else { return false }
    
    if regionCode.contains("CN") ||
        regionCode.contains("CHN") {
        return false
    } else {
        return true
    }
}

func openAppSettings() {
    if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplicationOpenSettingsURLString + bundleIdentifier) {
        if UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    } else {
        print("Can't open app's settings")
    }
}
