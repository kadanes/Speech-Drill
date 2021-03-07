//
//  SideNavNoticesTableViewCell.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideNavNoticesTableViewCell: UITableViewCell {
    let noticeStackView: UIStackView
    let updatesTextView: UITextView
    let noticesCollectionView: UICollectionView
    let noticesPagingIndicatorContainer: UIView
    let noticesPagingIndicator: UIPageControl
    private var noticeNumber = 0
    
    private var notices: [NoticeStructure] = [NoticeStructure(date:"29/09/18", notice:"No new notice")]
    
    private let sideNavNoticesCellReuseIdentifier = "SideNavNoticesCollectionViewCell"
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        logger.info("Initializing side nav notices table view cell")
        
        noticeStackView = UIStackView()
        updatesTextView = UITextView()
        
        let noticesViewLayout = UICollectionViewFlowLayout()
        noticesViewLayout.scrollDirection = .horizontal
        
        noticesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: noticesViewLayout)
        noticesCollectionView.register(SideNavNoticeCollectionViewCell.self, forCellWithReuseIdentifier: sideNavNoticesCellReuseIdentifier)
        
        noticesPagingIndicator = UIPageControl()
        noticesPagingIndicatorContainer = UIView()
        noticesPagingIndicator.currentPageIndicatorTintColor = accentColor
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        noticesCollectionView.delegate = self
        noticesCollectionView.dataSource = self
        noticesCollectionView.backgroundColor = .clear
        noticesCollectionView.isPagingEnabled = true
        noticesCollectionView.showsHorizontalScrollIndicator = false
        
        backgroundColor = .clear
        
        let noticeLbl = UILabel()
        noticeLbl.text = "Notices"
        noticeLbl.textColor = .white
        noticeLbl.backgroundColor = .clear
        noticeLbl.textAlignment = .center
        noticeLbl.font = getFont(name: .HelveticaNeueBold, size: .xlarge)
        contentView.addSubview(noticeLbl)
        noticeLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeLbl.topAnchor.constraint(equalTo: contentView.topAnchor),
            noticeLbl.heightAnchor.constraint(equalToConstant: 30),
            noticeLbl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        
        contentView.addSubview(noticesPagingIndicator)
        noticesPagingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(noticesCollectionView)
        noticesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticesPagingIndicator.centerXAnchor.constraint(equalTo: noticesCollectionView.centerXAnchor),
            noticesPagingIndicator.topAnchor.constraint(equalTo: noticesCollectionView.bottomAnchor),
            noticesPagingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            noticesCollectionView.topAnchor.constraint(equalTo: noticeLbl.bottomAnchor, constant: 8),
            noticesCollectionView.bottomAnchor.constraint(equalTo: noticesPagingIndicator.bottomAnchor, constant: -8),
            noticesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            noticesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
        ])
        
        contentView.addBottomBorder(with: .darkGray, andWidth: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- Actions

extension SideNavNoticesTableViewCell {
    func fetchNotices() {
        
        //        notesFIRBRef.keepSynced(true)
        noticesReference.observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else { return }
            
            do {
                
                let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                let unsortedNotices = try JSONDecoder().decode([NoticeStructure].self, from: data)
                
                self.notices = unsortedNotices.sorted(by: {(arg0,arg1) in
                    let date1 = arg0.date, date2 = arg1.date
                    guard let dateObj1 = convertToDate(date: date1), let dateObj2 = convertToDate(date: date2) else { return false }
                    return dateObj1 > dateObj2
                })
                
                self.noticesCollectionView.reloadData()
                logger.debug("Fetched notices \(self.notices)")
                
            } catch {
                logger.error("Error fetching notices: \(error)")
            }
        }
    }
}

extension SideNavNoticesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noticesPagingIndicator.numberOfPages = notices.count
        return notices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideNavNoticesCellReuseIdentifier, for: indexPath) as? SideNavNoticeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(notice: notices[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.size.width - 16, height: 130)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        noticesPagingIndicator.currentPage = Int(
            (noticesCollectionView.contentOffset.x / noticesCollectionView.frame.width)
                .rounded(.toNearestOrAwayFromZero)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
