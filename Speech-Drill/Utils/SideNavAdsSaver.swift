//
//  SideNavAdsSaver.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

let goGeniusAd = SideNavAdStructure(bannerUrl: "gogenius.png", tagLine: "Call us for councelling.", contact1: SideNavAdContactDetailsStruct(contactTitle: "Hvovi", contactNumber: "9987042606", contactEmail: nil), contact2: SideNavAdContactDetailsStruct(contactTitle: "Umang", contactNumber: "9167884007", contactEmail: nil), websiteUrl: "https://www.gogenius.co/")

let addAdsAd = SideNavAdStructure(bannerUrl: "study-resources.png", tagLine: "Click to add information about your study resource or contact me.", contact1: SideNavAdContactDetailsStruct(contactTitle: "Email to know more", contactNumber: nil, contactEmail: "parthv21@gmail.com"), contact2: nil, websiteUrl: "https://docs.google.com/forms/d/e/1FAIpQLSdvvrBIeeHW0-Q6WBnu6lEBaUS5ZRnpC0hWWSlWuw71aVdzcQ/viewform")

fileprivate func saveAllAds() {
        let ads = [goGeniusAd, addAdsAd]


        var jsonAds: [[String: Any]] = []
        for ad in ads {
            do {
                try jsonAds.append(ad.dictionary())
            } catch {
                print("Error parsing when storing ad", ad)
            }
        }
        sideNavAdsReference.setValue(jsonAds)
}

