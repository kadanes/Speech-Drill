//
//  RevealSideNav.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 28/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class RevealSideNav: NSObject, UIViewControllerAnimatedTransitioning {
    
    var pushStyle: Bool = false
    var previouslyHiddenVC: UIViewController.Type = MainVC.self
    
    var oldSnapshot: UIView = UIView()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }
        
        if pushStyle {
            hideSidenav(using: transitionContext)
            return
        }
        
        let initalScale = MenuHelper.initialMenuScale
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = MenuHelper.menuBGColor
                
        toVC.view.transform = CGAffineTransform(scaleX: initalScale, y: initalScale)
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
//        fromVC.navigationController?.navigationBar.isHidden = false
        fromVC.view.isHidden = true
        
        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { return }
        snapshot.isUserInteractionEnabled = false
        snapshot.tag = MenuHelper.snapshotNumber
        snapshot.layer.shadowOpacity = MenuHelper.snapshotOpacity
        
        containerView.insertSubview(snapshot, aboveSubview: toVC.view)
        fromVC.view.isHidden = true
                
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            snapshot.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidth
            snapshot.layer.opacity = MenuHelper.snapshotOpacity
            toVC.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.oldSnapshot = snapshot
        }
        )
    }
    
    func hideSidenav(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fz = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let tz = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
                
        
        let f = transitionContext.finalFrame(for: tz)
        
        let fOff = f.offsetBy(dx: UIScreen.main.bounds.width * MenuHelper.menuWidth, dy: 0)
        tz.view.frame = fOff
        
        transitionContext.containerView.insertSubview(tz.view, aboveSubview: fz.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                self.oldSnapshot.removeFromSuperview()
                tz.view.frame = f
            }, completion: {_ in
                transitionContext.completeTransition(true)
            })

    }
}
