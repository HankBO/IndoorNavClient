//
//  AppLogger.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/14.
//

import os

class AppLogger {
    static let shared = AppLogger()
    
    private let logger = Logger(subsystem: "com.yourapp.identifier", category: "main")
    
    private init() {} // Prevent external instantiation
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
    
    func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    func error(_ message: String) {
        logger.error("\(message)")
    }
    
    func fault(_ message: String) {
        logger.fault("\(message)")
    }
    
    func notice(_ message: String) {
        logger.notice("\(message)")
    }
}
