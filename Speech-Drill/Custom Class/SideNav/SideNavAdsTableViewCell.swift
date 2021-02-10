//
//  SideNavAdsTableViewCell.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class SideNavAdsTableViewCell: UITableViewCell {
    private let adsTitleLable: UILabel
    private let adsCollectionView: UICollectionView
    private let adsPagingIndicator: UIPageControl
    private var fetchedAds: [SideNavAdStructure] = []
    
    private let sideNavAdCellReuseIdentifier = "SideNavAdCellReuseIdentifier"
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        logger.info("Creating side nav ad cell")
        
        adsTitleLable = UILabel()
        let adsCollectionViewLayout = UICollectionViewFlowLayout()
        adsCollectionViewLayout.scrollDirection = .horizontal
        adsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: adsCollectionViewLayout)
        adsPagingIndicator = UIPageControl()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addTopBorder(with: .darkGray, andWidth: 1)
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(adsTitleLable)
        adsTitleLable.translatesAutoresizingMaskIntoConstraints = false
        adsTitleLable.textColor = .white
        adsTitleLable.font = getFont(name: .HelveticaNeueBold, size: .xlarge)
        adsTitleLable.text = "Other Resources"
        adsTitleLable.minimumScaleFactor = 0.5
        adsTitleLable.adjustsFontSizeToFitWidth = true
        adsTitleLable.textAlignment = .center
        
        contentView.addSubview(adsPagingIndicator)
        adsPagingIndicator.translatesAutoresizingMaskIntoConstraints = false
        adsPagingIndicator.tintColor = .white
        adsPagingIndicator.currentPageIndicatorTintColor = accentColor
        
        
        contentView.addSubview(adsCollectionView)
        adsCollectionView.backgroundColor = .clear
        adsCollectionView.delegate = self
        adsCollectionView.dataSource = self
        adsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        adsCollectionView.showsHorizontalScrollIndicator = false
        adsCollectionView.isPagingEnabled = true
        
        adsCollectionView.register(SideNavAdCell.self, forCellWithReuseIdentifier: sideNavAdCellReuseIdentifier)
        
        adsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            adsTitleLable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            adsTitleLable.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            adsTitleLable.heightAnchor.constraint(equalToConstant: 30),
            
            adsPagingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            adsPagingIndicator.heightAnchor.constraint(equalToConstant: 30),
            adsCollectionView.topAnchor.constraint(equalTo: adsTitleLable.bottomAnchor, constant: 3),
            adsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            adsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            adsCollectionView.bottomAnchor.constraint(equalTo: adsPagingIndicator.topAnchor, constant: -3),
            //            adsCollectionView.heightAnchor.constraint(equalToConstant: 250),
            adsPagingIndicator.centerXAnchor.constraint(equalTo: adsCollectionView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SideNavAdsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        logger.debug("Number of ads \(fetchedAds.count)")
        
        adsPagingIndicator.numberOfPages = fetchedAds.count
        return fetchedAds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideNavAdCellReuseIdentifier, for: indexPath) as? SideNavAdCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(adInformation: fetchedAds[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.size.width - 16, height: 250)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adsPagingIndicator.currentPage = Int(
            (adsCollectionView.contentOffset.x / adsCollectionView.frame.width)
                .rounded(.toNearestOrAwayFromZero)
        )
    }
    
    func fetchAds() {
        logger.info("Fetching ads...")
        
        sideNavAdsReference.observe(.value) { (snapshot) in
            if let value = snapshot.value as? [[String: Any]] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    self.fetchedAds = try JSONDecoder().decode([SideNavAdStructure].self, from: data)
                    self.adsCollectionView.reloadData()
                    logger.debug("Fetched ads: \(self.fetchedAds)")
                } catch {
                    logger.error("Failed to fetch ads: \(error)")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
