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
//    private let sideNavAdCellReuseIdentifier = "SideNavAdCellReuseIdentifier"
    
    static let sideNav = SideNavVC()
    var interactor: Interactor? = nil
    var calledFromVC: UIViewController?
    
    //    private var sideNavWidth: CGFloat =  MenuHelper.sideNavWidth
    //    private var hiddenSideNavWidth: CGFloat = MenuHelper.hiddenSideNavWidth
    
//    private let updatesTextView: UITextView
    private let sideNavNoticesCell: SideNavNoticesCell
    private let menuTableView: UITableView
    private let sideNavAdsView: SideNavAdsView
    private let versionInfoView: VersionInfoView
    
//    private var adsCollectionView: UICollectionView
//    private let adsPagingIndicator: UIPageControl
    
    private var menuItems = [sideNavMenuItemStruct]()
    
//    private var notices: Array<Dictionary<String,String>> = [[:]]
//    private var noticeNumber = 0
    
//    private let appstoreLink = "itms-apps://itunes.apple.com/app/id1433796147"
    private var phoneNumbers:[String:String] = ["Hvovi":"9987042606","Umang":"9167884007"]
    

//    var fetchedAds: [SideNavAdStructure] = []
    
    var noticeView: UIView = UIView()
    var adView: UIView = UIView()
    
    var selectedIndex = 1
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
//        updatesTextView = UITextView()
        menuTableView = UITableView()
        sideNavNoticesCell = SideNavNoticesCell()
        sideNavAdsView = SideNavAdsView()
        versionInfoView = VersionInfoView()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.register(SideNavMenuItemCell.self, forCellReuseIdentifier: sideNavMenuItemReuseIdentifier)
        menuTableView.separatorStyle = .none
        
        populateMenuItems()
        sideNavNoticesCell.fetchNotices()
        sideNavAdsView.fetchAds()
        
        addViews()
        
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
                menuTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedIndex = index
                break
            }
        }
    }
    
    func populateMenuItems() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
        let DiscussionsVC = DiscussionsViewController()
        
        let mainVCMenuItem = sideNavMenuItemStruct(itemName: "Recordings", itemImg: recordIcon, itemImgClr: accentColor, presentedVC: mainVC)
        let infoVCMenuItem = sideNavMenuItemStruct(itemName: "About", itemImg: infoIcon, itemImgClr: accentColor, presentedVC: infoVC)
        let discussionsVCMenuItem = sideNavMenuItemStruct(itemName: "Discussions", itemImg: discussionIcon, itemImgClr: accentColor, presentedVC: DiscussionsVC) //Look into using SF Symbols with UIImage(systemName: T##String)
        
        menuItems.append(mainVCMenuItem)
        menuItems.append(discussionsVCMenuItem)
        menuItems.append(infoVCMenuItem)
    }
        
    func addVersionInfoView() {
        
        view.addSubview(versionInfoView)
        versionInfoView.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            versionInfoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            versionInfoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            versionInfoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -1 * MenuHelper.hiddenSideNavWidth),
            versionInfoView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    func addAdView() {
        
        view.addSubview(sideNavAdsView)
        sideNavAdsView.fetchAds()
        sideNavAdsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideNavAdsView.bottomAnchor.constraint(equalTo: versionInfoView.topAnchor, constant: 0),
            sideNavAdsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            sideNavAdsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -(0 + MenuHelper.hiddenSideNavWidth)),
            sideNavAdsView.heightAnchor.constraint(equalToConstant: 255)
        ])
    }
    
    
    func addMenuTableView() {
        menuTableView.allowsMultipleSelection = false
        
        view.addSubview(menuTableView)
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8 + MenuHelper.hiddenSideNavWidth)),
            menuTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    func addViews() {
        
        addVersionInfoView()
//        addAdView()
        addMenuTableView()
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
            return sideNavNoticesCell
        }
        
        if indexPath.row == menuItems.count + 1 {
            let cell = UITableViewCell()
            cell.contentView.addSubview(sideNavAdsView)
            sideNavAdsView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sideNavAdsView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                sideNavAdsView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                sideNavAdsView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                sideNavAdsView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
            ])
            cell.backgroundColor = .clear
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sideNavMenuItemReuseIdentifier) as? SideNavMenuItemCell else { return UITableViewCell() }
                cell.configureCell(with: menuItems[indexPath.row - 1])
                return cell
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        } else if indexPath.row == menuItems.count + 1 {
            return 270
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
