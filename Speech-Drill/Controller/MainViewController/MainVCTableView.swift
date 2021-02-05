//
//  MainVCTableView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension MainVC: UITableViewDataSource, UITableViewDelegate {
    
    func reloadData() {
        updateUrlList()
        DispatchQueue.main.async {
            self.recordingTableView.reloadData()
        }
    }
    
    func insertRow(with url:URL ) {
        
        let timestamp = splitFileURL(url: url).timeStamp
        let date = parseDate(timeStamp: timestamp)
        
        let totalRecordingsTillDateCount = userDefaults.integer(forKey: totalRecordingsTillDateCountKey)
        NSLog("Total recordings till date: \(totalRecordingsTillDateCount)")
        
        let currentNumberOfRecordings = countNumberOfRecordings() + 1
        userDefaults.setValue(currentNumberOfRecordings, forKey: recordingsCountKey)
        userDefaults.setValue(totalRecordingsTillDateCount + 1, forKey: totalRecordingsTillDateCountKey)
        saveCurrentNumberOfSavedRecordings()
        askForReview(numberOfRecordings: currentNumberOfRecordings)
        
        
        if !recordingUrlsDict.keys.contains(date) {
            var urls = [URL]()
            urls.insert(url, at: 0)
            recordingUrlsDict[date] = urls
            
            recordingTableView.insertSections([0], with: .automatic)
            
            //            print("URLS: ",urls)
            //
            //            recordingUrlsDict[date] = urls
            //            let indexPath = IndexPath(row: 0, section: 0)
            //            recordingTableView.insertRows(at: [indexPath], with: .automatic)
            visibleSections.append(date)
            
        } else {
            
            findAndUpdateSection(date: date, recordingUrlsDict: recordingUrlsDict) { (section,_) in
                self.showSection(date: date)
                self.recordingUrlsDict[date]?.insert(url, at: 0)
                self.recordingTableView.reloadSections([section], with: .automatic)
                
            }
        }
    }
    
    ///Delete a row refering to the recording url
    func deleteRow(with url: URL) {
        removeFromExportList(url: url)
        let timestamp = splitFileURL(url: url).timeStamp
        let date = parseDate(timeStamp: timestamp)
        
        findAndUpdateSection(date: date, recordingUrlsDict: recordingUrlsDict) { (section, containedUrls) in
            var urls = containedUrls
            
            if let row = urls.index(of: url) {
                
                let indexPath = IndexPath(item: row, section: section)
                
                if let numberOfRecordingsInSection = self.recordingUrlsDict[date]?.count {
                    
                    if numberOfRecordingsInSection == 1 {
                        self.recordingUrlsDict.removeValue(forKey: date)
                        self.recordingTableView.deleteSections([section], with: .automatic)
                        return
                    } else {
                        urls.remove(at: row)
                        self.recordingUrlsDict[date] = urls
                        self.recordingTableView.deleteRows(at: [indexPath], with: .automatic)
                        return
                    }
                }
            }
        }
    }
    
    func reloadRow(url: URL) {
        let timestamp = splitFileURL(url:url).timeStamp
        let date = parseDate(timeStamp: timestamp)
        findAndUpdateSection(date: date, recordingUrlsDict: recordingUrlsDict) { (section, urls) in
            if let row = urls.index(of: url) {
                let indexPath = IndexPath(row: row, section: section)
                self.recordingTableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func reloadSection(date: String) {
        DispatchQueue.main.async {
            findAndUpdateSection(date: date, recordingUrlsDict: self.recordingUrlsDict) { (section, _) in
                self.recordingTableView.reloadSections([section], with: .automatic)
            }
        }
    }
    
    func togglePlayIconsFor(previouslyPlayingId: String, nowPlayingId: String) {
        reloadPlayedRow(playingId: previouslyPlayingId, pause: true) {
            //self.reloadPlayedRow(playingId: nowPlayingId, pause: false) {}
        }
    }
    
    
    func reloadPlayedRow(playingId: String, pause: Bool, completion: @escaping ()->()) {
        if checkIfDate(date: playingId) {
            findAndUpdateSection(date: playingId, recordingUrlsDict: recordingUrlsDict) { (section, _) in
                self.recordingTableView.reloadSections([section], with: .none)
                completion()
            }
        } else if playingId == selectedAudioId {
            if pause {
                setButtonBgImage(button: playSelectedBtn, bgImage: pauseBtnIcon, tintColor: accentColor)
                isPlaying = false
                completion()
            } else {
                setButtonBgImage(button: playSelectedBtn, bgImage: playBtnIcon, tintColor: accentColor)
                isPlaying = true
                completion()
            }
        } else {
            
            if let url = URL(string: playingId) {
                let timestamp = splitFileURL(url:url).timeStamp
                let date = parseDate(timeStamp: timestamp)
                findAndUpdateSection(date: date, recordingUrlsDict: recordingUrlsDict) { (section, urls) in
                    
                    if let row = urls.index(of: url) {
                        let indexPath = IndexPath(row: row, section: section)
                        self.recordingTableView.reloadRows(at: [indexPath], with: .automatic)
                        completion()
                    }
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recordingUrlsDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedRecordingUrls = sortDict(recordingUrlsDict: recordingUrlsDict)
        if (visibleSections.contains(sortedRecordingUrls[section].key)){
            return sortedRecordingUrls[section].value.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerCellId) as? SectionHeader {
            let date = sortDict(recordingUrlsDict: recordingUrlsDict)[section].key
            headerView.delegate = self
            headerView.configureCell(date: date)
            //headerView.playAllBtn.addTarget(headerView, action: #selector(SectionHeader.startPulsing(_:)), for: .touchDown)
            headerView.playAllBtn.addTarget(headerView, action: #selector(SectionHeader.playRecordingTapped(_:)), for: .touchUpInside)
            
            return headerView
        }
        
        return UITableViewCell()
    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //
    //        let dateSortedKeys = recordingUrlsDict.keys.sorted { (date1, date2) -> Bool in
    //            guard let convertedDate1 = convertToDate(date: date1) else { return false }
    //            guard let convertedDate2 = convertToDate(date: date2) else { return false }
    //            return convertedDate1 > convertedDate2
    //        }
    //
    //        let date = dateSortedKeys[section]
    //
    //        let  isSectionRecordingsPlaying = CentralAudioPlayer.player.checkIfPlaying(id: date)
    //
    //        if isSectionRecordingsPlaying {
    //            return expandedSectionHeaderHeight
    //        }
    //        return sectionHeaderHeight
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //
    //        let recordings = sortDict(recordingUrlsDict: recordingUrlsDict)[indexPath.section]
    //        let url = sortUrlList(recordingsUrlList: recordings.value)[indexPath.row]
    //        let timeStamp = splitFileURL(url: url).timeStamp
    //
    //        let isPlaying = CentralAudioPlayer.player.checkIfPlaying(id: "\(timeStamp)")
    //        if isPlaying {
    //            return expandedRecordingCellHeight
    //        }
    //        return recordingCellHeight
    //    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: recordingCellId) as? RecordingCell {
            
            let recordings = sortDict(recordingUrlsDict: recordingUrlsDict)[indexPath.section]
            let url = sortUrlList(recordingsUrlList: recordings.value)[indexPath.row]
            
            cell.configureCell(url: url)
            cell.delegate = self
            
            if(recordingUrlsListToExport.contains(url)) {
                cell.selectCheckBox()
            } else {
                cell.deselectCheckBox()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    ///Stoppping the running timers in recording cell
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: recordingCellId) as? RecordingCell{
            cell.disableTimer()
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: headerCellId) as? RecordingCell{
            cell.disableTimer()
        }
    }
    
    func setHiddenVisibleSectionList() {
          
          let dateSortedKeys = recordingUrlsDict.keys.sorted { (date1, date2) -> Bool in
              guard let convertedDate1 = convertToDate(date: date1) else { return false }
              guard let convertedDate2 = convertToDate(date: date2) else { return false }
              return convertedDate1 > convertedDate2
          }
          if dateSortedKeys.count == 0 {return}
          
          if visibleSections.count == 0 {
              visibleSections.append(dateSortedKeys[0])
              for ind in 1..<dateSortedKeys.count {
                  hiddenSections.append(dateSortedKeys[ind])
              }
          } else {
              if !visibleSections.contains(dateSortedKeys[0]) {
                  showSection(date: dateSortedKeys[0])
              }
          }
      }
      
      func toggleSection(date: String) {
          if visibleSections.contains(date) {
              hideSection(date: date)
          } else {
              showSection(date: date)
          }
          updateRowsFor(recordingsOn: date)
          
          if visibleSections.contains(date) {
              DispatchQueue.main.async {
                  let dateSortedKeys = self.recordingUrlsDict.keys.sorted { (date1, date2) -> Bool in
                      guard let convertedDate1 = convertToDate(date: date1) else { return false }
                      guard let convertedDate2 = convertToDate(date: date2) else { return false }
                      return convertedDate1 > convertedDate2
                  }
                  
                  guard let sectionInd = dateSortedKeys.index(of : date) else { return }
                  let indexPath = IndexPath(row: 0, section: sectionInd)
                  self.recordingTableView.scrollToRow(at: indexPath, at: .top, animated: true)
              }
          }
      }
      
      func updateRowsFor(recordingsOn date: String) {
          
          findAndUpdateSection(date: date, recordingUrlsDict: recordingUrlsDict) { (section, urls) in
              
              self.recordingTableView.reloadSections([section], with: .automatic)
          }
      }
      
      func hideSection(date: String) {
          if hiddenSections.contains(date) {return}
          visibleSections = visibleSections.filter {$0 != date}
          hiddenSections.append(date)
      }
      
      func showSection(date: String) {
          if visibleSections.contains(date) {return}
          hiddenSections = hiddenSections.filter{$0 != date}
          visibleSections.append(date)
      }
      
      func checkIfHidden(date:String) -> Bool {
          return hiddenSections.contains(date)
      }
}
