//
//  InfoVC.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {

    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var githubBtn: UIButton!
    
    @IBOutlet weak var gmailBtn: UIButton!
    
    @IBOutlet weak var twitterBtn: RoundButton!
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    @IBOutlet weak var closeInfoBtn: UIButton!
    
    
    let repoURL = URL(string: "https://github.com/parthv21/TOEFL-Speaking")
    
    let reportBugURL = URL(string: "googlegmail:///co?to=parthv21@gmail.com&subject=Bug%20Report%20(Speaking%20App)&body=Hey%20I%20found%20a%20bug!")
    
    let licenseURL = URL(string: "https://fontawesome.com/license")
    
    let ttsURL = URL(string: "http://www.fromtexttospeech.com")
    
    var icons: [UIImage] = [boxIcon,infoIcon,emailIcon,shareIcon,checkIcon,closeIcon,githubIcon,recordIcon,deleteIcon,playBtnIcon,checkMarkIcon,pauseBtnIcon,deleteBtnIcon,singleLeftIcon,doubleLeftIcon,tripleLeftIcon,doubleRightIcon,singleRightIcon,singleShareIcon,tripleRightIcon,plusIcon,minusIcon]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBtnImgProp(button: githubBtn, topPadding: 5, leftPadding: 1)
        setBtnImgProp(button: gmailBtn, topPadding: 5, leftPadding: 1)
        setBtnImgProp(button: closeInfoBtn, topPadding: 5, leftPadding: 1)
        setBtnImgProp(button: twitterBtn, topPadding: 5, leftPadding: 1)
        
        infoContainer.layer.cornerRadius = 5
        infoContainer.layer.masksToBounds = true
        
        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        
       icons = icons.shuffled()
        
    }

    @IBAction func gitHubTapped(_ sender: UIButton) {
        openURL(url: repoURL)
    }
    
    @IBAction func gmailTapped(_ sender: UIButton) {
        openURL(url: reportBugURL)
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        
        let screenName =  "parthv21"
        let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
        
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            application.open(webURL as URL)
        }
    }
    
    @IBAction func showLicenseTapped(_ sender: UIButton) {
        openURL(url: licenseURL)
    }
    
    @IBAction func fromTTSTapped(_ sender: UIButton) {
        openURL(url: ttsURL)
    }
    
    @IBAction func closeInfoTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension InfoVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCell {
            
            cell.configureCell(icon: icons[indexPath.row])
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 40, height: 40)
    }

}
