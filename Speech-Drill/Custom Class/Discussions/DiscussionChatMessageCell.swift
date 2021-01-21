//
//  DiscussionChatMessageCell.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 13/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class DiscussionChatMessageCell: UITableViewCell {
    
    private let messageLabel: UITextView
    private let senderNameLabel: UILabel
    private let messageSentTimeLabel: UILabel
    private let messageBubble: UIView
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        messageLabel = UITextView()
        senderNameLabel = UILabel()
        messageSentTimeLabel = UILabel()
        messageBubble = UIView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(messageBubble)
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        
        messageBubble.addSubview(senderNameLabel)
        senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        senderNameLabel.numberOfLines = 0
        senderNameLabel.lineBreakMode = .byCharWrapping
        senderNameLabel.font =  getFont(name: .HelveticaNeueBold, size: .large)
        senderNameLabel.textColor = .white
        
        messageBubble.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.isEditable = false
        messageLabel.isSelectable = false
        messageLabel.dataDetectorTypes = .all
        messageLabel.textContainer.lineBreakMode = .byWordWrapping
        messageLabel.isScrollEnabled = false
        messageLabel.backgroundColor = .clear
        messageLabel.isUserInteractionEnabled = true
        
//        messageLabel.numberOfLines = 0
//        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = getFont(name: .HelveticaNeue, size: .medium)
        
        messageBubble.addSubview(messageSentTimeLabel)
        messageSentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        messageSentTimeLabel.lineBreakMode = .byCharWrapping
        messageSentTimeLabel.numberOfLines = 0
        messageSentTimeLabel.font = getFont(name: .HelveticaNeueItalic, size: .small)
        
        // set hugging and compression resistance for Name label
        senderNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        senderNameLabel.setContentHuggingPriority(.required, for: .vertical)
        
        // create bubble Leading and Trailing constraints
        bubbleLeadingConstraint = messageBubble.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10)
        bubbleTrailingConstraint = messageBubble.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10)
        
        // priority will be changed in configureCell()
        bubbleLeadingConstraint.priority = .defaultHigh
        bubbleTrailingConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            
            bubbleLeadingConstraint,
            bubbleTrailingConstraint,
            
            messageBubble.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            messageBubble.bottomAnchor.constraint(equalTo:  self.contentView.bottomAnchor, constant: -10),
            
            messageBubble.widthAnchor.constraint(lessThanOrEqualTo: self.contentView.widthAnchor, constant: -100),
            
            senderNameLabel.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: 10),
            senderNameLabel.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: 10),
            senderNameLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -10),
            
            messageLabel.topAnchor.constraint(equalTo: senderNameLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: messageSentTimeLabel.topAnchor, constant: -10),
            
            messageSentTimeLabel.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: 10),
            messageSentTimeLabel.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -10),
            messageSentTimeLabel.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -10),
            
        ])
        
        // corners will have radius: 10
        messageBubble.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(message: DiscussionMessage, isSender: Bool, previousMessage: DiscussionMessage?) {
        
        let senderName = isSender ? "You" : message.userName
        senderNameLabel.text = senderName + " " + message.userCountryEmoji
        
        let date = Date(timeIntervalSince1970: message.messageTimestamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.timeZone = .current
        
        dayTimePeriodFormatter.dateFormat = "hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date)
        
        messageLabel.text = message.message
        
        messageSentTimeLabel.text = dateString
        
        messageLabel.textColor = isSender ? .black : .white
        senderNameLabel.textColor = isSender ? .black : .white
        messageSentTimeLabel.textColor = isSender ? .black : .white
        messageSentTimeLabel.textAlignment = isSender ? .right : .left
        
        bubbleLeadingConstraint.priority = isSender ? .defaultLow : .defaultHigh
        bubbleTrailingConstraint.priority = isSender ? .defaultHigh : .defaultLow
        
        messageBubble.backgroundColor = isSender ? accentColor : .gray
        
        let senderCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        let nonSenderCorners: CACornerMask =  [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        
        messageBubble.layer.maskedCorners = isSender ?
            // topLeft, topRight, bottomRight
            senderCorners
            :
            // topLeft, topRight, bottomLeft
            nonSenderCorners
//
//        if let previousMessage = previousMessage {
//            if message.userEmailAddress == previousMessage.userEmailAddress && message.userCountryCode == previousMessage.userCountryCode && isSender {
//                senderNameLabel.isHidden = true
//            } else {
//                senderNameLabel.isHidden = false
//            }
//        } else {
//            senderNameLabel.isHidden = false
//        }
    }
}
