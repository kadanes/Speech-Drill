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
        
    private let messageLabel: UILabel
    private let senderNameLabel: UILabel
    private let messageBubble: UIView
    
    private var bubbleLeadingConstraint: NSLayoutConstraint!
    private var bubbleTrailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        messageLabel = UILabel()
        senderNameLabel = UILabel()
        messageBubble = UIView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        self.contentView.addSubview(messageBubble)
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        
        messageBubble.addSubview(senderNameLabel)
        senderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        senderNameLabel.numberOfLines = 0
        senderNameLabel.lineBreakMode = .byCharWrapping
        senderNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        senderNameLabel.textColor = .white
        
        messageBubble.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.textColor = .white
        
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
            messageLabel.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -10),
            
        ])
        
        // corners will have radius: 10
        messageBubble.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(message: DiscussionMessage, isSender: Bool) {
        senderNameLabel.text = message.userName + " " + message.userCountryEmoji
        
        let date = Date(timeIntervalSince1970: message.messageTimestamp)

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.timeZone = .current
        
        dayTimePeriodFormatter.dateFormat = "hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date)
        
        let messageFont:UIFont = UIFont(name: "Helvetica Neue", size: 13)!
        let sentTimeFont:UIFont = UIFont(name: "HelveticaNeue-ThinItalic", size: 11)!

        let messageTextAttributes = [NSAttributedString.Key.font: messageFont]
        
        let setTimeTextParagraphStyle =  NSMutableParagraphStyle()
        setTimeTextParagraphStyle.alignment = isSender ? .left : .left

        let sentTimeTextAttributes = [NSAttributedString.Key.font: sentTimeFont, NSAttributedString.Key.paragraphStyle: setTimeTextParagraphStyle]

        let messageString = NSMutableAttributedString(string: message.message + "\n\n",
        attributes: messageTextAttributes)
        
        let sentTimeString = NSMutableAttributedString(string: dateString, attributes: sentTimeTextAttributes)

        messageString.append(sentTimeString)
            
//        messageLabel.text = message.message + "\n\n" + dateString
        messageLabel.attributedText = messageString
                
        messageLabel.textColor = isSender ? .black : .white
        senderNameLabel.textColor = isSender ? .black : .white

        bubbleLeadingConstraint.priority = isSender ? .defaultLow : .defaultHigh
        bubbleTrailingConstraint.priority = isSender ? .defaultHigh : .defaultLow
        
        messageBubble.backgroundColor = isSender ? accentColor : .gray
        
        let senderCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        let nonSenderCorners: CACornerMask =  [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        if #available(iOS 11.0, *) {
            messageBubble.layer.maskedCorners = isSender ?
                // topLeft, topRight, bottomRight
                senderCorners
                :
                // topLeft, topRight, bottomLeft
                nonSenderCorners
        } else {
            // Fallback on earlier versions
            
            let corners: CACornerMask = isSender ? senderCorners : nonSenderCorners
            
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: 10, height: 10))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            messageBubble.layer.mask = mask
        }
        
    }
}
