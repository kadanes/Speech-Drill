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
import Firebase
import StoreKit

func deleteStoredRecording(recordingURL: URL) -> DeleteResult {
    logger.info("Deleting recording at \(recordingURL)")
    
    let fileManager = FileManager()
    
    let path = "\(recordingURL)".replacingOccurrences(of: "file:///", with: "/")
    
    if fileManager.fileExists(atPath: path) {
        do{
            try FileManager.default.removeItem(at: recordingURL)
            return .Success
        } catch let error as NSError {
            logger.error("Could not delete file \(error.localizedDescription)")

            return .Failed
        }
    } else {
        return .FileNotFound
    }
}

func findAndUpdateSection(date: String, recordingUrlsDict:Dictionary<String,Array<URL>>, completion: @escaping (Int,Array<URL>)->()) {
    logger.info("Updating section for date \(date)")
    
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
    logger.info("Opening url: \(String(describing: url))")
    
    guard let url = url else { return }
    //    if UIApplication.shared.canOpenURL(url) {
    //    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    
}

func setBtnImgProp(button: UIButton, topPadding: CGFloat, leftPadding: CGFloat) {
    logger.debug("Setting button image properties")
    
    button.imageView?.contentMode = .scaleAspectFit
    button.contentEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding, leftPadding)
}

func setButtonBgImage(button: UIButton, bgImage: UIImage,tintColor color: UIColor) {
    let buttonImg = bgImage.withRenderingMode(.alwaysTemplate)
    logger.debug("Setting button image properties")
    
    DispatchQueue.main.async {
        UIView.transition(with: button, duration: 0.3, options: .curveEaseIn, animations: {
            button.setImage(buttonImg, for: .normal)
            button.tintColor = color
        }, completion: nil)
    }
}

func splitFileURL(url: URL) -> (timeStamp:Int,topicNumber:Int,thinkTime:Int) {
    logger.debug("Splitting recording url to get details, \(url)")
    
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
    logger.info("Verify if passed string is a valid date")
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "dd/MM/yyyy"
    
    if dateFormatterGet.date(from: date) != nil {
        return true
    } else {
        return false
    }
}

func parseDate(timeStamp: Int) -> String {
    logger.debug("Parsing timestamp to dd/MM/yyyy date")
    
    let ts = Double(timeStamp)
    let date = Date(timeIntervalSince1970: ts)
    let dateFormatter = DateFormatter()
    
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    let strDate = dateFormatter.string(from: date)
    return strDate
}

func convertToDate(date: String) -> Date? {
    logger.debug("Parsing date string to date")
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.date(from: date)
}

func checkIfSilent() {
    logger.debug("Checking if mute switch is on")
    
    Mute.shared.isPaused = false
    Mute.shared.checkInterval = 0.5
    Mute.shared.alwaysNotify = true
    Mute.shared.notify = { isMute in
        Mute.shared.isPaused = true
        if isMute {
            logger.debug("Muted")
            Toast.show(message: "Please turn silent mode off!", type: .Failure)
        }
    }
}

func seperatorPathFor(thinkTime: Int) -> String? {
    logger.debug("Getting audio seperator file path")
    
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
    logger.debug("Getting path for \(fileName) from bundle")
    
    let path = Bundle.main.path(forResource: fileName, ofType: nil)
    return path
}

///Function to sort list of recording urls by file name (timestamp)
func sortUrlList(recordingsUrlList: [URL]) -> [URL] {
    logger.info("Sorting url list by timestamp")
    
    let sortedRecordingsUrlList = recordingsUrlList.sorted(by: {(url1,url2)-> Bool in
        let timestamp1 = splitFileURL(url: url1).0
        let timestamp2 = splitFileURL(url: url2).0
        return timestamp1 > timestamp2
    })
    return sortedRecordingsUrlList
}

///Sort doctionary of recording urls by date
func sortDict(recordingUrlsDict: Dictionary<String,Array<URL>>) -> [(key:String,value:Array<URL>)] {
    logger.info("Sorting dictionary of recordings for dates (\(type(of: recordingUrlsDict)) by date")
    
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
    logger.info("Merging recordings from url list")
    
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
                    logger.error("Error copying merged files \(error)")
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
    logger.event("Opening share sheet to export recording at \(url)")
    
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
    logger.info("Converting seconds (\(seconds)) to minutes")
    
    let playbackTime = Int(round(seconds))
    let mins = Int(playbackTime / 60)
    let sec = playbackTime - (mins * 60)
    let minsAndSec = "\(mins):\(String(format: "%02d", sec))"
    return minsAndSec
}

func getAppstoreVersion() -> String? {
    logger.info("Getting app store version of Speech-Drill")
    
    let infoDictionary = Bundle.main.infoDictionary
    let appID = infoDictionary![appIdKey] as! String
    guard let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)") else {
        logger.error("Bad app store url for Speech-Drill")
        return nil
    }
    
    guard let data = try? Data(contentsOf: url) else {
        logger.error("App data not found for Speech-Drill")
        return nil
        
    }
    
    do {
        guard let lookup = (try JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any] else { return nil }
        if let resultCount = lookup["resultCount"] as? Int, resultCount == 1 {
            if let results = lookup["results"] as? [[String:Any]] {
                if let appStoreVersion = results[0]["version"] as? String{
                    return appStoreVersion
                }
            }
        }
    } catch {
        logger.error("Error parsing app store data for Speech-Drill: \(error)")
    }
    
    return nil
}

func getInstalledVersionNumber() -> String? {
    logger.debug("Getting current app version number")
    guard let infoDictionary = Bundle.main.infoDictionary, let currentVersionNumber = infoDictionary[appVersionNumberKey] as? String else { return nil}
    return currentVersionNumber
}

func getInstalledBuildNumber() -> String? {
    logger.debug("Getting current app build number")
    
    guard let infoDictionary = Bundle.main.infoDictionary, let currentBuildNumber = infoDictionary[appBuildNumberKey] as? String else { return nil}
    return currentBuildNumber
}

func getFullInstalledAppVersion() -> String? {
    logger.debug("Getting installed app version and build number")
    
    guard let installedVersionNumber = getInstalledVersionNumber() else { return nil }
    guard let installedBuildNumber = getInstalledBuildNumber() else { return "\(installedVersionNumber)(_)" }
    return "\(installedVersionNumber)(\(installedBuildNumber))"
}

func validateTextView(textView: UITextView) -> Bool {
    logger.info("Validating text view for non-empty text")
    
    guard let text = textView.text,
          !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
        return false
    }
    return true
}

func isCallKitSupported() -> Bool {
    logger.info("Checking if should support call kit in current region")
    
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
    logger.info("Opening settings page for Speech-Drill")
    
    if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplicationOpenSettingsURLString + bundleIdentifier) {
        if UIApplication.shared.canOpenURL(appSettings) {
            UIApplication.shared.open(appSettings)
        }
    } else {
        logger.error("Can't open settings page for Speech-Drill")
    }
}

/// Get the user name of logged in user
/// - Returns: Will return the user's email id by stripping part after @ and removing full stops. E.g: my.dotted.email@domain.com will return mydottedemail.
func getAuthenticatedUsername() -> String? {
    logger.debug("Getting username for logged in user")
    
    guard let user = Auth.auth().currentUser, let userEmail = user.email else { return nil }
    return getUsernameFromEmail(email: userEmail)
}

func getUsernameFromEmail(email: String) -> String? {
    logger.debug("Converting \(email) to username without dots and domain name")
    
    let emailComponents = email.components(separatedBy: "@")
    if emailComponents.count == 0  { return nil }
    let username = emailComponents[0].replacingOccurrences(of: ".", with: "")
    return username
}

/// Returns a UUID to idendify users not logged in.
/// - Returns: Will return unique identifierForVendor if not nil else a randomly generated UUID. Generated will be stored in user defaults with key uuidKey so same value gets returned if possibke when app is reinstalled or identifierForVendor is nil.
func getUUID() -> String {
    logger.debug("Getting uuid for device")
    
    let defaults = UserDefaults.standard
    if let storedUUID = defaults.string(forKey: uuidKey) { return storedUUID }
    
    let newUUID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    defaults.setValue(newUUID, forKey: uuidKey)
    return newUUID
}


/// Get a date formatter that parses Date to current timestamp as dd MM yyyy
/// - Returns: A date formatter object to parse dates
func getDateFormatter() -> DateFormatter {
    logger.debug("Getting date formatter for dd MM yyyy")
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .current
    dateFormatter.dateFormat = "dd MMM yyyy"
    return dateFormatter
}


/// Get a date from a string  of date format dd MMM yyyy.
/// - Parameter dateString: Date string formated as dd MMM yyyy
/// - Returns: A date object by parsing date in dd MMM yyy format
func getDate(from dateString: String) -> Date? {
    logger.debug("Converting date string \(dateString) (dd MM yyyy) to date")
    let dateFormatter = getDateFormatter()
    return dateFormatter.date(from: dateString) ?? nil
}

/// Get a string representation in current local time for a timestamp
/// - Parameter timestamp: Timestamp to be converted to date string
/// - Returns: A date string from passed timestamp in dd MMM yyy format
func getDateString(from timestamp: Double) -> String {
    logger.debug("Getting date string (dd MM yyyy) from timestamp \(timestamp)")
    let dateFormatter = getDateFormatter()
    let date = Date(timeIntervalSince1970: timestamp)
    let dateString = dateFormatter.string(from: date)
    return dateString
}


/// Requests review from user based on certain conditions.
/// 1. Should have recorderd at least 3 recordings (if you want to force attept a review ask don't pass any parameter)
/// 2. Has not already asked for a review today
/// 3. A probabitly of 50% if will ask today
/// 4. If review has not been asked more than 30 times in the same year for the current version
/// - Parameter numberOfRecordings: If the number of recordings is greater than 3 then a review will be asked.
func askForReview(numberOfRecordings: Int = 5) {
    logger.info("Asking for review")
    
    let defaults = UserDefaults.standard
    let lastAskedReviewAt = defaults.double(forKey: lastAskedReviewAtKey)
    let dateStringForLastReviewAsk = getDateString(from: lastAskedReviewAt)
    let dateForLastReviewAsk = getDate(from: dateStringForLastReviewAsk) ?? Date(timeIntervalSince1970: 0)
    let askedReviewToday = Calendar.current.isDateInToday(dateForLastReviewAsk)
    var appReviewRequestsCount = defaults.integer(forKey: appReviewRequestsCountKey)
    
    if Date().localDate().years(from: dateForLastReviewAsk) >= 1 {
        defaults.setValue(0, forKey: appReviewRequestsCountKey)
        appReviewRequestsCount = 0
    }
    
    var isAskingReviewForSameVersion = false
    
    if let currentlyInstalledVersion = getInstalledVersionNumber(), let lastReviewAskedForVersion = defaults.string(forKey: lastReviewAskedForVersionKey) {
        if currentlyInstalledVersion == lastReviewAskedForVersion {
            isAskingReviewForSameVersion = true
        } else {
            appReviewRequestsCount = 0
            defaults.setValue(0, forKey: appReviewRequestsCountKey)
        }
        logger.debug("Last asked review for: \(lastReviewAskedForVersion)")
    }
    
    let askingReviewTooManyTimes = appReviewRequestsCount >= 30 && isAskingReviewForSameVersion
    
    let totalRecordingsTillDateCount = defaults.integer(forKey: totalRecordingsTillDateCountKey)
    let localNumberOfRecordings = max(numberOfRecordings, totalRecordingsTillDateCount)
    
    logger.debug("Number of recordings: \(localNumberOfRecordings)")
    logger.debug("Asking review too many times: \(askingReviewTooManyTimes)")
    logger.debug("Asked review today: \(askedReviewToday)")
    
    
    if localNumberOfRecordings > 3 && Bool.random() && !askedReviewToday && !askingReviewTooManyTimes {
        SKStoreReviewController.requestReview()
        defaults.setValue(Date().timeIntervalSince1970, forKey: lastAskedReviewAtKey)
        if let versionNumber = getInstalledVersionNumber() {
            defaults.setValue(versionNumber, forKey: lastReviewAskedForVersionKey)
        }
        defaults.setValue(appReviewRequestsCount + 1, forKey: appReviewRequestsCountKey)
    }
}

func fetchUserInfo() {
    
    var userInfoRef: DatabaseReference
    
    if let userName = getAuthenticatedUsername() {
        userInfoRef = authenticatedUsersReference.child(userName)
    } else {
        let uuid = getUUID()
        userInfoRef = unauthenticatedUsersReferences.child(uuid)
        logger.debug("Fetching user info for \(userInfoRef)")
    }
        
    userInfoRef.observeSingleEvent(of: .value) { (snapshot) in
        if let value = snapshot.value {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601withFractionalSeconds
                
                let userInfo = try decoder.decode(UserInfo.self, from: data)
                
                logger.debug("User Info: \(userInfo)")
                logger.debug("First online: \(userInfo.activity.firstSeenDate)")
                logger.debug("Type of First online: \(type(of: userInfo.activity.firstSeenDate))")

            } catch {
                logger.error("Could not decode user info \(error)")
            }
        }
    }
}
