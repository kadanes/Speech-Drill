//
//  DiscussionChatView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 13/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class DiscussionChatView: UIView {
    
    let discussionChatId = "DiscussionChatID"
    let discussionTableView: UITableView
    let messages: [String]  = ["Some what long message", "Really really really long message that will overflow message bubble max width", "This one will also overflow by some good margin as it is a super long message. We might get 3 lines too? Need some more text", "Tiny response that is small", "Nom nom nom", "More messages", "More more more messages"]
    let isSender: [Bool] = [false, true, false, true, false, false, false]
        
    override init(frame: CGRect) {
        discussionTableView = UITableView()
        super.init(frame: frame)
        
        discussionTableView.register(DiscussionChatMessageCell.self, forCellReuseIdentifier: discussionChatId)
        discussionTableView.delegate = self
        discussionTableView.dataSource = self
        
        discussionTableView.estimatedRowHeight = 30
        discussionTableView.rowHeight = UITableViewAutomaticDimension
        
        self.addSubview(discussionTableView)
        discussionTableView.translatesAutoresizingMaskIntoConstraints = false
        discussionTableView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            discussionTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            discussionTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            discussionTableView.topAnchor.constraint(equalTo: self.topAnchor),
            discussionTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DiscussionChatView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let discussionChatMessageCell = tableView.dequeueReusableCell(withIdentifier: discussionChatId, for: indexPath) as? DiscussionChatMessageCell else { return UITableViewCell()}
        


        discussionChatMessageCell.configureCell(message: messages[indexPath.row], isSender: isSender[indexPath.row])

//                discussionChatMessageCell.setNeedsLayout()
//        discussionChatMessageCell.layoutIfNeeded()
//        discussionChatMessageCell.messageBubble.layoutIfNeeded()
//        discussionChatMessageCell.layoutIfNeeded()
        
        return discussionChatMessageCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
}
