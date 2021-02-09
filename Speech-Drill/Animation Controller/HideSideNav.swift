//
//  HideSideNav.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 29/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class HideSideNav : NSObject {
    var presentingAddedVC = true
    
    init(vcPresent: Bool) {
        self.presentingAddedVC = vcPresent
    }
    
}

extension HideSideNav: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from)
        else { return }
        
        let initalScale = MenuHelper.initialMenuScale
        
        let containerView = transitionContext.containerView
        
        let snapshot = containerView.viewWithTag(MenuHelper.snapshotNumber)
        containerView.insertSubview(fromVC.view, belowSubview: snapshot!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            snapshot?.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
            snapshot?.layer.opacity = 1
            fromVC.view.transform = CGAffineTransform(scaleX: initalScale, y: initalScale)
            
        }) { _ in
            let didTransitionComplete = !transitionContext.transitionWasCancelled
            if didTransitionComplete {
                snapshot?.removeFromSuperview()
                toVC.view.isHidden = false
            }
            transitionContext.completeTransition(didTransitionComplete)
        }
        
    }
}
