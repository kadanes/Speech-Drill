//
//  LogginConfiguration.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 09/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//  Ref: https://medium.com/joshtastic-blog/convenient-logging-in-swift-75e1adf6ba7c

import Foundation

import Willow

var willow_logger: Logger?

struct LoggingConfiguration {
    
    static func configure() {
        
        let name = "Logger"
       
        #if DEBUG
            willow_logger = buildDebugLogger(name: name)
        #else
            willow_logger = buildReleaseLogger(name: name)
        #endif
        
        willow_logger?.enabled = true
    }
    
    /**
     Builds a logger for debug-builds. Prints all log messages to the console.
     Logging will block the main thread.
     
     - parameter name: The name of the logger.
     - returns: The configured logger.
     */
    private static func buildDebugLogger(name: String) -> Logger {
        
        let emojiModifier = EmojiModifier(name: name)
        
        let consoleWriter = ConsoleWriter(modifiers: [emojiModifier, TimestampModifier()])
        
        return Logger(logLevels: [.all], writers: [consoleWriter], executionMethod: .synchronous(lock: NSRecursiveLock()))
    }
    
    /**
     Builds a logger for release-builds. Prints only serve messages.
     Logging will be performed asynchronously to prevent performance problems in production.
     
     - parameter name: The name of the logger.
     - returns: The configured logger.
     */
    private static func buildReleaseLogger(name: String) -> Logger {
        
        let osLogWriter = OSLogWriter(subsystem: "com.parthtamane.SpeechTrainer", category: name)
        
        let appLogLevels: LogLevel = [.event, .info, .warn, .error, .method]
        let asynchronousExecution: Logger.ExecutionMethod = .asynchronous(
            queue: DispatchQueue(label: "com.parthtamane.logging", qos: .utility)
        )
        
        return Logger(logLevels: appLogLevels, writers: [osLogWriter], executionMethod: asynchronousExecution)
    }
}

extension LogLevel {
    static var method = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
}

extension Logger {
    public func methodMessage(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: .method)
    }
    
    public func methodMessage(_ message: @escaping () -> String) {
        logMessage(message, with: .method)
    }
}
