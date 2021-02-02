//
//  MainVC.swift
//  TOEFL Speaking
//
//  Created by Parth Tamane on 31/07/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit
import AVFoundation
import CallKit
import Mute
import Firebase
import GoogleSignIn

class MainVC: UIViewController {
    
    //    static let mainVC = MainVC()
    //    let sideNavVC = SideNavVC()
    
    @IBOutlet weak var topicsContainer: UIView!
    @IBOutlet weak var thinkTimeLbl: UILabel!
    
    @IBOutlet weak var thinkTimeInfoView: UIView!
    @IBOutlet weak var thinkLbl: UILabel!
    //    @IBOutlet weak var thinkInfoImgView: UIImageView!
    
    @IBOutlet weak var speakTimeLbl: UILabel!
    
    @IBOutlet weak var speakTimeInfoView: UIView!
    @IBOutlet weak var speakLbl: UILabel!
    //    @IBOutlet weak var speakInfoImgView: UIImageView!
    
    //    @IBOutlet weak var thinkTimeChangeStackViewSeperator: UIView!
    
    @IBOutlet weak var thinkTimeChangeStackViewContainer: UIView!
    @IBOutlet weak var thinkTimeChange15: UIButton!
    @IBOutlet weak var thinkTimeChange30: UIButton!
    @IBOutlet weak var thinkTimeChange20: UIButton!
    
    
    //    @IBOutlet weak var displaySideNavBtn: UIButton!
    
    @IBOutlet weak var thinkTimeChangeStackView: UIStackView!
    
    //    @IBOutlet weak var switchModesBtn: RoundButton!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cancelRecordingBtn: UIButton!
    
    @IBOutlet weak var topicTxtView: UITextView!
    
    @IBOutlet weak var topicNumberLbl: UILabel!
    
    @IBOutlet weak var changeTopicBtnsStackView: UIStackView!
    
    @IBOutlet weak var loadNextTopicBtn: RoundButton!
    @IBOutlet weak var loadNextTenthTopicBtn: RoundButton!
    @IBOutlet weak var loadNextFiftiethTopicBtn: RoundButton!
    
    @IBOutlet weak var loadPreviousTopicBtn: RoundButton!
    @IBOutlet weak var loadPreviousTenthTopicBtn: RoundButton!
    @IBOutlet weak var loadPreviousFiftiethTopicBtn: RoundButton!
    
    @IBOutlet weak var recordingTableView: UITableView!
    
    //Export Menu
    @IBOutlet weak var exportMenuView: UIView!
    @IBOutlet weak var exportMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var exportSelectedBtn: UIButton!
    @IBOutlet weak var exportSelectedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playSelectedBtn: UIButton!
    @IBOutlet weak var playSelectedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exportMenuStackView: UIStackView!
    @IBOutlet weak var closeShareMenuBtn: UIButton!
    @IBOutlet weak var exportSeekerView: UIView!
    @IBOutlet weak var exportCurrentPlayTimeLbl: UILabel!
    @IBOutlet weak var exportPlayingSeeker: UISlider!
    @IBOutlet weak var totalPlayTimeLbl: UILabel!
    
    let switchModeButton = UIButton()
    
    //    let interactor = Interactor()
    
    var isTestMode = false
    var reducedTime = false
    
    var defaultThinkTime = 15
    var defaultSpeakTime = 45
    var thinkTime = 15
    var speakTime = 45
    
    var topicNumber = 0
    var topics: [String] = []
    
    var isPlaying = false
    var isRecording = false
    var isThinking = false
    var blinking = true
    var cancelledRecording = false
    var currentRecordingURL: URL?
    
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    
    var recordingUrlsDict: Dictionary<String,Array<URL>> = [:]
    
    var hiddenSections = [String]()
    var visibleSections = [String]()
    
    var recordingUrlsListToExport = [URL]()
    
    let userDefaults = UserDefaults.standard
    
    var thinkTimer: Timer?
    var speakTimer: Timer?
    var blinkTimer: Timer?
    weak var exportPlayBackTimer: Timer?
    
    var audioPlayer: AVAudioPlayer?
    
    let callObserver = CXCallObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingTableView.dataSource = self
        recordingTableView.delegate = self
        recordingTableView.rowHeight = UITableViewAutomaticDimension
        recordingTableView.estimatedRowHeight = recordingCellHeight
        recordingTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        recordingTableView.estimatedSectionHeaderHeight = sectionHeaderHeight
        
        recordingTableView.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: headerCellId)
        
        if isCallKitSupported() {
            callObserver.setDelegate(self, queue: nil)
        }
        
        resetRecordingState()
        
        updateUrlList()
        readTopics()
        topicNumber = userDefaults.integer(forKey: "topicNumber")
        renderTopic(topicNumber: topicNumber)
        
        configureTopicsView()
        
        exportSelectedActivityIndicator.stopAnimating()
        
        setBtnImage()
        setUIButtonsProperty()
        
        setHiddenVisibleSectionList()
        
        addHeader()
        
        //        saveBasicUserInfo()
        //        let email = "parthv.21.email@gmail.com"
        //        print("Stripped Email: ", email.replacingOccurrences(of: ".", with: ""))
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
        //            saveBasicUserInfo()
        ////            print("Google User (Main VC): ", GIDSignIn.sharedInstance()?.currentUser)
        //        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user {
//                print("User is not nil")
                saveBasicUserInfo(deleteUnauth: false)
            } else {
//                print("User is nil")
                saveBasicUserInfo()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = mainGray
        super.viewWillAppear(true)
        toggleExportMenu()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        recordingTableView.reloadData()
    }
}
