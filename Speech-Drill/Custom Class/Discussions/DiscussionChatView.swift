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
    
    var scrolledToSavedPositionAfterLoadingChats = false
    var chatDataIsLoaded = false {
        didSet {
            //            scrollTableViewToEnd()
            if chatDataIsLoaded {
                discussionTableView.hideActivityIndicator()
                filterMessages()
            }
            
            if shouldScrollToMessageFromNotification {
                scrollToReceivedMessage(at: messageFromNotificationTimestamp, with: messageFromNotificationID)
            } else {
                scrollToLastReadMessage()
            }
        }
    }
    
    var isPresented = false {
        didSet {
            if shouldScrollToLastReadMessage {
                scrollToLastReadMessage()
            } else if shouldScrollToMessageFromNotification {
                scrollToReceivedMessage(at: messageFromNotificationTimestamp, with: messageFromNotificationID)
            }
        }
    }
    
    var shouldScrollToMessageFromNotification = false {
        didSet {
            scrollToReceivedMessage(at: messageFromNotificationTimestamp, with: messageFromNotificationID)
        }
    }
    
    var shouldScrollToLastReadMessage = false {
        didSet {
            scrollToLastReadMessage()
        }
    }
    
    var loadedAdminUsers = false {
        didSet {
            filterMessages()
        }
    }
    
    var loadedFilteredUsers = false {
        didSet {
            filterMessages()
        }
    }
    
    var loadededBlockedUsers = false {
        didSet {
            print("Loaded blocked users \(loadededBlockedUsers)")
            //            if loadededBlockedUsers {
            //                discussionTableView.reloadData()
            //            }
        }
    }
    
    var messageFromNotificationTimestamp: Double = 0
    var messageFromNotificationID: String? = nil
    var viewNotificationMessageAnimated: Bool = true
    
    let discussionChatId = "DiscussionChatID"
    let discussionTableView: UITableView
    var unfilteredMessages: [String: [DiscussionMessage]]  = [:]
    var unfilteredMessageSendDates: [String] = []
    
    var filteredMessages: [String: [DiscussionMessage]] = [:]
    var filteredMessageSendDates: [String] = []
    var adminUsers: [String] = [String]()
    var filteredUsers: [String] = [String]()
    var blockedUsers: [String] = [String]()
    
    let notLoggedInUserEmailId = "UserNotLoggedIn"
    var userEmail: String
    var first = true
    
    override init(frame: CGRect) {
        logger.info("Initializing chat view")
        
        discussionTableView = UITableView(frame: CGRect.zero, style: .grouped)
        userEmail = notLoggedInUserEmailId
        super.init(frame: frame)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendTapNotification))
        discussionTableView.addGestureRecognizer(tapRecognizer)
        
        discussionTableView.showActivityIndicator()
        discussionTableView.register(DiscussionChatMessageCell.self, forCellReuseIdentifier: discussionChatId)
        discussionTableView.delegate = self
        discussionTableView.dataSource = self
        
        discussionTableView.estimatedRowHeight = 300
        discussionTableView.rowHeight = UITableViewAutomaticDimension
        discussionTableView.sectionFooterHeight = 0
        
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
        loadGroupUserList()
        loadInitialMessages()
        appendNewMessages()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadGroupUserList() {
        logger.info("Loading user group lists")
        
        adminGroupReference.observe(.value) { (snapshot) in
            if let admins = snapshot.value as? [String: Any] {
                self.adminUsers = Array(admins.keys)
                self.loadedAdminUsers = true
            } else if !snapshot.exists() {
                self.loadedAdminUsers = true
                self.adminUsers = [String]()
            }
            logger.debug("Admin Users: \(self.adminUsers)")
        }
        filteredGroupReference.observe(.value) { (snapshot) in
            if let filtered = snapshot.value as? [String: Any] {
                self.filteredUsers = Array(filtered.keys)
                self.loadedFilteredUsers = true
            } else if !snapshot.exists() {
                self.loadedFilteredUsers = true
                self.filteredUsers = [String]()
            }
            logger.debug("Filtered Users: \(self.filteredUsers)")
        }
        blockedGroupReference.observe(.value) { (snapshot) in
            if let blocked = snapshot.value as? [String: Any] {
                self.blockedUsers = Array(blocked.keys)
                self.loadededBlockedUsers = true
            } else if !snapshot.exists() {
                self.loadededBlockedUsers = true
                self.blockedUsers = [String]()
            }
            self.discussionTableView.reloadData()
            logger.debug("Blocked Users: \(self.blockedUsers)")
        }
    }
    
    func shouldFilterMessages() -> Bool {
        logger.info("Checking if messages should be filtered")
        
        //        guard let filteredUsers = filteredUsers else { return false }
        //        let adminUsers = self.adminUsers
        let currentUserName = getAuthenticatedUsername() ?? ""
        
        if adminUsers.contains(currentUserName) || filteredUsers.contains(currentUserName)  {
            //            print("Should not filter messages")
            return false
        }
        //        print("Should filter messages")
        return true
    }
    
    func filterMessages() {
        logger.debug("Trying to filter messages with senders: \(filteredUsers)")
        
        if !chatDataIsLoaded {
            logger.debug("Returning without filtering")
            return
        }
        
        if !shouldFilterMessages() {
            logger.debug("Returning without filtering as should not filter")
            return
        }
        //        guard let filteredUsers = filteredUsers else { return }
        
        filteredMessages = [String: [DiscussionMessage]]()
        filteredMessageSendDates = [String]()
        
        for messageSendDate in unfilteredMessageSendDates {
            if let messagesForDate = unfilteredMessages[messageSendDate] {
                let filteredMessagesForDate = messagesForDate.filter({
                    !(filteredUsers.contains(getUsernameFromEmail(email: $0.userEmailAddress) ?? "" ))
                    
                })
                if filteredMessagesForDate.count > 0 {
                    filteredMessageSendDates.append(messageSendDate)
                    filteredMessages[messageSendDate] = filteredMessagesForDate
                }
            }
        }
        logger.info("Reloading chat tableview after filtering messages")
        discussionTableView.reloadData()
    }
    
    func shouldFilterIn(message: DiscussionMessage) -> Bool {
        logger.info("Checking if message with id \(message.messageID ?? "NIL") should be filtered in")
        
        let messageSenderUserName = getUsernameFromEmail(email: message.userEmailAddress) ?? ""
        if filteredUsers.contains(messageSenderUserName) { return false}
        return true
    }
    
    func getMessages() -> [String: [DiscussionMessage]] {
        logger.info("Getting filtered/unfiltered messages")
        return shouldFilterMessages() ? filteredMessages : unfilteredMessages
    }
    
    func getMessageSendDates() -> [String] {
        logger.info("Getting filtered/unfiltered message send dates")
        return shouldFilterMessages() ? filteredMessageSendDates : unfilteredMessageSendDates
    }
    
    func loadInitialMessages() {
        logger.info("Loading initial messages")
        messagesReference.queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            //            print("Snapshot: ", snapshot, "\nValue: ", snapshot.value)
            
            guard let value = snapshot.value as? [String: Any] else {
                self.first = false
                self.chatDataIsLoaded = true
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
                    
                    let dateString = getDateString(from: message.messageTimestamp)
                    
                    if !self.unfilteredMessageSendDates.contains(dateString) {
                        self.unfilteredMessageSendDates.append(dateString)
                    }
                    
                    self.unfilteredMessages[dateString, default: [DiscussionMessage]()].append(message)
                }
                
                self.discussionTableView.reloadData()
                self.chatDataIsLoaded = true
                self.filterMessages()
                
            } catch {
                logger.error("Error fetching inital messages: \(error)")
            }
        }
    }
    
    func appendNewMessages() {
        logger.info("Setting up new messages listner")
        //        messagesReference.queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
        //        if self.first {
        //                      self.scrollTableViewToEnd(animated: false)
        //                      self.first = false
        //                      return
        //                  }
        let discussionMessageTimestampKey = DiscussionMessage.CodingKeys.messageTimestamp.stringValue
        messagesReference.queryOrdered(byChild: discussionMessageTimestampKey).queryStarting(atValue: NSDate().timeIntervalSince1970).observe(.childAdded) { (snapshot) in
            
            //            print("Snapshot: ", snapshot)
            
            self.saveUserEmail()
            
            if  let value = snapshot.value {
                
                //                print("Value: ", value)
                
                do {
                    
                    var lastCellWasVisible: Bool = false
                    if let visiblePaths = self.discussionTableView.indexPathsForVisibleRows {
                        //                        print("Visible paths: ", visiblePaths)
                        //                        print("Sections: ", self.messageSendDates.count - 1)
                        //                        print("Row: ", self.messages[self.messageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1)
                        
                        lastCellWasVisible = visiblePaths.contains([self.unfilteredMessageSendDates.count - 1, self.unfilteredMessages[self.unfilteredMessageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1])
                    }
                    
                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    let message = try JSONDecoder().decode(DiscussionMessage.self, from: data)
                    
                    //                    let dateString = self.getDateString(from: message.messageTimestamp)
                    
                    self.insertNewMessage(message: message)
                    
                    if lastCellWasVisible {
                        self.scrollTableViewToEnd()
                        // This is not working
                    }
                    //                    else {
                    //                        Toast.show(message: "New Message", type: .Info)
                    //                    }
                } catch {
                    logger.error("Error appending new message: \(value), \(error)")
                }
            }
        }
    }
    
    func insertNewMessage(message: DiscussionMessage) {
        logger.info("Inserting new message send date in data source, section in chat table view")
        
        let sentDateString = getDateString(from: message.messageTimestamp)
        let shouldFilterInMessage = shouldFilterIn(message: message)
        
        var isNewSection = false
        
        if !unfilteredMessageSendDates.contains(sentDateString) {
            unfilteredMessageSendDates.append(sentDateString)
            if !shouldFilterMessages() {
                isNewSection = true
            }
        }
        
        if shouldFilterMessages() && !shouldFilterInMessage {
            unfilteredMessages[sentDateString, default: [DiscussionMessage]()].append(message)
            return
        }
        
        if shouldFilterInMessage && !filteredMessageSendDates.contains(sentDateString) {
            filteredMessageSendDates.append(sentDateString)
            if shouldFilterMessages() {
                isNewSection = true
            }
        }
        
        if isNewSection {
            let indexSet = IndexSet(integer: self.getMessageSendDates().count - 1)
            
            discussionTableView.performBatchUpdates({
                discussionTableView.insertSections(indexSet, with: .automatic)
                
            }) { (update) in
                self.insertRow(with: message, at: sentDateString)
            }
        } else {
            self.insertRow(with: message, at: sentDateString)
        }
    }
    
    func insertNewMessage(message: DiscussionMessage,at sentAtDateString: String) {
        logger.info("Inserting new message in data source")
        
        if shouldFilterIn(message: message) {
            filteredMessages[sentAtDateString, default: [DiscussionMessage]()].append(message)
        }
        unfilteredMessages[sentAtDateString, default: [DiscussionMessage]()].append(message)
    }
    
    func insertRow(with message: DiscussionMessage,at sentAtDateString: String) {
        logger.info("Inserting row in chat table view")
        
        insertNewMessage(message: message, at: sentAtDateString)
        
        let messages = getMessages()
        let messageSendDates = getMessageSendDates()
        
        let indexPath = IndexPath(row:(messages[sentAtDateString, default: [DiscussionMessage]()].count - 1), section: messageSendDates.index(of: sentAtDateString) ?? 0)
        
        self.discussionTableView.insertRows(at: [indexPath], with: .automatic)
    }
}

extension DiscussionChatView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //        print("Section dates: \( getMessageSendDates()), count: \(getMessageSendDates().count)")
        print("Number of rows in section:")
        printMessageDetails()
        return getMessageSendDates().count
        
        //        if shouldFilterMessage() {
        //            return filteredMessages.count
        //        }
        //        return unfilteredMessageSendDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let messages = getMessages()
        let messageSendDates = getMessageSendDates()
        return messages[messageSendDates[section], default: [DiscussionMessage]()].count
        
        //        if shouldFilterMessage() {
        //            return filteredMessages[filteredMessageSendDates[section], default: [DiscussionMessage]()].count
        //        }
        //        return unfilteredMessages[unfilteredMessageSendDates[section], default: [DiscussionMessage]()].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        print("Presenting cell: ", indexPath)
        
        guard let discussionChatMessageCell = tableView.dequeueReusableCell(withIdentifier: discussionChatId, for: indexPath) as? DiscussionChatMessageCell else { return UITableViewCell()}
        
        let messages = getMessages()
        let messageSendDates = getMessageSendDates()
        
        guard indexPath.section < messageSendDates.count, let messagesForSection = messages[messageSendDates[indexPath.section]], indexPath.row < messagesForSection.count else {
            NSLog("\(indexPath) is out of bounds for displaying message cell")
            return UITableViewCell()
        }
        
        let message = messagesForSection[indexPath.row]
        //        let message = messages[messageSendDates[indexPath.section], default: [DiscussionMessage]()][indexPath.row]
        
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
        
        if let visibleRows = tableView.indexPathsForVisibleRows, visibleRows.contains(indexPath) {
            //            print("Presenting Cell is visible: ", indexPath)
            discussionChatMessageCell.updateLastReadMessageTimestamp(message: message)
        }
        
        return discussionChatMessageCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: discussionTableView.frame.size.width, height: 40))
        let headerLabel = UILabel(frame: CGRect(x: (discussionTableView.frame.size.width-100)/2, y: 0, width: 100, height: 40))
        
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.font = getFont(name: .HelveticaNeueBold, size: .medium)
        headerLabel.backgroundColor = .clear
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.white
        
        headerLabelView.addSubview(headerLabel)
        headerLabel.clipsToBounds = true
        headerLabel.layer.cornerRadius = 10
        
        headerLabel.text = getDateStringForHeaderText(dateString: getMessageSendDates()[section])
        
        return headerLabelView
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
        if let visibleRows = tableView.indexPathsForVisibleRows, visibleRows.contains(indexPath) {
            //            print("Displaying Cell is visible: ", indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
    
    //    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        guard let userName = getAuthenticatedUsername(), //let adminUsers = adminUsers,
    //              adminUsers.contains(userName) else {
    //            return nil
    //        }
    //
    //        var contextualActions: [UIContextualAction] = [UIContextualAction]()
    //
    //        let showToggleGroupAction: (Bool, DiscussionMessage?) = shouldShowToggleGroupAction(indexPath: indexPath)
    //
    //        if showToggleGroupAction.0, let message = showToggleGroupAction.1 {
    //            contextualActions.append(getToggleFilterUserContextualAction(message: message))
    //            contextualActions.append(getToggleBlockedUserContextualAction(message: message))
    //        }
    //
    //        return UISwipeActionsConfiguration(actions: contextualActions)
    //    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let userName = getAuthenticatedUsername(), //let adminUsers = adminUsers,
              adminUsers.contains(userName) else {
            return nil
        }
        
        var contextualActions: [UIContextualAction] = [UIContextualAction]()
        
        let showToggleGroupAction: (Bool, DiscussionMessage?) = shouldShowToggleGroupAction(indexPath: indexPath)
        
        if showToggleGroupAction.0, let message = showToggleGroupAction.1 {
            contextualActions.append(getToggleFilterUserContextualAction(message: message))
            contextualActions.append(getToggleBlockedUserContextualAction(message: message))
        }
        
        let showDeleteAction = shouldShowDeleteMessageAction(indexPath: indexPath)
        
        if showDeleteAction.0, let messageID = showDeleteAction.1 {
            contextualActions.insert(getDeleteMessageContextualAction(messageID: messageID), at: 0)
        }
        
        if contextualActions.count == 0 { return nil }
        
        return UISwipeActionsConfiguration(actions: contextualActions)
    }
    
    func safeGetMessage(at indexPath: IndexPath) -> DiscussionMessage? {
        logger.info("Safely unwrapping and getting messages")
        
        let messageSendDates = getMessageSendDates()
        let messages = getMessages()
        
        guard let messageSendDate = messageSendDates[safe: indexPath.section], let messagesOnSendDate = messages[messageSendDate], let message = messagesOnSendDate[safe: indexPath.row] else { return  nil }
        return message
    }
    
    func shouldShowToggleGroupAction(indexPath: IndexPath) -> (Bool, DiscussionMessage?) {
        logger.info("Checking if toggle group swipe actions should be showed")
        
        guard let message = safeGetMessage(at: indexPath) else { return (false, nil)}
        
        guard let senderUserName = getUsernameFromEmail(email: message.userEmailAddress), !adminUsers.contains(senderUserName) else {
            return  (false, nil)
        }
        
        return (true, message)
    }
    
    func shouldShowDeleteMessageAction(indexPath: IndexPath) -> (Bool, String?) {
        logger.info("Checking if delete message swipe actions should be showed")
        
        guard let message = safeGetMessage(at: indexPath), let messageID = message.messageID else { return (false, nil)}
        return (true, messageID)
    }
    
    func getToggleFilterUserContextualAction(message: DiscussionMessage) -> UIContextualAction {
        logger.info("Setting up toggle filter user swipe action")
        
        //        let filteredUsers = self.filteredUsers ?? [String]()
        
        var canAddUserToFilteredGroup = true
        let senderUserName = getUsernameFromEmail(email: message.userEmailAddress)
        
        if filteredUsers.contains(senderUserName ?? "") {
            canAddUserToFilteredGroup = false
        }
        
        
        let action = UIContextualAction(style: .normal, title: "Filter") { (action, view, completion) in
            logger.event("Filtering/Unfiltering user \(senderUserName ?? "NIL")")
            //            guard let filteredUsers = self.filteredUsers else { completion(false) }
            
            guard let senderUserName = senderUserName else {
                completion(false)
                return
            }
            
            addOrRemoveUser(from: .FILTERED, userName: senderUserName, fcmToken: message.fcmToken)
            
            completion(true)
            
        }
        
        action.image = canAddUserToFilteredGroup ? filteredUserIcon : unfilteredUserIcon
        action.backgroundColor = canAddUserToFilteredGroup ? .orange : confirmGreen
        action.title = canAddUserToFilteredGroup ? "Filter" : "Unfilter"
        return action
    }
    
    func getToggleBlockedUserContextualAction(message: DiscussionMessage) -> UIContextualAction {
        logger.info("Setting up toggle block user swipe action")
        //        let filteredUsers = self.filteredUsers ?? [String]()
        
        var canAddUserToBlockedGroup = true
        let senderUserName = getUsernameFromEmail(email: message.userEmailAddress)
        
        if blockedUsers.contains(senderUserName ?? "") {
            canAddUserToBlockedGroup = false
        }
        
        
        let action = UIContextualAction(style: .normal, title: "Block User") { (action, view, completion) in
            logger.event("Blocking/Unblocking user \(senderUserName ?? "NIL")")
            
            //            guard let filteredUsers = self.filteredUsers else { completion(false) }
            
            guard let senderUserName = senderUserName else {
                completion(false)
                return
            }
            
            addOrRemoveUser(from: .BLOCKED, userName: senderUserName, fcmToken: message.fcmToken)
            
            completion(true)
            
        }
        
        action.image = canAddUserToBlockedGroup ? blockedUserIcon : unblockedUserIcon
        action.backgroundColor = canAddUserToBlockedGroup ? enabledRed : confirmGreen
        action.title = canAddUserToBlockedGroup ? "Block" : "Unblock"
        return action
    }
    
    
    func getDeleteMessageContextualAction(messageID: String) -> UIContextualAction {
        logger.info("Setting up delete message swipe action")
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            logger.event("Deleting message with id \(messageID)")
            
            messagesReference.child(messageID).setValue(nil) { (error, ref) in
                guard error == nil else {
                    completion(false)
                    return
                }
                self.deleteMessage(with: messageID)
                self.discussionTableView.reloadData()
                completion(true)
            }
        }
        
        action.image = deleteMessageIcon
        action.backgroundColor = disabledRed
        return action
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        storeContentOffset()
        saveReadTimestampForVisibleCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        storeContentOffset()
        saveReadTimestampForVisibleCell()
    }
}

//MARK:- Utility Functions
extension DiscussionChatView {
    
    func saveUserEmail() {
        logger.info("Saving user email and reloading tableview")
        
        filterMessages()
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            //            if self.userEmail == notLoggedInUserEmailId {
            //                print("userEmail == notLoggedInUserEmailId")
            //                discussionTableView.reloadData()
            //            } else {
            //                print("userEmail != notLoggedInUserEmailId")
            //                self.userEmail = notLoggedInUserEmailId
            //                discussionTableView.reloadData()
            //            }
            self.userEmail = notLoggedInUserEmailId
            discussionTableView.reloadData()
            printMessageDetails()
            return
        }
        
        self.userEmail = userEmail
        printMessageDetails()
        discussionTableView.reloadData()
    }
    
    func printMessageDetails() {
        logger.info("Printing message details")
        logger.debug("Email: \(userEmail)")
        logger.debug("Messages: \(unfilteredMessages)")
        logger.debug("Send Dates: \(unfilteredMessageSendDates)")
        logger.debug("Filtered Messages: \(filteredMessages)")
        logger.debug("Filtered Send Dates: \(filteredMessageSendDates)")
        logger.debug("Should filter message? \(shouldFilterMessages()), Filtered Users: \(filteredUsers)")
    }
    
    func getDateStringForHeaderText(dateString: String) -> String {
        logger.info("Getting date string for header")
        
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
        logger.info("Scrolling tableview to end")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
            let messages = self.getMessages()
            let messageSendDates = self.getMessageSendDates()
            let indexPath = IndexPath(row: messages[messageSendDates.last ?? "", default: [DiscussionMessage]()].count - 1, section: messageSendDates.count - 1)
            if self.discussionTableView.isValid(indexPath: indexPath) {
                self.discussionTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
            }
        })
    }
    
    func storeContentOffset() {
        logger.info("Storing content offset")
        
        discussionTableView.layoutIfNeeded()
        let defaults = UserDefaults.standard
        let maxOffsetY = max(0, discussionTableView.maxContentOffset.y)
        var oldYOffset = CGFloat(defaults.double(forKey: chatViewSeenYContentOffsetKey))
        oldYOffset = min(oldYOffset, maxOffsetY)
        let currentYOffset = discussionTableView.contentOffset.y
        let shouldSaveNewOffset: Bool = currentYOffset > oldYOffset
        
        //        print("Will save new chat scroll offset \(currentYOffset)? \(shouldSaveNewOffset)")
        if shouldSaveNewOffset {
            defaults.set(currentYOffset, forKey: chatViewSeenYContentOffsetKey)
        }
    }
    
    func scrollToSavedContentOffset() {
        logger.info("Scrolling to saved content offset")
        
        if !chatDataIsLoaded {
            //            print("Not scrolling to saved offset as chat data is not loaded")
            return
        }
        
        discussionTableView.layoutIfNeeded()
        let defaults = UserDefaults.standard
        var oldYOffset: CGFloat = CGFloat(defaults.double(forKey: chatViewSeenYContentOffsetKey))
        let maxOffsetY = self.discussionTableView.maxContentOffset.y
        //        print("Max offset: ",maxOffsetY, " Saved offset: ", oldYOffset)
        
        if maxOffsetY < 0 {
            return
        }
        if scrolledToSavedPositionAfterLoadingChats {
            //            print("Already scrolled to saved position after loading chats")
            return
        }
        
        oldYOffset =  min(oldYOffset, maxOffsetY)
        let offset = CGPoint(x: 0, y: oldYOffset)
        
        DispatchQueue.main.async {
            //            print("Scrolling to seen end:")
            self.discussionTableView.setContentOffset(offset, animated: true)
            self.scrolledToSavedPositionAfterLoadingChats = true
        }
    }
}

//MARK:- Actions
extension DiscussionChatView {
    @objc func sendTapNotification() {
        logger.event("Chat view tapped")
        NotificationCenter.default.post(name: NSNotification.Name(chatViewTappedNotificationName), object: nil)
    }
    
    
    func deleteMessage(with messageID: String) {
        
        logger.info("Deleting message with id \(messageID) from unfiltered messages")
        
        (unfilteredMessageSendDates, unfilteredMessages) = deleteMessage(with: messageID, sendDates: unfilteredMessageSendDates, messages: unfilteredMessages)
        //        unfilteredMessageSendDates = updatedUnfilteredMessages.0
        //        unfilteredMessages = updatedUnfilteredMessages.1
        
        logger.info("Deleting message with id \(messageID) from filtered messages")
        
        (filteredMessageSendDates, filteredMessages) = deleteMessage(with: messageID, sendDates: filteredMessageSendDates, messages: filteredMessages)
        
    }
    
    func deleteMessage(with messageID: String, sendDates: [String], messages: [String: [DiscussionMessage]]) -> ([String], [String: [DiscussionMessage]]) {
        findMessageUsingMessageID(sendDates: sendDates, messages: messages, messageID: messageID) { (section, row) in
            logger.info("Deleting message info with id \(messageID) from datasource and send dates")
            
            var localMessages = messages
            var localSendDates = sendDates
            
            logger.debug("Before deleting: \nLocal Messages: \(localMessages) \nLocal Send Dates: \(localSendDates)")
            
            localMessages[localSendDates[section]]?.remove(at: row)
            if localMessages[localSendDates[section]]?.count == 0 {
                localSendDates.remove(at: section)
            }
            
            logger.debug("After deleting: \nLocal Messages: \(localMessages) \nLocal Send Dates: \(localSendDates)")
            return (localSendDates, localMessages)
        }
    }
    
    func findMessageUsingMessageID(sendDates: [String], messages: [String: [DiscussionMessage]], messageID: String, completion: @escaping (_ section: Int, _ row: Int) -> ([String], [String: [DiscussionMessage]])) -> ([String], [String: [DiscussionMessage]]) {
        logger.info("Finding message with id \(messageID)")
        
        for (section, sendDate) in sendDates.enumerated().reversed() {
            logger.debug("Found \(sendDate) at position \(section)")
            for (row, message) in messages[sendDate, default: [DiscussionMessage]()].enumerated().reversed() {
                logger.debug("Found \(message.messageID ?? "NIL") at position \(row)")
                if messageID == message.messageID {
                    return completion(section, row)
                }
            }
        }
        
        return (sendDates, messages)
    }
    
    func findMessageUsingTimestampOrID(messageTimestamp: Double, messageID: String?,  completion: @escaping (_ section: Int, _ row: Int) -> Void) {
        let defaults = UserDefaults.standard
        
        logger.info("Finding message with timestamp \(messageTimestamp), and id \(messageID ?? "NIL")")
        
        if messageTimestamp == 0 {
            completion(0, 0)
        }
        
        let messages = self.getMessages()
        let messageSendDates = self.getMessageSendDates()
        
        
        if let lastMessageDate = messageSendDates.last {
            if let lastSendDateMessages = messages[lastMessageDate], let lastMessage = lastSendDateMessages.last {
                if lastMessage.messageTimestamp <= messageTimestamp {
                    if lastMessage.messageTimestamp < messageTimestamp {
                        defaults.setValue(lastMessage.messageTimestamp, forKey: lastReadMessageTimestampKey)
                        defaults.setValue(lastMessage.messageID, forKey: lastReadMessageIDKey)
                        saveLastReadMessageTimestamp()
                    }
                    return completion(messageSendDates.count - 1, lastSendDateMessages.count - 1)
                }
            }
        }
        
        let lastReadMessageDateString = getDateString(from: messageTimestamp)
        guard let lastReadMessageDayIndex = messageSendDates.index(of: lastReadMessageDateString), let lastReadMessageDayMessages = messages[messageSendDates[lastReadMessageDayIndex]] else { return }
        
        var foundLastReadMessage = false
        var lastReadMessageIndex = 0
        for (row, message) in lastReadMessageDayMessages.enumerated() {
            if let lastReadMessageID = messageID, let messageID = message.messageID {
                if messageID == lastReadMessageID {
                    foundLastReadMessage = true
                    lastReadMessageIndex = row
                    break
                }
            } else {
                if message.messageTimestamp == messageTimestamp {
                    foundLastReadMessage = true
                    lastReadMessageIndex = row
                    break
                }
            }
        }
        if foundLastReadMessage {
            return completion(lastReadMessageDayIndex, lastReadMessageIndex)
        }
    }
    
    
    func setReseivedMessageInfo(at messageTimestamp: Double, with messageID: String?, viewAnimated: Bool = true) {
        logger.info("Setting message notification info timestamp \(messageTimestamp), id \(messageID ?? "NIL") and animated ?= \(viewAnimated)")
        
        messageFromNotificationTimestamp = messageTimestamp
        messageFromNotificationID = messageID
        viewNotificationMessageAnimated = viewAnimated
        shouldScrollToMessageFromNotification = true
        
    }
    
    private func scrollToReceivedMessage(at messageTimestamp: Double, with messageID: String?) {
        logger.info("Scrolling to message with timestamp \(messageTimestamp) and id \(messageID ?? "NIL")")
        
        if !chatDataIsLoaded || !isPresented || !shouldScrollToMessageFromNotification {
            return
        }
        
        findMessageUsingTimestampOrID(messageTimestamp: messageTimestamp, messageID: messageID) { (section, row) in
            logger.debug("Scrolling to row \(row) section \(section)")
            let scrollToIndexPath = IndexPath(row: row, section: section)
            if self.discussionTableView.isValid(indexPath: scrollToIndexPath) {
                self.discussionTableView.scrollToRow(at: scrollToIndexPath, at: .bottom, animated: self.viewNotificationMessageAnimated)
            }
        }
        shouldScrollToMessageFromNotification = false
    }
    
    private func scrollToLastReadMessage() {
        logger.info("Scrolling to last read message")
        
        if !chatDataIsLoaded || !isPresented {
            logger.debug("Not scrolling to last read message chat data loaded ?= \(chatDataIsLoaded) or is presented for the first time ?= \(isPresented)")
            return
        }
        
        let defaults = UserDefaults.standard
        let lastReadMessageTimestamp = defaults.double(forKey: lastReadMessageTimestampKey)
        let lastReadMessageID = defaults.string(forKey: lastReadMessageIDKey)
        
        findMessageUsingTimestampOrID(messageTimestamp: lastReadMessageTimestamp, messageID: lastReadMessageID) { (section, row) in
            let scrollToIndexPath = IndexPath(row: row, section: section)
            //            if let visibleRows = self.discussionTableView.indexPathsForVisibleRows {
            //                if visibleRows.contains(scrollToIndexPath) { return }
            //            }
            if self.discussionTableView.isValid(indexPath: scrollToIndexPath) {
                self.discussionTableView.scrollToRow(at: scrollToIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    //    func scrollToLastReadMessage(messageTimestamp: Double? = nil, messageId: String? = nil) {
    //        return
    //        let defaults = UserDefaults.standard
    //
    //        var lastReadMessageTimestamp: Double = 0
    //        var lastReadMessageID: String? = nil
    //
    //        if let messageTimestamp = messageTimestamp {
    //            lastReadMessageTimestamp = messageTimestamp
    //            lastReadMessageID = messageId
    //        } else {
    //            lastReadMessageTimestamp = defaults.double(forKey: lastReadMessageTimestampKey)
    //            lastReadMessageID = defaults.string(forKey: lastReadMessageIDKey)
    //        }
    //
    //       NSLog("Last Read Message TS: \(lastReadMessageTimestamp), ID: \(lastReadMessageID)")
    //
    //        if !chatDataIsLoaded || !isPresentedForTheFirstTime {
    //            print("Not scrolling to saved offset as chat data loaded \(chatDataIsLoaded) or is presented for the first time \(isPresentedForTheFirstTime)")
    //            return
    //        }
    //
    ////        return
    //
    //
    //    }
    
    func saveReadTimestampForVisibleCell() {
        logger.info("Updating last read timestamp using visible cells")
        
        guard let visibleRows = discussionTableView.indexPathsForVisibleRows else { return }
        //        print(visibleRows)
        let messages = getMessages()
        let messageSendDates = getMessageSendDates()
        
        for visibleRow in visibleRows {
            if let discussionCell = discussionTableView.cellForRow(at: visibleRow) as? DiscussionChatMessageCell {
                //                print("Visible row: \(visibleRow)")
                if visibleRow.section < messageSendDates.count {
                    let messageSendDate = messageSendDates[visibleRow.section]
                    if let messagesOnSendDate = messages[messageSendDate], visibleRow.row < messagesOnSendDate.count {
                        let message = messagesOnSendDate[visibleRow.row]
                        discussionCell.updateLastReadMessageTimestamp(message: message)
                    }
                }
            }
        }
    }
}
