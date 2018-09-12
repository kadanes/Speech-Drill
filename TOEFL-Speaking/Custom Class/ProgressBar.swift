//
//  ProgressBar.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 12/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class ProgressBar: NSObject  {
    
    static let bar = ProgressBar()
    
    private var progressBar = UIView()
    
    private var c4: NSLayoutConstraint?
    
    private override init() {
        
        super.init()
        
        DispatchQueue.main.async {
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                    
                }
                
                self.progressBar = UIView(frame: CGRect())
                self.progressBar.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressBar.backgroundColor = accentColor
                self.progressBar.alpha = 1
                
                topController.view.addSubview(self.progressBar)
                
                let c1 = NSLayoutConstraint(item: self.progressBar, attribute: .leading, relatedBy: .equal, toItem: topController.view, attribute: .leading, multiplier: 1, constant: 0)
             
                let c2 = NSLayoutConstraint(item: self.progressBar, attribute: .bottom, relatedBy: .equal, toItem: topController.view, attribute: .bottom, multiplier: 1, constant: 0)
                
                let c3 = NSLayoutConstraint(item: self.progressBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 3)
                
                self.c4 = NSLayoutConstraint(item: self.progressBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
            
                topController.view.addConstraints([c1, c2, c3, self.c4!])
                
            }
        }
    }
    
    func updateWidth(progress: Float) {
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                self.c4?.constant = CGFloat(progress) * topController.view.bounds.width
            }
        }
    }
}
