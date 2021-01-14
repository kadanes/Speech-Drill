//
//  DiscussionChatViewSectionHeader.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 14/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class DiscussionChatViewSectionHeader: UIView {
    let messageSendDate: String
    
    required init(messageSendDate: String) {
        self.messageSendDate = messageSendDate
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
