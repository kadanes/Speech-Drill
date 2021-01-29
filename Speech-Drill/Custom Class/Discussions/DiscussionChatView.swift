//
//  DiscussionChatView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 13/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import FirebaseAuth

class DiscussionChatView: UIView {
    
    let discussionChatId = "DiscussionChatID"
    let discussionTableView: UITableView
    var messages: [String: [DiscussionMessage]]  = [:]
    var messageSendDates: [String] = []
    
    var userEmail = "UserNotLoggedIn"
    var first = true
    
    override init(frame: CGRect) {
        discussionTableView = UITableView()
        
        super.init(frame: frame)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendTapNotification))
        discussionTableView.addGestureRecognizer(tapRecognizer)
        
        //        saveUserEmail()
        
        discussionTableView.register(DiscussionChatMessageCell.self, forCellReuseIdentifier: discussionChatId)
        discussionTableView.delegate = self
        discussionTableView.dataSource = self
    
        discussionTableView.estimatedRowHeight = 30
        discussionTableView.rowHeight = UITableViewAutomaticDimension
        
        self.addSubview(discussionTableView)
        discussionTableView.translatesAutoresizingMaskIntoConstraints = false
        discussionTableView.backgroundColor = .clear
        discussionTableView.allowsSelection = false
        discussionTableView.separatorStyle = .none
        
        NSLayoutConstraint.activate([
            discussionTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            discussionTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            discussionTableView.topAnchor.constraint(equalTo: self.topAnchor),
            discussionTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        loadInitialMessages()
        appendNewMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadInitialMessages() {
        messagesReference.queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
//            print("Snapshot: ", snapshot, "\nValue: ", snapshot.value)
            
            guard let value = snapshot.value as? [String: Any] else {
                self.first = false
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let messages = try JSONDecoder().decode([String: DiscussionMessage].self, from: data)
                var messagesList = messages.map { $0.1 }
                messagesList = messagesList.sorted(by: {
                    $0.messageTimestamp < $1.messageTimestamp
                })
                
                for message in messagesList {
                    
                    let dateString = self.getDateString(from: message.messageTimestamp)
                    
                    if !self.messageSendDates.contains(dateString) {
                        self.messageSendDates.append(dateString)
                    }
                    
                    self.messages[dateString, default: [DiscussionMessage]()].append(message)
                }
                                
                self.discussionTableView.reloadData()
                self.scrollToSavedContentOffset()
            } catch {
                print(error)
            }
        }
    }
    
    func appendNewMessages() {
//        messagesReference.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
//        if self.first {
//                      self.scrollTableViewToEnd(animated: false)
//                      self.first = false
//                      return
//                  }
        
        messagesReference.queryOrdered(byChild: disucssionMessageTimestampKey).queryStarting(atValue: NSDate().timeIntervalSince1970).observe(.childAdded) { (snapshot) in
        
//            print("Snapshot: ", snapshot)
                        
            self.saveUserEmail()
            
            if  let value = snapshot.value {
                
//                print("Value: ", value)
                
                do {
                    
                    var lastCellWasVisible: Bool = false
                    if let visiblePaths = self.discussionTableView.indexPathsForVisibleRows {
                        print("Visible paths: ", visiblePaths) 
                        
                        print("Sections: ", self.messageSendDates.count - 1)
                        print("Row: ", self.messages[self.messageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1)
                        
                        lastCellWasVisible = visiblePaths.contains([self.messageSendDates.count - 1, self.messages[self.messageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1])
                    }
                    
                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    let message = try JSONDecoder().decode(DiscussionMessage.self, from: data)
                    
                    let dateString = self.getDateString(from: message.messageTimestamp)
                    
//                    print("Date string: ", dateString, " All dates:", self.messageSendDates)
                    
                    if !self.messageSendDates.contains(dateString) {
                        self.messageSendDates.append(dateString)
                        let indexSet = IndexSet(integer: self.messageSendDates.count - 1)
                        self.discussionTableView.performBatchUpdates({
//                            print("Index set")
                            self.discussionTableView.insertSections(indexSet, with: .automatic)
                            
                        }) { (update) in
                            print("After Update: Last cell visible", lastCellWasVisible)
                            self.insertMessage(dateString: dateString, message: message)
                        }
                    } else {
                        print("Without Update: Last cell visible", lastCellWasVisible)
                        self.insertMessage(dateString: dateString, message: message)
                    }
                    
                    if lastCellWasVisible {
                        self.scrollTableViewToEnd()
                        // This is not working
                    }
//                    else {
//                        Toast.show(message: "New Message", type: .Info)
//                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func insertMessage(dateString: String, message: DiscussionMessage) {
        messages[dateString, default: [DiscussionMessage]()].append(message)
        let indexPath = IndexPath(row:(self.messages[dateString, default: [DiscussionMessage]()].count - 1), section: self.messageSendDates.index(of: dateString) ?? 0)
//        print("Index path: ", indexPath)
        self.discussionTableView.insertRows(at: [indexPath], with: .automatic)
    }
}

extension DiscussionChatView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messageSendDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[messageSendDates[section], default: [DiscussionMessage]()] .count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let discussionChatMessageCell = tableView.dequeueReusableCell(withIdentifier: discussionChatId, for: indexPath) as? DiscussionChatMessageCell else { return UITableViewCell()}
        
        
        let message = messages[messageSendDates[indexPath.section], default: [DiscussionMessage]()][indexPath.row]
        
        var previousRow = indexPath.row - 1
        var previousSection = indexPath.section
        
        if previousRow < 0 {
            previousSection = indexPath.section - 1
            if previousSection >= 0 {
                previousRow = messages[messageSendDates[previousSection], default: [DiscussionMessage]()].count - 1
            }
        }
        
        var previousMessage: DiscussionMessage? = nil
        if previousRow >= 0 && previousSection >= 0 {
            previousMessage = messages[messageSendDates[previousSection], default: [DiscussionMessage]()][previousRow]
        }
            
        discussionChatMessageCell.configureCell(message:message, isSender: message.userEmailAddress == userEmail, previousMessage: previousMessage)
        
        return discussionChatMessageCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: discussionTableView.frame.size.width, height: 60))
        let headerLabel = UILabel(frame: CGRect(x: (discussionTableView.frame.size.width-100)/2, y: 20, width: 100, height: 40))
        
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.font = getFont(name: .HelveticaNeue, size: .medium)
        headerLabel.backgroundColor = UIColor.white
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.black
        
        headerLabelView.addSubview(headerLabel)
        headerLabel.clipsToBounds = true
        headerLabel.layer.cornerRadius = 10
        
        headerLabel.text = getDateStringForHeaderText(dateString: messageSendDates[section])
        
        return headerLabelView
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            if let cell = tableView.cellForRow(at: indexPath) as? DiscussionChatMessageCell {
                let pasteboard = UIPasteboard.general
                pasteboard.string = cell.getMessageLabel().text
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        storeContentOffset()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        storeContentOffset()
    }
}

//MARK:- Utility Functions

extension DiscussionChatView {
    
    func saveUserEmail() {
        
        guard let currrentUser = GIDSignIn.sharedInstance()?.currentUser  else {
            if userEmail == "UserNotLoggedIn" {
                return
            } else {
                userEmail = "UserNotLoggedIn"
                discussionTableView.reloadData()
            }
            return
        }
        
       userEmail = currrentUser.profile.email
       print("Email: ", userEmail)
       discussionTableView.reloadData()
    }
    
    func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }
    
    func getDate(from dateString: String) -> Date? {
        //        print("Date String: ", dateString)
        let dateFormatter = getDateFormatter()
        return dateFormatter.date(from: dateString) ?? nil
    }
    
    func getDateString(from timestamp: Double) -> String {
        let dateFormatter = getDateFormatter()
        let date = Date(timeIntervalSince1970: timestamp)
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func getDateStringForHeaderText(dateString: String) -> String {
        guard let date = getDate(from: dateString) else {
            //            print("Could not get date for generting header string")
            return dateString
        }
        //        print("Date: ", date.description(with: .current))
        if Calendar.current.isDateInToday(date) { return "Today"}
        if Calendar.current.isDateInYesterday(date) {return "Yesterday"}
        return dateString
    }
    
    func scrollTableViewToEnd(animated: Bool = true) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
            let indexPath = IndexPath(row: self.messages[self.messageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1, section: self.messageSendDates.count - 1)
            if self.discussionTableView.isValid(indexPath: indexPath) {
                self.discussionTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
        })
    }
    
    func storeContentOffset() {
        let defaults = UserDefaults.standard
        let oldYOffset: CGFloat = CGFloat(defaults.double(forKey: chatViewSeenYContentOffset) )
        let currentYOffset = discussionTableView.contentOffset.y
    
        if currentYOffset > oldYOffset {
            defaults.set(currentYOffset, forKey: chatViewSeenYContentOffset)
        }
    }
    
    func scrollToSavedContentOffset() {
        let defaults = UserDefaults.standard
        let oldYOffset: CGFloat = CGFloat(defaults.double(forKey: chatViewSeenYContentOffset) )
        let offset = CGPoint(x: 0, y: oldYOffset)
        self.discussionTableView.setContentOffset(offset, animated: true)
    }
}

//MARK:- Actions

extension DiscussionChatView {
    @objc func sendTapNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(chatViewTappedNotificationName), object: nil)
    }
}
