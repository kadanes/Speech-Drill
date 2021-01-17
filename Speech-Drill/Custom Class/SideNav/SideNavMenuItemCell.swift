//
//  SideNavMenuCellItem.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 17/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class SideNavMenuItemCell: UITableViewCell {
    
    let menuItemIcon: UIImageView
    let menuItemName: UILabel
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        menuItemIcon = UIImageView()
        menuItemName = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.addSubview(menuItemIcon)
        menuItemIcon.translatesAutoresizingMaskIntoConstraints = false
        menuItemIcon.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            menuItemIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            menuItemIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            menuItemIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            menuItemIcon.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        menuItemName.textColor = .white
        menuItemName.textAlignment = .left
        
        contentView.addSubview(menuItemName)
        menuItemName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            menuItemName.leadingAnchor.constraint(equalTo: menuItemIcon.trailingAnchor, constant: 16),
            menuItemName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            menuItemName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            menuItemName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
        
        //                cellView.clipsToBounds = true
        //                cellView.layer.cornerRadius = 10
        //                let selectedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        //                let nonselectedCorners: CACornerMask = []
        //                var isSelected = true
        //                cellView.layer.maskedCorners = isSelected ? selectedCorners : nonselectedCorners
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with menuItem: sideNavMenuItemStruct) {
        menuItemIcon.image = menuItem.itemImg.withRenderingMode(.alwaysTemplate)
        menuItemIcon.tintColor = menuItem.itemImgClr
        menuItemName.text = menuItem.itemName
    }
}
