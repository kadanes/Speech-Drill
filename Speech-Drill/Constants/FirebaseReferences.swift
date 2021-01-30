//
//  FirebaseReferences.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 12/01/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import Firebase

let ref = Database.database().reference()

let noticesReference = ref.child("notices")
let userLocationReference = ref.child("onlineUserLocations")
let messagesReference = ref.child("discussionMessages")
let sideNavAdsReference = ref.child("sideNavAds")

let usersReference = ref.child("users")
let authenticatedUsersReference = usersReference.child("authenticated")
let unauthenticatedUsersReferences = usersReference.child("unauhtenticated")

let speechDrillDiscussionsFCMTopicName = "SpeechDrillDiscussions"
