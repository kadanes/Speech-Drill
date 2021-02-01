//
//  SideNavigationVCTableView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

extension SideNavigationController: UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return menuItems.count}
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return sideNavNoticesTableViewCell
        }
        
        if indexPath.section == 2 {
            return sideNavAdsTableViewCell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sideNavMenuItemReuseIdentifier) as? SideNavMenuItemCell else { return UITableViewCell() }
        cell.configureCell(with: menuItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 190
        } else if indexPath.section == 2 {
            return 300
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let calledFromVCIndex = calledFromVCIndex else { return }
        
        if indexPath.section == 0 || indexPath.section == 2 {
            let indexPath = IndexPath(row: calledFromVCIndex, section: 1)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            return
        }
        
        let presentedVC = menuItems[indexPath.row].presentedVC
        self.calledFromVCIndex = indexPath.row
        presentedVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
}
