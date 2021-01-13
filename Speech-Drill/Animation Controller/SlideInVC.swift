//
//  SlideInVC.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 30/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class SlideInVC:NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
       return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        
        if let toVCSnapShot = toVC.view.snapshotView(afterScreenUpdates: true) {
            
            let initalScale = MenuHelper.initialMenuScale
            let containerView  = transitionContext.containerView

            containerView.addSubview(fromVC.view)
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            containerView.insertSubview(toVCSnapShot, aboveSubview: fromVC.view)
            
            toVCSnapShot.center.x += UIScreen.main.bounds.width * (MenuHelper.menuWidth)
            toVCSnapShot.layer.opacity = MenuHelper.snapshotOpacity
            
            toVC.view.isHidden = true
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toVCSnapShot.layer.opacity = 1
                toVCSnapShot.center.x = UIScreen.main.bounds.width/2
                fromVC.view.transform = CGAffineTransform(scaleX: initalScale, y: initalScale)
            }) { (done) in
                if done {
                    toVC.view.isHidden = false
                    toVCSnapShot.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        }
    }
}
