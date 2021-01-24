//
//  SideNavigationController.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 24/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SideNavigationController: UIViewController {
    
    private let noticesUrl = "https://github.com/parthv21/Speech-Drill/blob/master/Speech-Drill/Information/info.json"
    
    private let sideNavMenuItemReuseIdentifier = "SideNavMenuItemIdentifier"
    
    static let sideNav = SideNavVC()
    var interactor: Interactor? = nil
    var calledFromVC: UIViewController?
    
    private let sideNavContainer: UIView
    private let sideNavTableView: UITableView
    private let sideNavNoticesTableViewCell: SideNavNoticesTableViewCell
    private let sideNavAdsTableViewCell: SideNavAdsTableViewCell
    private let versionInfoView: VersionInfoView
    private var menuItems = [sideNavMenuItemStruct]()
    
    var selectedIndex = 1
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        sideNavContainer = UIView()
        sideNavTableView = UITableView()
        sideNavNoticesTableViewCell = SideNavNoticesTableViewCell()
        sideNavAdsTableViewCell = SideNavAdsTableViewCell()
        versionInfoView = VersionInfoView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideNavTableView.delegate = self
        sideNavTableView.dataSource = self
        sideNavTableView.register(SideNavMenuItemCell.self, forCellReuseIdentifier: sideNavMenuItemReuseIdentifier)
        sideNavTableView.separatorStyle = .none
        
        sideNavNoticesTableViewCell.fetchNotices()
        sideNavAdsTableViewCell.fetchAds()
        
        configureSideNav()
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(closeViewWithPan(sender:)))
//        view.addGestureRecognizer(panGesture)
        
        view.backgroundColor = MenuHelper.menuBGColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        guard let calledFromVC = calledFromVC else { return }
        for (index,item) in menuItems.enumerated() {
            if item.presentedVC.isKind(of: type(of: calledFromVC)) {
                let indexPath = IndexPath(item: index + 1, section: 0)
                sideNavTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedIndex = index
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func configureSideNav() {
        
        
        view.addSubview(sideNavContainer)
        sideNavContainer.translatesAutoresizingMaskIntoConstraints = false
        
        sideNavContainer.addSubview(versionInfoView)
        versionInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        //Storyboard Based VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
        //Fully programatic VC - There is a reference to this in the VC too which I think will cause memory leaks
        let DiscussionsVC = DiscussionsViewController()
        
        //        calledFromVC = mainVC
        
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
            
            sideNavContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            sideNavContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            
            sideNavContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            versionInfoView.bottomAnchor.constraint(equalTo: sideNavContainer.bottomAnchor),
            versionInfoView.leadingAnchor.constraint(equalTo: sideNavContainer.leadingAnchor, constant: -8),
            versionInfoView.trailingAnchor.constraint(equalTo: sideNavContainer.trailingAnchor, constant: 8),
            
            sideNavTableView.topAnchor.constraint(equalTo: sideNavContainer.topAnchor),
            sideNavTableView.leadingAnchor.constraint(equalTo: sideNavContainer.leadingAnchor),
            sideNavTableView.trailingAnchor.constraint(equalTo: sideNavContainer.trailingAnchor),
            sideNavTableView.bottomAnchor.constraint(equalTo: versionInfoView.topAnchor)
        ])
    }
    
    @objc func closeViewWithPan(sender: UIPanGestureRecognizer) {
        
        guard let calledFromVC = calledFromVC else { return }
        
        print("Presenting VC: ", navigationController?.presentingViewController)
        
        if navigationController?.presentingViewController == nil {
            navigationController?.pushViewController(calledFromVC, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: calledFromVC))".lowercased()])
        
    }
}

extension SideNavigationController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return sideNavNoticesTableViewCell
        }
        
        if indexPath.row == menuItems.count + 1 {
            return sideNavAdsTableViewCell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sideNavMenuItemReuseIdentifier) as? SideNavMenuItemCell else { return UITableViewCell() }
        cell.configureCell(with: menuItems[indexPath.row - 1])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 190
        } else if indexPath.row == menuItems.count + 1 {
            return 300
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 || indexPath.row == menuItems.count + 1 { return }
        
        let vcToPresent = menuItems[indexPath.row - 1].presentedVC
        
        calledFromVC = vcToPresent
        vcToPresent.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vcToPresent, animated: true)
        
    }
}
