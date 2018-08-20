//
//  Utils.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 20/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


func openURL(url: URL?) {
    
    guard let url = url else {return }
    
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}


func setBtnImgProp(button: UIButton, topPadding: CGFloat, leftPadding: CGFloat) {
    button.imageView?.contentMode = .scaleAspectFit
    button.contentEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding, leftPadding)
}


func splitFileURL(url: String) -> (Int,Int,Int) {
    
    let urlComponents = url.components(separatedBy: "/")
    
    let fileName = urlComponents[urlComponents.count - 1]
    
    let fileNameComponents = fileName.components(separatedBy: ".")
    
    var timeStamp: Int = 0
    var topicNumber: Int = 0
    var thinkTime: Int = 0
    
    if fileNameComponents.indices.count > 0 {
        
        let recordingNameComponents = fileNameComponents[0].components(separatedBy: "_")
        
        if let thinkTimeUW = Int(recordingNameComponents[2]) {
            thinkTime = thinkTimeUW
        }
        
        if let topicNumberUW = Int(recordingNameComponents[1]) {
            topicNumber = topicNumberUW
        }
        
        if let timeStampUW = Int(recordingNameComponents[0]) {
            timeStamp = timeStampUW
        }
        
    }
    
    return (timeStamp,topicNumber,thinkTime)
}

