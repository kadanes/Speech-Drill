//
//  SideNavVC.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 28/09/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class SideNavVC: UIViewController{
    
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
        
        let closeBtn = UIButton(frame: CGRect(x: MenuHelper.sideNavWidth, y: 0, width: MenuHelper.hiddenSideNavWidth , height: view.bounds.height))
        closeBtn.addTarget(self, action: #selector(closeViewTapped), for: .touchUpInside)
        view.addSubview(closeBtn)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(closeViewWithPan(sender:)))
        view.addGestureRecognizer(panGesture)
        
        view.backgroundColor = MenuHelper.menuBGColor
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for (index,item) in menuItems.enumerated() {
            if item.presentedVC.isKind(of: type(of: calledFromVC!)) {
                let indexPath = IndexPath(item: index + 1, section: 0)
                sideNavTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedIndex = index
                break
            }
        }
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
            sideNavContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -(8 + MenuHelper.hiddenSideNavWidth)),
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
        
        Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: calledFromVC))".lowercased()])
        
        let translation = sender.translation(in: view)
        let progress = MenuHelper.calculateProgress(
            translationInView: translation,
            viewBounds: view.bounds,
            direction: .Left
        )
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func closeViewTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension SideNavVC: UITableViewDelegate,UITableViewDataSource  {
    
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
        guard let calledFromVC = calledFromVC else { return }
        
        if vcToPresent.isKind(of: type(of: calledFromVC))  {
            
            Analytics.logEvent(AnalyticsEvent.HideSideNav.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: calledFromVC))".lowercased()])
            
            dismiss(animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                
                Analytics.logEvent(AnalyticsEvent.ChooseMenuItem.rawValue, parameters: [StringAnalyticsProperties.VCDisplayed.rawValue : "\(type(of: vcToPresent))".lowercased()])
                
                vcToPresent.transitioningDelegate = self
                vcToPresent.modalPresentationStyle = .custom
                self.present(vcToPresent, animated: true, completion: nil)
            }
        }
    }
}

extension SideNavVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInVC()
    }
}
