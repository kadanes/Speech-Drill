//
//  EmojiModifier.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 09/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import Willow

struct EmojiModifier: LogModifier {
    
    let name: String
    
    /**
     Brings little fun with emojis in debugging.
     Takes message and puts a emoji depending on the logLevel at the start of the line.
     
     - parameter message: The message to log.
     - parameter logLevel: The severity of the message.
     - returns: The modified log message.
     */
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        let logPrefix = "[\(name)/\(logLevel)]"
        switch logLevel {
        case .method:
            return "💬 \(logPrefix) => \(message)"
        case .debug:
            return "🔬 \(logPrefix) => \(message)"
        case .info:
            return "💡 \(logPrefix) => \(message)"
        case .event:
            return "🔵 \(logPrefix) => \(message)"
        case .warn:
            return "⚠️ \(logPrefix) => \(message)"
        case .error:
            return "💥 \(logPrefix)=> \(message)"
        default:
            return "\(logPrefix) => \(message)"
        }
    }
}
