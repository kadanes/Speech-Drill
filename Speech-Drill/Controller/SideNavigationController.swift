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
import GoogleSignIn

class SideNavigationController: UIViewController {
    
    private let noticesUrl = "https://github.com/parthv21/Speech-Drill/blob/master/Speech-Drill/Information/info.json"
    
    private let sideNavMenuItemReuseIdentifier = "SideNavMenuItemIdentifier"
        
    var interactor: Interactor? = nil
    var calledFromVCIndex: Int?
    let indexOfVCToShowOnLoad: Int = 0
    
    private let sideNavContainer: UIView
    private let sideNavTableView: UITableView
    private let sideNavNoticesTableViewCell: SideNavNoticesTableViewCell
    private let sideNavAdsTableViewCell: SideNavAdsTableViewCell
    private let versionInfoView: VersionInfoView
    private var menuItems = [sideNavMenuItemStruct]()
    
    //Storyboard Based VC
    private let mainVC: MainVC
    private let infoVC: InfoVC
    //Fully programatic VC - There is a reference to this in the VC too which I think will cause memory leaks
    private let DiscussionsVC: DiscussionsViewController
    
    var shouldAutoNavigateToChild = true
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        sideNavContainer = UIView()
        sideNavTableView = UITableView()
        sideNavNoticesTableViewCell = SideNavNoticesTableViewCell()
        sideNavAdsTableViewCell = SideNavAdsTableViewCell()
        versionInfoView = VersionInfoView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        infoVC = storyboard.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
        //Fully programatic VC - There is a reference to this in the VC too which I think will cause memory leaks
        DiscussionsVC = DiscussionsViewController()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.delegate = self
        
        sideNavTableView.delegate = self
        sideNavTableView.dataSource = self
        sideNavTableView.register(SideNavMenuItemCell.self, forCellReuseIdentifier: sideNavMenuItemReuseIdentifier)
        sideNavTableView.separatorStyle = .none
        
        sideNavNoticesTableViewCell.fetchNotices()
        sideNavAdsTableViewCell.fetchAds()
        
        configureSideNav()
        
        view.backgroundColor = MenuHelper.menuBGColor
        
        print("Google User (SideNav VC): ", GIDSignIn.sharedInstance()?.currentUser)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        if shouldAutoNavigateToChild {
            if calledFromVCIndex == nil { calledFromVCIndex = indexOfVCToShowOnLoad }
            navigationController?.pushViewController(menuItems[calledFromVCIndex!].presentedVC, animated: false)
            shouldAutoNavigateToChild = false
            
        } else {
            guard let calledFromVCIndex = calledFromVCIndex else { return }
            let indexPath = IndexPath(row: calledFromVCIndex, section: 1)
            sideNavTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
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
    
    @objc func closeViewWithEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        
        guard let calledFromVCIndex = calledFromVCIndex else { return }
                
        let presentedVC = menuItems[calledFromVCIndex].presentedVC
        
        if !(navigationController?.topViewController?.isKind(of: type(of: presentedVC)) ?? true) {
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
        Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: presentedVC))".lowercased()])
        
    }
}

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

////MARK:- Transition Animation
//extension SideNavigationController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
//    
//    func navigationController(
//            _ navigationController: UINavigationController,
//            animationControllerFor operation: UINavigationControllerOperation,
//            from fromVC: UIViewController,
//            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//            print("From: ", fromVC, " To: ", toVC, " Operation: ", operation)
//
//            revealSideNav.pushStyle = operation == .push
//            return revealSideNav
//        }
//}
