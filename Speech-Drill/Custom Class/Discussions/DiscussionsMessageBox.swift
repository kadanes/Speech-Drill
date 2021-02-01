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
import Firebase

    class DiscussionsMessageBox: UIView {
        
        let messageTextView: UITextView
        let sendMessageButton: UIButton
        var maxMessageBoxHeight: CGFloat = 60
        var minMessageBoxHeight: CGFloat = 10
        let maxRowsInMessageBox: CGFloat = 5
        let messageBoxPadding: CGFloat = 5
        var cursorHeight: CGFloat = 0
        
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
            let messageTextViewFont = getFont(name: .HelveticaNeue, size: .medium)
            messageTextView.font = messageTextViewFont
            
    //        let sizeEstimateLetter = "A"
    //        let sizeEstimate = sizeEstimateLetter.size(withAttributes: [NSAttributedStringKey.font: messageTextViewFont])
    //        maxMessageBoxHeight = maxRowsInMessageBox * sizeEstimate.height + 2 * messageBoxPadding
    //        minMessageBoxHeight = sizeEstimate.height + 2 * messageBoxPadding
    //        print("Letter Height: ", sizeEstimate.height)

            
            cursorHeight = messageTextView.caretRect(for: messageTextView.beginningOfDocument).height
            maxMessageBoxHeight = maxRowsInMessageBox * cursorHeight + 2 * messageBoxPadding
            minMessageBoxHeight = cursorHeight + 2 * messageBoxPadding
            
            messageTextView.clipsToBounds = true
            messageTextView.layer.cornerRadius = 5
            messageTextView.layer.borderColor = accentColor.cgColor
            messageTextView.layer.borderWidth = 1
            messageTextView.layer.backgroundColor = UIColor.black.cgColor
            messageTextView.isScrollEnabled = false
            messageTextView.contentInset.left = messageBoxPadding
            messageTextView.contentInset.right = -1 * messageBoxPadding
            messageTextView.contentInset.top = messageBoxPadding
            messageTextView.contentInset.bottom = messageBoxPadding
            
            
              
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
                messageTextView.heightAnchor.constraint(lessThanOrEqualToConstant: maxMessageBoxHeight),
    //            messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: minMessageBoxHeight),

                sendMessageButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
                sendMessageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                sendMessageButton.heightAnchor.constraint(equalToConstant: 30),
                sendMessageButton.widthAnchor.constraint(equalToConstant: 30)
            ])
                    
            NotificationCenter.default.addObserver(self, selector: #selector(endEditingOnChatViewScroll), name: NSNotification.Name(chatViewTappedNotificationName), object: nil)
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
            
//            let googleUser = GIDSignIn.sharedInstance()?.currentUser
            let currentUser = Auth.auth().currentUser
            
            if currentUser == nil {
                let notSignedInAlert = UIAlertController(title: "Please Login", message: "You will have to login with your gmail account before you can send a message. Tap the user icon on the top right corner of the screen to be logged in.", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Okay", style: .cancel) { _ in }
                notSignedInAlert.addAction(dismissAction)
                UIApplication.shared.windows.last?.rootViewController?.present(notSignedInAlert, animated: true)
                
            } else if validateTextView(textView: messageTextView), let currentUser = currentUser {
                
                let providerId = currentUser.providerData[0].providerID
                let defaults = UserDefaults.standard
                let userCountryCode = defaults.string(forKey: userLocationCodeKey) ?? "UNK"
                let userCountryEmoji = defaults.string(forKey: userLocationEmojiKey) ?? flag(from: "UNK")
                let userEmail = currentUser.email ?? "Email_Unknown"
                let userName = currentUser.displayName ?? "User_Name_Unknown"
                let timestamp = NSDate().timeIntervalSince1970
                let userProfileUrl = currentUser.photoURL?.absoluteString
                let fcmToken = defaults.string(forKey: fcmTokenKey)

                let newMessageReference = messagesReference.childByAutoId()
                let messageId = newMessageReference.key
                
                var validatedMessage = messageTextView.text!
                validatedMessage = validatedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let message = DiscussionMessage(message: validatedMessage, userCountryCode: userCountryCode, userCountryEmoji: userCountryEmoji, userName: userName, userEmailAddress: userEmail, messageTimestamp: timestamp, fcmToken: fcmToken, question: nil, recordingURL: nil, profilePictureURL: userProfileUrl, messageID: messageId, providerID: providerId)
                
                do {
                    let messageDictionary = try message.dictionary()
                    newMessageReference.setValue(messageDictionary) { (error, reference) in
                        if let error = error {
                            print("Failed to save message \(messageDictionary) in database: \(error)")
                        }
                    }
                    reregisterForTopicFCM()
                } catch {
                    print(error)
                }
                
                messageTextView.text = nil
                messageTextView.endEditing(false)
//                messageTextView.isScrollEnabled = false
//                messageTextView.setNeedsUpdateConstraints()
                updateSendButton()
            }
            
        }
        
        func reregisterForTopicFCM() {
            Messaging.messaging().unsubscribe(fromTopic: speechDrillDiscussionsFCMTopicName)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                Messaging.messaging().subscribe(toTopic: speechDrillDiscussionsFCMTopicName)
            }
        }
    }

    extension DiscussionsMessageBox: UITextViewDelegate {
        
//        override var intrinsicContentSize: CGSize {
//            let textSize = self.messageTextView.sizeThatFits(CGSize(width: self.messageTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
//
//            if(textSize.height >= maxMessageBoxHeight) {
//                return CGSize(width: self.bounds.width, height: .infinity)
//            } else {
//                return CGSize(width: self.bounds.width, height: textSize.height + 2 * messageBoxPadding)
//            }
//        }
//
        func textViewDidChange(_ textView: UITextView) {
            updateSendButton()
            self.invalidateIntrinsicContentSize()
            
            if abs(textView.contentSize.height - maxMessageBoxHeight) < cursorHeight || textView.contentSize.height > maxMessageBoxHeight {
                textView.isScrollEnabled = true
            } else {
                textView.isScrollEnabled = false
                textView.setNeedsUpdateConstraints()
            }
            
                
//                if (textView.contentSize.height >= maxMessageBoxHeight) {
//                    textView.isScrollEnabled = true
//                } else {
//                    textView.isScrollEnabled = false
//                    textView.setNeedsUpdateConstraints()
//                }
        }
    }
