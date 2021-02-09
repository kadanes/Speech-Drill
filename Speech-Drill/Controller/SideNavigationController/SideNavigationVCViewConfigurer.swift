//
//  SideNavigationVCViewConfigurer.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension SideNavigationController {
    
    func configureSideNav() {
        logger.info()
        view.addSubview(sideNavContainer)
        sideNavContainer.translatesAutoresizingMaskIntoConstraints = false
        
        sideNavContainer.addSubview(versionInfoView)
        versionInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        let mainVCMenuItem = sideNavMenuItemStruct(itemName: "Recordings", itemImg: recordIcon, itemImgClr: accentColor, presentedVC: mainVC)
        let infoVCMenuItem = sideNavMenuItemStruct(itemName: "About", itemImg: infoIcon, itemImgClr: accentColor, presentedVC: infoVC)
        let discussionsVCMenuItem = sideNavMenuItemStruct(itemName: "Discussions", itemImg: discussionIcon, itemImgClr: accentColor, presentedVC: DiscussionsVC) //Look into using SF Symbols with UIImage(systemName: T##String)
        
        menuItems.append(mainVCMenuItem)
        menuItems.append(discussionsVCMenuItem)
        menuItems.append(infoVCMenuItem)
        
        sideNavTableView.allowsMultipleSelection = false
        
        sideNavContainer.addSubview(sideNavTableView)
        sideNavTableView.translatesAutoresizingMaskIntoConstraints = false
        sideNavTableView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            sideNavContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            sideNavContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            sideNavContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            sideNavContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            versionInfoView.bottomAnchor.constraint(equalTo: sideNavContainer.bottomAnchor),
            versionInfoView.leadingAnchor.constraint(equalTo: sideNavContainer.leadingAnchor, constant: -8),
            versionInfoView.trailingAnchor.constraint(equalTo: sideNavContainer.trailingAnchor, constant: 16),
            
            sideNavTableView.topAnchor.constraint(equalTo: sideNavContainer.topAnchor),
            sideNavTableView.leadingAnchor.constraint(equalTo: sideNavContainer.leadingAnchor),
            sideNavTableView.trailingAnchor.constraint(equalTo: sideNavContainer.trailingAnchor),
            sideNavTableView.bottomAnchor.constraint(equalTo: versionInfoView.topAnchor)
        ])
        
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(closeViewWithEdgeSwipe(sender:)))
        edgePanGesture.edges = .right
        view.addGestureRecognizer(edgePanGesture)
    }
}
