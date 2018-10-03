//
//  AnalyticsEvents.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 03/10/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import Foundation

enum AnalyticsEvent: String {
    
    case ShowSideNav = "show_side_nav"
    case HideSideNav = "hide_side_nav"
    case ChooseMenuItem = "choose_menu_item"
    
    case RecordTopic = "record_topic"
    case CancelRecording = "cancel_recording"
    
    case PlayRecordings = "play_recordings"
    case ShareRecordings = "share_recordings"
    case ToggleSection = "toggle_section"
    
    case ToggleSpeakingMode = "toggle_speaking_mode"
    case SetThinkTime = "set_think_time"
    
    case ShowNextTopic = "show_next_topic"
    case ShowPreviousTopic = "show_previous_topic"
    
    case ShowDeleteMenu = "show_delete_menu"
    case ConfirmDelete = "confirm_delete"
    case CancelDelete = "cancel_delete"
    
    case CallCouncillor = "call_councillor"
    case ViewOnAppstore = "view_on_appstore"
    
    case OpenRepo = "open_repo"
    case SendMail = "send_mail"
    case SendTweet = "send_tweet"
    case OpenFontAwesome = "open_font_awesome"
    case OpenTextToSpeech = "open_text_to_speech"
    
}

enum IntegerAnalyticsPropertites: String {
    case ThinkTime = "think_time"
    case NumberOfTopics = "number_of_topics"
    case ShowCurrentVersion = "show_current_version"
}

enum StringAnalyticsProperties: String {
    case ToggleSectionFrom = "toggle_section_from"
    case CouncillorName = "councillor_name"
    case ModeName = "mode_name"
    case RecordingsType = "recordings_type"
    case VCDisplayed = "vc_displayed"
}

enum RecordingsType: String {
    case Single = "single"
    case Selected = "selected"
    case Section = "section"
}

enum ToggleSectionFrom: String {
    case Label = "label"
    case Button = "button"
}
