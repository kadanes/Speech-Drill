//
//  FirebaseDatabaseReferences.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 12/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import Firebase

let ref = Database.database().reference()

let userLocationReference = ref.child("onlineUserLocations")
