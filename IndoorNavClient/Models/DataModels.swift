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
    let security: String?
}

struct DeviceInfo: Codable {
    let deviceId: String
    let macAddress: String?
    let systemVersion: String
}
