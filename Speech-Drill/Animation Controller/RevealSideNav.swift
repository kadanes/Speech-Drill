//
//  RevealSideNav.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 28/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class RevealSideNav: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
        let fromVC = transitionContext.viewController(forKey: .from),
        let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        
        let containerView = transitionContext.containerView
    
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { return }
        snapshot.isUserInteractionEnabled = false
        snapshot.tag = MenuHelper.snapshotNumber
        snapshot.layer.shadowOpacity = MenuHelper.snapshotOpacity
        
        containerView.insertSubview(snapshot, aboveSubview: toVC.view)
        fromVC.view.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            snapshot.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
            snapshot.layer.opacity = MenuHelper.snapshotOpacity
        }, completion: { _ in
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        )
    }
}
