//
//  DataModels.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import Foundation

struct WiFiFingerprint: Codable {
    let timestamp: Date
    let networks: [WiFiNetwork]
    let deviceInfo: DeviceInfo
}

struct WiFiNetwork: Codable {
    let bssid: String
    let ssid: String?
    let rssi: Int
    let frequency: Int?
}

struct DeviceInfo: Codable {
    let deviceId: String
    let macAddress: String?
    let systemVersion: String
}

struct LocationResponse: Codable {
    let estimatedLocation: Coordinate
    let confidence: Double
    let timestamp: Date
}

struct Coordinate: Codable {
    let x: Double
    let y: Double
    let floor: Int?
}

enum WiFiScannerError: Error {
    case interfaceNotFound
    case scanFailed
    case permissionDenied
}
