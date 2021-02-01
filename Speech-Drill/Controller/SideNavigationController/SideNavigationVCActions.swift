//
//  SideNavigationVCActions.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import FirebaseAnalytics

extension SideNavigationController {
    
    @objc func closeViewWithEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        
        guard let calledFromVCIndex = calledFromVCIndex else { return }
                
        let presentedVC = menuItems[calledFromVCIndex].presentedVC
        
        if !(navigationController?.topViewController?.isKind(of: type(of: presentedVC)) ?? true) {
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: presentedVC))".lowercased()])
        
    }

    @objc func viewDiscussions(with userInfo: [AnyHashable : Any] ) {
        print("Recived Notification: ", userInfo)
        let presentedVC = menuItems[1].presentedVC
        
        guard let alreadyPresentedDiscussions = navigationController?.topViewController?.isKind(of: type(of: presentedVC)) else { return }
        
        guard let alreadyPresentingSideNavigationController = navigationController?.topViewController?.isKind(of: type(of: self)) else { return }
        
        if  !alreadyPresentedDiscussions {
            
            if !(alreadyPresentingSideNavigationController) {
                navigationController?.popViewController(animated: false)
            }
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
}
