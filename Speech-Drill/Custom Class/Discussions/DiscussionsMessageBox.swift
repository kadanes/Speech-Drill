//
//  DiscussionsMessageBox.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 12/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

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

        messageTextView.delegate = self
        self.addSubview(messageTextView)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.textColor = .white
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.clipsToBounds = true
        messageTextView.layer.cornerRadius = 5
        messageTextView.layer.borderColor = accentColor.cgColor
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.backgroundColor = UIColor.black.cgColor
        messageTextView.isScrollEnabled = false
        
        self.addSubview(sendMessageButton)
        sendMessageButton.translatesAutoresizingMaskIntoConstraints = false
        setButtonBgImage(button: sendMessageButton, bgImage:sendMessageIcon , tintColor: disabledAccentColor)
        sendMessageButton.isEnabled = false
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonPressed(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            messageTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            messageTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            messageTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            messageTextView.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -10),
            messageTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 150),
            messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            sendMessageButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            sendMessageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 30),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(endEditingOnChatViewScroll), name: NSNotification.Name(chatViewScrolledNotificationName), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DiscussionsMessageBox {
    
    func updateSendButton() {
        let isMessageValid = validateTextView(textView: messageTextView)
        sendMessageButton.tintColor = isMessageValid ? accentColor : disabledAccentColor
        sendMessageButton.isEnabled = isMessageValid
    }
    
    @objc func endEditingOnChatViewScroll(_ notification: NSNotification) {
        messageTextView.endEditing(false)
    }
    
    @objc func sendMessageButtonPressed(_ sender: UIButton) {
        
        let googleUser = GIDSignIn.sharedInstance()?.currentUser
        
        if googleUser == nil {
            Toast.show(message: "Login via gmail to send a message.", type: .Failure)
            GIDSignIn.sharedInstance()?.signIn()
            
        } else if validateTextView(textView: messageTextView) {
            
            let defaults = UserDefaults.standard
            let userCountryCode = defaults.string(forKey: userLocationCodeKey) ?? "UNK"
            let userCountryEmoji = defaults.string(forKey: userLocationEmojiKey) ?? flag(from: "UNK")
            let profile = googleUser?.profile
            let userEmail = profile?.email ?? "EmailUnknown"
            let userName = profile?.name ?? "UserNameUnknown"
            let timestamp = NSDate().timeIntervalSince1970
            
            
            var validatedMessage = messageTextView.text!
            validatedMessage = validatedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let message = DiscussionMessage(message: validatedMessage, userCountryCode: userCountryCode, userCountryEmoji: userCountryEmoji, userName: userName, userEmailAddress: userEmail, messageTimestamp: timestamp, fcmToken: nil, question: nil, recordingUrl: nil)
            
            do {
                let messageDictionary = try message.dictionary()
                messagesReference.childByAutoId().setValue(messageDictionary)
            } catch {
                print(error)
            }
            
            messageTextView.text = nil
            messageTextView.endEditing(false)
            messageTextView.isScrollEnabled = false
            messageTextView.setNeedsUpdateConstraints()
        }
        
    }
}

extension DiscussionsMessageBox: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
        if textView.contentSize.height >= 150 {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
            textView.setNeedsUpdateConstraints()
        }
    }
}
