//
//  MainVCCallHelper.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 01/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import CallKit

//MARK :- Check for call interrupt
extension MainVC: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        logger.info()
        print("Call: ", call)
        
        if call.hasEnded == true {
            print("Disconnected")
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Cancelling recording")
            cancelRecording()
        }
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
        }
    }
}
