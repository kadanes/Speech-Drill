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
    private let sideNavAdCellReuseIdentifier = "SideNavAdCellReuseIdentifier"
    
    static let sideNav = SideNavVC()
    var interactor: Interactor? = nil
    var calledFromVC: UIViewController?
    
    //    private var sideNavWidth: CGFloat =  MenuHelper.sideNavWidth
    //    private var hiddenSideNavWidth: CGFloat = MenuHelper.hiddenSideNavWidth
    
    private let updatesTextView: UITextView
    private let menuTableView: UITableView
    private var adsCollectionView: UICollectionView
    private let adsPagingIndicator: UIPageControl
    
    private var menuItems = [sideNavMenuItemStruct]()
    
    private var notices: Array<Dictionary<String,String>> = [[:]]
    private var noticeNumber = 0
    
    private let appstoreLink = "itms-apps://itunes.apple.com/app/id1433796147"
    private var phoneNumbers:[String:String] = ["Hvovi":"9987042606","Umang":"9167884007"]
    
    let goGeniusAd = SideNavAdStructure(bannerUrl: "gogenius.png", tagLine: "Call us for councelling.", contact1: SideNavAdContactDetailsStruct(contactTitle: "Hvovi", contactNumber: "9987042606", contactEmail: nil), contact2: SideNavAdContactDetailsStruct(contactTitle: "Umang", contactNumber: "9167884007", contactEmail: nil), websiteUrl: "https://www.gogenius.co/")
    let adAdsAdd = SideNavAdStructure(bannerUrl: "ads-here.jpeg", tagLine: "Place ads for study resources!", contact1: SideNavAdContactDetailsStruct(contactTitle: "Give a Call", contactNumber: "+917977009722", contactEmail: nil), contact2: SideNavAdContactDetailsStruct(contactTitle: "Send Email", contactNumber: nil, contactEmail: "parthv21@gmail.com"), websiteUrl: nil)
    
    var ads: [SideNavAdStructure] = []
    
    var noticeView: UIView = UIView()
    var versionInfoView: UIView = UIView()
    var adView: UIView = UIView()
    
    var selectedIndex = 0
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        updatesTextView = UITextView()
        menuTableView = UITableView()
        let adsCollectionViewLayout = UICollectionViewFlowLayout()
        adsCollectionViewLayout.scrollDirection = .horizontal
        adsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: adsCollectionViewLayout)
        adsPagingIndicator = UIPageControl()
        
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
        
        populateMenuItems()
        fetchNotices()
        
        addViews()
        
        let closeBtn = UIButton(frame: CGRect(x: MenuHelper.sideNavWidth, y: 0, width: MenuHelper.hiddenSideNavWidth , height: view.bounds.height))
        closeBtn.addTarget(self, action: #selector(closeViewTapped), for: .touchUpInside)
        view.addSubview(closeBtn)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(closeViewWithPan(sender:)))
        view.addGestureRecognizer(panGesture)
        
        view.backgroundColor = MenuHelper.menuBGColor
        
        ads = [goGeniusAd, adAdsAdd]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for (index,item) in menuItems.enumerated() {
            if item.presentedVC.isKind(of: type(of: calledFromVC!)) {
                let indexPath = IndexPath(item: index, section: 0)
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
    
    func addNoticeView() {
        
        noticeView = makeNoticeView()
        view.addSubview(noticeView)
        noticeView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            updatesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8 + MenuHelper.hiddenSideNavWidth)),
            noticeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            noticeView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func addVersionInfoView() {
        
        versionInfoView = makeVersionDetailView()
        view.addSubview(versionInfoView)
        versionInfoView.translatesAutoresizingMaskIntoConstraints = false
        let versionInfoViewTopCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .top, relatedBy: .equal, toItem: updatesTextView, attribute: .bottom, multiplier: 1, constant: 4)
        let versionInfoViewLeadingCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 8)
        let versionInfoViewTrailingCnstrnt = NSLayoutConstraint(item: versionInfoView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -(8 + MenuHelper.hiddenSideNavWidth))
        view.addConstraints([versionInfoViewTopCnstrnt,versionInfoViewLeadingCnstrnt,versionInfoViewTrailingCnstrnt])
    }
    
    
    func addAdView() {
        
        view.addSubview(adsPagingIndicator)
        adsPagingIndicator.translatesAutoresizingMaskIntoConstraints = false
        adsPagingIndicator.tintColor = .white
        adsPagingIndicator.currentPageIndicatorTintColor = accentColor
        
        
        view.addSubview(adsCollectionView)
        adsCollectionView.backgroundColor = .clear
        adsCollectionView.delegate = self
        adsCollectionView.dataSource = self
        adsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
//        adsCollectionView.isPagingEnabled = true
        adsCollectionView.register(SideNavAdCell.self, forCellWithReuseIdentifier: sideNavAdCellReuseIdentifier)
        
        adsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adsPagingIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            adsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            adsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8 + MenuHelper.hiddenSideNavWidth)),
            adsCollectionView.bottomAnchor.constraint(equalTo: adsPagingIndicator.topAnchor, constant: 0),
            adsCollectionView.heightAnchor.constraint(equalToConstant: 250),
            adsPagingIndicator.centerXAnchor.constraint(equalTo: adsCollectionView.centerXAnchor)
        ])
    }
    
    
    func addMenuTableView() {
        menuTableView.allowsMultipleSelection = false
        
        view.addSubview(menuTableView)
        menuTableView.translatesAutoresizingMaskIntoConstraints = false
        menuTableView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            menuTableView.topAnchor.constraint(equalTo: versionInfoView.bottomAnchor, constant: 20),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(8 + MenuHelper.hiddenSideNavWidth)),
            menuTableView.bottomAnchor.constraint(equalTo: adsCollectionView.topAnchor, constant: 0)
        ])
    }
    
    func addViews() {
        
        addNoticeView()
        addVersionInfoView()
        addAdView()
        addMenuTableView()
    }
    
    func makeNoticeView() -> UIView {
        let noticeContainer = UIView()
        
        let noticeStackView = UIStackView()
        noticeStackView.axis = .horizontal
        noticeStackView.spacing = 5
        noticeStackView.alignment = .fill
        noticeStackView.distribution = .fillEqually
        noticeContainer.addSubview(noticeStackView)
        noticeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeStackView.leadingAnchor.constraint(equalTo: noticeContainer.leadingAnchor),
            noticeStackView.trailingAnchor.constraint(equalTo: noticeContainer.trailingAnchor),
            noticeStackView.topAnchor.constraint(equalTo: noticeContainer.topAnchor),
            noticeStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let nextNoticeBtn = UIButton()
        nextNoticeBtn.addTarget(self, action: #selector(showNextNotice), for: .touchUpInside)
        setButtonBgImage(button: nextNoticeBtn, bgImage: singleRightIcon, tintColor: .white)
        setBtnImgProp(button: nextNoticeBtn, topPadding: 5, leftPadding: 5)
        nextNoticeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let prevNoticeBtn = UIButton()
        prevNoticeBtn.addTarget(self, action: #selector(showPrevNotice), for: .touchUpInside)
        setButtonBgImage(button: prevNoticeBtn, bgImage: singleLeftIcon, tintColor: .white)
        setBtnImgProp(button: prevNoticeBtn, topPadding: 5, leftPadding: 5)
        prevNoticeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        noticeStackView.insertArrangedSubview(prevNoticeBtn, at: 0)
        noticeStackView.insertArrangedSubview(nextNoticeBtn, at: 1)
        
        let noticeLbl = UILabel()
        noticeLbl.text = "Notice"
        noticeLbl.textColor = .white
        noticeLbl.backgroundColor = .clear
        noticeLbl.textAlignment = .center
        noticeStackView.insertArrangedSubview(noticeLbl, at: 1)
        noticeLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noticeLbl.topAnchor.constraint(equalTo: noticeStackView.topAnchor),
            noticeLbl.bottomAnchor.constraint(equalTo: noticeStackView.bottomAnchor)
        ])
        
        updatesTextView.isEditable = false
        updatesTextView.textColor = .white
        updatesTextView.backgroundColor = .clear
        updatesTextView.font = UIFont(name: "HelveticaNeue", size: 16)
        showNotice()
        
        updatesTextView.translatesAutoresizingMaskIntoConstraints = false
        noticeContainer.addSubview(updatesTextView)
        
        NSLayoutConstraint.activate([
            updatesTextView.leadingAnchor.constraint(equalTo: noticeContainer.leadingAnchor),
            updatesTextView.trailingAnchor.constraint(equalTo: noticeContainer.trailingAnchor),
            updatesTextView.topAnchor.constraint(equalTo: noticeStackView.bottomAnchor),
            updatesTextView.bottomAnchor.constraint(equalTo: noticeContainer.bottomAnchor)
        ])
        
        
        
        return noticeContainer
        
    }
    
    func makeVersionDetailView() -> UIView {
        
        let versionInfoLblHeight: CGFloat = 40
        let downloadBtnHeight: CGFloat = 40
        let downloadBtnWidth: CGFloat = 180
        
        let versionInfoView = UIView(frame: CGRect())
        
        let versionInfoLbl = UILabel()
        versionInfoView.addSubview(versionInfoLbl)
        versionInfoLbl.textAlignment = .center
        versionInfoLbl.numberOfLines = 0
        versionInfoLbl.textColor = UIColor.white
        versionInfoLbl.minimumScaleFactor = 0.5
        versionInfoLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            versionInfoLbl.topAnchor.constraint(equalTo: versionInfoView.topAnchor),
            versionInfoLbl.leadingAnchor.constraint(equalTo: versionInfoView.leadingAnchor),
            versionInfoLbl.trailingAnchor.constraint(equalTo: versionInfoView.trailingAnchor),
            versionInfoLbl.heightAnchor.constraint(equalToConstant: versionInfoLblHeight)
        ])
        
        
        let appstoreBtn = UIButton(frame: CGRect())
        versionInfoView.addSubview(appstoreBtn)
        appstoreBtn.translatesAutoresizingMaskIntoConstraints = false
        appstoreBtn.addTarget(self, action: #selector(openInAppstore), for: .touchUpInside)
        appstoreBtn.layer.cornerRadius = 10
        appstoreBtn.clipsToBounds = true
        appstoreBtn.backgroundColor = enabledGray.withAlphaComponent(0.1)
        
        NSLayoutConstraint.activate([
            appstoreBtn.widthAnchor.constraint(equalToConstant: downloadBtnWidth),
            appstoreBtn.heightAnchor.constraint(equalToConstant: downloadBtnHeight),
            appstoreBtn.centerXAnchor.constraint(equalTo: versionInfoView.centerXAnchor),
            appstoreBtn.topAnchor.constraint(equalTo: versionInfoLbl.bottomAnchor, constant: 7)
        ])
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = enabledGray
        versionInfoView.addSubview(seperatorView)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.topAnchor.constraint(equalTo: appstoreBtn.bottomAnchor, constant: 10),
            seperatorView.bottomAnchor.constraint(equalTo: versionInfoView.bottomAnchor, constant: 0),
            seperatorView.leadingAnchor.constraint(equalTo: versionInfoView.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: versionInfoView.trailingAnchor)
            
        ])
        
        var currentVersion = ""
        let currentBuildNo = getBuildNumber()
        var latestVersion = ""
        if let installedVersion = getInstalledVersion() {
            currentVersion = installedVersion
        }
        if let appstoreVersion = getAppstoreVersion() {
            latestVersion = appstoreVersion
        }
        
        var versionInfo = "You are running v\(currentVersion)"
        if currentBuildNo != "" {
            versionInfo += " (\(currentBuildNo))"
        }
        if currentVersion == latestVersion {
            appstoreBtn.setTitle("View on Appstore", for: .normal)
        } else {
            appstoreBtn.setTitle("Download (v\(latestVersion))", for: .normal)
        }
        versionInfoLbl.text = versionInfo
        
        return versionInfoView
    }
    
    @objc func showNextNotice() {
        if noticeNumber - 1 >= 0 {
            noticeNumber -= 1
        }
        showNotice()
    }
    
    @objc func showPrevNotice() {
        if noticeNumber + 1 < notices.count {
            noticeNumber += 1
        }
        showNotice()
    }
    
    func showNotice() {
        if noticeNumber >= 0 && noticeNumber < notices.count {
            
            guard let date = notices[noticeNumber]["date"],let notice = notices[noticeNumber]["notice"] else {
                updatesTextView.text = "No notices..."
                return
            }
            
            updatesTextView.text = "\(date)\n\n\(notice)"
            
        } else {
            updatesTextView.text = "No notices..."
        }
        
    }
    
    @objc func openInAppstore() {
        
        var currentVersion = "0"
        var latestVersion = "0"
        var isVersionSame: Int = 1
        
        if let cv = getInstalledVersion(), let lv = getAppstoreVersion() {
            currentVersion = cv
            latestVersion = lv
        }
        if currentVersion != latestVersion { isVersionSame = 0 }
        
        Analytics.logEvent(AnalyticsEvent.ViewOnAppstore.rawValue, parameters: [IntegerAnalyticsPropertites.ShowCurrentVersion.rawValue : isVersionSame as NSObject ])
        let url = URL(string: appstoreLink)
        openURL(url: url)
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
    
    func fetchNotices() {
        
        let notesFIRBRef = Database.database().reference().child("notices")
        notesFIRBRef.keepSynced(true)
        notesFIRBRef.observe(.value) { (snapshot) in
            guard var notices = snapshot.value as? Array<Dictionary<String,String>> else { return }
            
            notices = notices.sorted(by: {(arg0,arg1) in
                guard let date1 = arg0["date"], let date2 = arg1["date"] else { return false}
                guard let dateObj1 = convertToDate(date: date1), let dateObj2 = convertToDate(date: date2) else { return false }
                return dateObj1 > dateObj2
            })
            self.notices = notices
            self.showNotice()
        }
    }
}

extension SideNavVC: UITableViewDelegate,UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sideNavMenuItemReuseIdentifier) as? SideNavMenuItemCell else { return UITableViewCell() }
        cell.configureCell(with: menuItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcToPresent = menuItems[indexPath.row].presentedVC
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

extension SideNavVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        adsPagingIndicator.numberOfPages = ads.count
        return ads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sideNavAdCellReuseIdentifier, for: indexPath) as? SideNavAdCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(adInformation: ads[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: adsCollectionView.frame.size.width, height: 250)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adsPagingIndicator.currentPage = Int(
            (adsCollectionView.contentOffset.x / adsCollectionView.frame.width)
            .rounded(.toNearestOrAwayFromZero)
        )
    }
    
    func snapToNearestCell(scrollView: UIScrollView) {
         let middlePoint = Int(scrollView.contentOffset.x + UIScreen.main.bounds.width / 2)
         if let indexPath = self.adsCollectionView.indexPathForItem(at: CGPoint(x: middlePoint, y: 0)) {
              self.adsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
         }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.snapToNearestCell(scrollView: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.snapToNearestCell(scrollView: scrollView)
    }
    
}
