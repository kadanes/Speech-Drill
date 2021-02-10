//
//  LoggingProxy.swift
//  Speech-Drill
//
//  Created by Parth Tamane on 09/02/21.
//  Copyright © 2021 Parth Tamane. All rights reserved.
//

import Foundation
import Willow

var logger = LoggingProxy(logger: willow_logger)

// swiftformat:disable redundantSelf
struct LoggingProxy {

    var proxLogger: Logger?

    init(logger: Logger?) {
        self.proxLogger = logger
    }

    
    public func method(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        proxLogger?.methodMessage(self.format(message: message, file: file, function: function, line: line))
        
    }
    
    public func debug(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {

        proxLogger?.debugMessage(self.format(message: message, file: file, function: function, line: line))
    }

    public func info(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        proxLogger?.infoMessage(self.format(message: message, file: file, function: function, line: line))
    }

    public func event(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {

        proxLogger?.eventMessage(self.format(message: message, file: file, function: function, line: line))
    }

    public func warn(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {

        proxLogger?.warnMessage(self.format(message: message, file: file, function: function, line: line))
    }

    public func error(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {

        proxLogger?.errorMessage(self.format(message: message, file: file, function: function, line: line))
    }

    private func format(message: String, file: String, function: String, line: Int) -> String {

        #if DEBUG /* I use os_log in production where line numbers and functions are discouraged */
            return "[\(sourceFileName(filePath: file)) / \(function):\(line)] \(message)"
        #else
            return message
        #endif
    }

    private func sourceFileName(filePath: String) -> String {

        let components = filePath.components(separatedBy: "/")
        return (components.isEmpty ? "" : components.last) ?? ""
    }
}
