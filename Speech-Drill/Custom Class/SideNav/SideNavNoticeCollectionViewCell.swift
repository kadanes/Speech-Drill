//
//  SideNavNoticeCollectionViewCell.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 19/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class SideNavNoticeCollectionViewCell: UICollectionViewCell {
    let noticeLabel: UILabel
    
    override init(frame: CGRect) {
        logger.info("Initializing side nav notice collection view cell")
        
        noticeLabel = UILabel()
        super.init(frame: frame)
        
        contentView.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noticeLabel.textColor = .white
        noticeLabel.font = getFont(name: .HelveticaNeue, size: .medium)
        noticeLabel.numberOfLines = 0
        noticeLabel.lineBreakMode = .byTruncatingTail
        noticeLabel.textAlignment = .left
        noticeLabel.minimumScaleFactor = 0.5
        noticeLabel.adjustsFontSizeToFitWidth = true
        
        NSLayoutConstraint.activate([
            noticeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            noticeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            noticeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            noticeLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(notice: NoticeStructure) {
        noticeLabel.text = notice.notice + "\n\n" + notice.date
    }
}
