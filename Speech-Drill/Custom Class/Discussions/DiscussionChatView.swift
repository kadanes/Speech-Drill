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
        
        saveUserEmail()
        
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
            
            guard let value = snapshot.value as? [String: Any] else {return}
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
            } catch {
                print(error)
            }
        }
    }
    
    func appendNewMessages() {
        messagesReference.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
            
            if self.first {
                self.first = false
                return
            }
            
            self.saveUserEmail()
            
            if  let value = snapshot.value {
                do {
                    
                    var lastCellWasVisible: Bool = false
                    if let visiblePaths = self.discussionTableView.indexPathsForVisibleRows {
                        
                        lastCellWasVisible = visiblePaths.contains([self.messageSendDates.count - 1, self.messages[self.messageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1])
                    }
                    
                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    let message = try JSONDecoder().decode(DiscussionMessage.self, from: data)
                    
                    let dateString = self.getDateString(from: message.messageTimestamp)
                    
                    if !self.messageSendDates.contains(dateString) {
                        self.messageSendDates.append(dateString)
                    }
                    
                    self.messages[dateString, default: [DiscussionMessage]()].append(message)
                    
                    
//                    self.discussionTableView.reloadData() //Make this push cell
                    
                    let indexPath = IndexPath(row:(self.messages[dateString, default: [DiscussionMessage]()].count - 1), section: self.messageSendDates.index(of: dateString) ?? 0)
                    self.discussionTableView.insertRows(at:[indexPath], with: .left)
                    
                    if lastCellWasVisible {
                        self.scrollTableViewToEnd()
                    } else {
                        Toast.show(message: "New Message", type: .Info)
                    }
                } catch {
                    print(error)
                }
            }
        }
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
        discussionChatMessageCell.configureCell(message:message, isSender: message.userEmailAddress == userEmail)
        
        return discussionChatMessageCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: discussionTableView.frame.size.width, height: 60))
        let headerLabel = UILabel(frame: CGRect(x: (discussionTableView.frame.size.width-100)/2, y: 20, width: 100, height: 40))
        
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.font = UIFont(name: "Helvetica Neue", size: 13)!
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: NSNotification.Name(chatViewScrolledNotificationName), object: nil)
    }
    
}

//MARK:- Utility Functions

extension DiscussionChatView {
    
    func saveUserEmail() {
        if userEmail != "UserNotLoggedIn" { return }
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            userEmail = currentUser.profile.email
            print("Email: ", userEmail)
            discussionTableView.reloadData()
        }
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
}
