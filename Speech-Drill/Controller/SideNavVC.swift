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

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let dummyView = UIView(frame: CGRect(x: 10, y: 200, width: 100, height: 100))
        dummyView.backgroundColor = accentColor
        
        view.addSubview(dummyView)
        
        let closeBtn = UIButton(frame: CGRect(x: 4, y: 30, width: 200, height: 20))
        closeBtn.addTarget(self, action: #selector(closeViewTapped), for: .touchUpInside)
        closeBtn.setTitle("Close", for: .normal)
        
        view.addSubview(closeBtn)
        
        view.backgroundColor = confirmGreen
    }
    
    @objc func closeViewTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
