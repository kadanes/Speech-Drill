//
//  DiscussionsVCKeyboardHandler.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Keyboard handler
extension DiscussionsViewController {
    
    func handleKeyboardWillChangeFrame(keyboardEvent: KeyboardEvent) {
        logger.info()
        let uiScreenHeight = UIScreen.main.bounds.size.height
        let endFrame = keyboardEvent.keyboardFrameEnd
        let endFrameY = endFrame.origin.y
        
        if oldKeyboardEndFrameY == endFrameY {
            return
        }
        oldKeyboardEndFrameY = endFrameY
        
        let offset = -1 * endFrame.size.height
        
        //         print("Handling keyboard change frame:  End Y - ", endFrameY)
        
        if endFrameY >= uiScreenHeight {
            self.discussionsMessageBoxBottomAnchor.constant = 0.0
            self.discussionChatView.discussionTableView.contentOffset.y += 2 * offset
        } else {
            self.discussionsMessageBoxBottomAnchor.constant = offset
            self.discussionChatView.discussionTableView.contentOffset.y -= offset
        }
        
        UIView.animate(
            withDuration: keyboardEvent.duration,
            delay: TimeInterval(0),
            options: keyboardEvent.options,
            animations: {
                self.view.layoutIfNeeded()
                
            },
            completion: nil)
    }
    
}
