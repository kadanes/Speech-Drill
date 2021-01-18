//
//  SideNavAdsView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class SideNavAdsView: UIView {
    private var adsCollectionView: UICollectionView
    private let adsPagingIndicator: UIPageControl
    private var fetchedAds: [SideNavAdStructure] = []
    
    private let sideNavAdCellReuseIdentifier = "SideNavAdCellReuseIdentifier"
    
    override init(frame: CGRect) {
        let adsCollectionViewLayout = UICollectionViewFlowLayout()
        adsCollectionViewLayout.scrollDirection = .horizontal
        adsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: adsCollectionViewLayout)
        adsPagingIndicator = UIPageControl()
        super.init(frame: frame)
        
        addTopBorder(with: .darkGray, andWidth: 1)
        
        addSubview(adsPagingIndicator)
        adsPagingIndicator.translatesAutoresizingMaskIntoConstraints = false
        adsPagingIndicator.tintColor = .white
        adsPagingIndicator.currentPageIndicatorTintColor = accentColor
        
        
        addSubview(adsCollectionView)
        adsCollectionView.backgroundColor = .clear
        adsCollectionView.delegate = self
        adsCollectionView.dataSource = self
        adsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        adsCollectionView.showsHorizontalScrollIndicator = false
        adsCollectionView.isPagingEnabled = true

        adsCollectionView.register(SideNavAdCell.self, forCellWithReuseIdentifier: sideNavAdCellReuseIdentifier)
        
        adsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adsPagingIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            adsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            adsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            adsCollectionView.bottomAnchor.constraint(equalTo: adsPagingIndicator.topAnchor, constant: 0),
            adsCollectionView.heightAnchor.constraint(equalToConstant: 250),
            adsPagingIndicator.centerXAnchor.constraint(equalTo: adsCollectionView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SideNavAdsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        sideNavAdsReference.observe(.value) { (snapshot) in
            if let value = snapshot.value as? [[String: Any]] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                    self.fetchedAds = try JSONDecoder().decode([SideNavAdStructure].self, from: data)
                    self.adsCollectionView.reloadData()
                } catch {
                    print("Error fetching ad data")
                    print(error)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
