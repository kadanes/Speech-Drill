//
//  DiscussionsMessageBox.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 12/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class DiscussionsMessageBox: UIView {
    
    let messageTextView: UITextView
    let sendMessageButton: UIButton
    
    required init(coder aDecoder: NSCoder) {
         //        countryCollectionView = UITableView()
         //          super.init(coder: aDecoder)
         fatalError("init(coder:) has not been implemented")
     }
    
    override init(frame: CGRect) {
        messageTextView = UITextView()
        sendMessageButton = UIButton()
        super.init(frame: frame)

        self.isUserInteractionEnabled = true

        self.addSubview(messageTextView)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.textColor = .white
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.clipsToBounds = true
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = accentColor.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.backgroundColor = UIColor.black.cgColor
        
        self.addSubview(sendMessageButton)
        sendMessageButton.translatesAutoresizingMaskIntoConstraints = false
        setButtonBgImage(button: sendMessageButton, bgImage:sendMessageIcon , tintColor: accentColor)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            messageTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            messageTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            messageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -10),
            
            sendMessageButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            sendMessageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 30),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
}
