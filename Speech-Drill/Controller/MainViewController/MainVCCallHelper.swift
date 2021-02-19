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
        logger.info("Observing call")
                
        if call.hasEnded == true {
            logger.info("Disconnected")
        }
        if call.isOutgoing == true && call.hasConnected == false {
            logger.info("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            logger.info("Cancelling recording due to call event")
            cancelRecording()
        }
        if call.hasConnected == true && call.hasEnded == false {
            logger.info("Connected")
        }
    }
}
