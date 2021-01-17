//
//  SideNavAdStructure.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 17/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation

struct SideNavAdStructure: Codable {
    let bannerUrl, tagLine: String
    let contact1: SideNavAdContactDetailsStruct?
    let contact2: SideNavAdContactDetailsStruct?
    let websiteUrl: String?
}

struct SideNavAdContactDetailsStruct: Codable {
    let contactTitle: String
    let contactNumber: String?
    let contactEmail: String?
}


