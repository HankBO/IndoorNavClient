//
//  WiFiScanner.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import CoreWLAN
import Foundation
import CoreLocation

class WiFiScanner {
    private var interface: CWInterface?
    private var locationManager: CLLocationManager
    
    init () {
        self.interface = CWWiFiClient.shared().interface()
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func scanNetworks() async throws -> [WiFiNetwork] {
        // print(self.locationManager.authorizationStatus)
        
        guard let interface = interface else {
            throw WiFiScannerError.interfaceNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let scanResults = try interface.scanForNetworks(withName: nil)
                let networks = scanResults.compactMap { network -> WiFiNetwork? in
                    guard let bssid = network.bssid else { return nil }
                    
                    return WiFiNetwork(
                        bssid: bssid,
                        ssid: network.ssid,
                        rssi: network.rssiValue,
                        frequency: network.wlanChannel?.channelNumber,
                    )
                }
                continuation.resume(returning: networks)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func createFingerprint() async throws -> WiFiFingerprint {
        print("Start scanning networks, timestamp: \(getCurrentTimeByHHmmssSSS())")
        let networks = try await scanNetworks()
        let deviceInfo = DeviceInfo(
            deviceId: getDeviceId(),
            macAddress: interface?.hardwareAddress(),
            systemVersion: ProcessInfo.processInfo.operatingSystemVersionString
        )
        
        return WiFiFingerprint(
            timestamp: Date(),
            networks: networks,
            deviceInfo: deviceInfo
        )
    }
    
    private func getDeviceId() -> String {
        if let deviceId = UserDefaults.standard.string(forKey: "DeviceId") {
            return deviceId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "DeviceId")
            return newId
        }
    }
}
