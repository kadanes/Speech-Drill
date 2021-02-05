//
//  UserCountryUIView.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 11/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit

class UserCountryUIView: UIView{
    
    let viewTitleLabel: UILabel
    let countryCollectionView: UICollectionView
    let countryCellReuseIdentifier: String = "UserCountryCell"
//    var countryUserCount: [String:Int] = ["India": 100000, "Pakistan":300000, "USA": 1000]
    var countryUserCount: [String:Int] = [:]
    var sortedCountryUserCount: [Dictionary<String, Int>.Element] = []
    var showFlag = true
    
    required init(coder aDecoder: NSCoder) {
        //        countryCollectionView = UITableView()
        //          super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.itemSize = UICollectionViewFlowLayoutAutomaticSize
//        layout.estimatedItemSize = CGSize(width: 100, height: 50)
        
        countryCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        viewTitleLabel = UILabel()
        super.init(frame: frame)
        setupTableView()
//        sortedCountryUserCount = self.countryUserCount.sorted(by: <)
        monitorOnlineUsers()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleFlagState))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    
    func setupTableView() {
        
        self.addSubview(viewTitleLabel)
        viewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        viewTitleLabel.textColor = .white
        viewTitleLabel.font = getFont(name: .HelveticaNeueBold, size: .large)
        viewTitleLabel.text = "Online Users"
        
        self.addSubview(countryCollectionView)
        countryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        countryCollectionView.register(UserCountryCell.self, forCellWithReuseIdentifier: countryCellReuseIdentifier)
        countryCollectionView.delegate = self
        countryCollectionView.dataSource = self
        countryCollectionView.showsHorizontalScrollIndicator = false
        countryCollectionView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            viewTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            viewTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            viewTitleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            countryCollectionView.leadingAnchor.constraint(equalTo: viewTitleLabel.trailingAnchor, constant: 10),
            countryCollectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            countryCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            countryCollectionView.heightAnchor.constraint(equalToConstant: 30)
            
        ])
    }
    
    func monitorOnlineUsers() {
         userLocationReference.observe(.value) { (snapshot) in
            
            let onlineUsers = snapshot.value as? [String: String] ?? [:]
//            print("Online Users: ", onlineUsers)
            self.countryUserCount.removeAll()
            for countryCode in onlineUsers.values {
                self.countryUserCount[countryCode, default: 0] += 1
            }
            self.sortedCountryUserCount = self.countryUserCount.sorted(by: <)
            self.countryCollectionView.reloadData()
         }
     }
    
    @objc func toggleFlagState() {
        showFlag = !showFlag
        countryCollectionView.reloadData()
    }
}

extension UserCountryUIView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 30)
//        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countryUserCount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let countryCell = collectionView.dequeueReusableCell(withReuseIdentifier: countryCellReuseIdentifier, for: indexPath) as? UserCountryCell else {
            return UICollectionViewCell()
        }
        
        let countryName = sortedCountryUserCount[indexPath.row].key
        let countryUserCount = sortedCountryUserCount[indexPath.row].value
        
        if showFlag {
            countryCell.configureCell(countryName: flag(from: countryName), countryUserCount: countryUserCount)
        } else {
            countryCell.configureCell(countryName: countryName, countryUserCount: countryUserCount)
        }
        
        
        return countryCell
    }
}
