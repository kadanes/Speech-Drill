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
        logger.info("Selected \(indexPath) in SideNavigationController")
        guard let calledFromVCIndex = calledFromVCIndex else { return }
        
        if indexPath.section == 0 || indexPath.section == 2 {
            let indexPath = IndexPath(row: calledFromVCIndex, section: 1)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            return
        }
        
        let presentedVC = menuItems[indexPath.row].presentedVC
        self.calledFromVCIndex = indexPath.row
        presentedVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    func updateUnreadMessagesCount() {
            logger.info("Updating count of unread messages")

            let messageTimestampKey = DiscussionMessage.CodingKeys.messageTimestamp.stringValue
            let defaults = UserDefaults.standard
    //        let query = messagesReference.observe(.childAdded) { (snapshot) in
    //            if snapshot.exists() {
    //                let startTimestamp = defaults.double(forKey: lastReadMessageTimestampKey)
    //                let offset: Double = 0.00000001
    //                messagesReference.queryOrdered(byChild: messageTimestampKey).queryStarting(atValue: startTimestamp + offset).observe(.value) { (snapshot) in
    //                    if let value = snapshot.value as? [String: Any] {
    //                        print("Number of unread messages: \(value.count) Last Read TS \(UserDefaults.standard.double(forKey: lastReadMessageTimestampKey))")
    //                    }
    //                }
    //            }
    //        }
            
            unreadMessageCountUpdateQueryHandle = messagesReference.queryOrdered(byChild: messageTimestampKey).queryStarting(atValue: defaults.double(forKey: lastReadMessageTimestampKey) + 0.000001).observe(.value) { (snapshot) in
                if let value = snapshot.value as? [String: Any] {
                    print("Number of unread messages: \(value.count) Last Read TS \(UserDefaults.standard.double(forKey: lastReadMessageTimestampKey))")
                    self.menuItems[1].itemName = "Discussions (\(value.count))"
                    self.sideNavTableView.reloadData()
                } else {
                    self.menuItems[1].itemName = "Discussions"
                    self.sideNavTableView.reloadData()
                }
            }
        }
        
        func stopUpdatingUnreadMessagesCount() {
            guard let handle = unreadMessageCountUpdateQueryHandle else { return }
            messagesReference.removeObserver(withHandle: handle)
        }
}
