//
//  SideNavAdsSaver.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 18/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

let goGeniusAd = SideNavAdStructure(bannerUrl: "gogenius.png", tagLine: "Call us for councelling.", contact1: SideNavAdContactDetailsStruct(contactTitle: "Hvovi", contactNumber: "9987042606", contactEmail: nil), contact2: SideNavAdContactDetailsStruct(contactTitle: "Umang", contactNumber: "9167884007", contactEmail: nil), websiteUrl: "https://www.gogenius.co/")

let adAdsAdd = SideNavAdStructure(bannerUrl: "ads-here.jpeg", tagLine: "Place ads for study resources!", contact1: SideNavAdContactDetailsStruct(contactTitle: "Send an email", contactNumber: nil, contactEmail: "parthv21@gmail.com"), contact2: SideNavAdContactDetailsStruct(contactTitle: "Umang", contactNumber: "9167884007", contactEmail: nil), websiteUrl: "https://docs.google.com/forms/d/e/1FAIpQLSdvvrBIeeHW0-Q6WBnu6lEBaUS5ZRnpC0hWWSlWuw71aVdzcQ/viewform")

func saveAllAds() {
        let ads = [goGeniusAd, adAdsAdd]


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

