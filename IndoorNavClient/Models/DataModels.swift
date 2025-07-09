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

enum WiFiScannerError: Error {
    case interfaceNotFound
    case scanFailed
    case permissionDenied
}

struct LocationResponse: Codable {
    let timestamp: Date
}

struct CollectDataResponse: Codable {
    let success: Bool
    let message: String
    let id: String?
}

struct PositioningResponse: Codable {
    let success: Bool
    let confidence: Double?
    let message: String?
}

enum APIError: Error {
    case requestFailed
    case uploadFailed
    case invalidResponse
    case collectDataFailed
    case positioningFailed
}
