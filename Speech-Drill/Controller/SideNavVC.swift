//
//  SideNavVC.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 28/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class SideNavVC: UIViewController {
    
    static let sideNav = SideNavVC()

    var interactor: Interactor? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeX = view.bounds.width * MenuHelper.menuWidth
        let closeWidth = view.bounds.width - closeX
        
        let closeBtn = UIButton(frame: CGRect(x: closeX, y: 0, width: closeWidth , height: view.bounds.height))
        closeBtn.addTarget(self, action: #selector(closeViewTapped), for: .touchUpInside)
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.backgroundColor = disabledRed
        view.addSubview(closeBtn)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(closeViewWithPan(sender:)))
        view.addGestureRecognizer(panGesture)
        
        
        view.backgroundColor = UIColor.darkGray
        
    }
    
    @objc func closeViewWithPan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        // 4
        let progress = MenuHelper.calculateProgress(
            translationInView: translation,
            viewBounds: view.bounds,
            direction: .Left
        )
        // 5
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                // 6
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func closeViewTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
