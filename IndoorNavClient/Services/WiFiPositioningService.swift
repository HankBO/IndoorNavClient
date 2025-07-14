//
//  WiFiPositioningService.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import Foundation

extension Notification.Name {
    static let positioningUpdated = Notification.Name("positioningUpdated")
    static let wifiScanCompleted = Notification.Name("wifiScanCompleted")
    static let trainingDataCollected = Notification.Name("trainingDataCollected")
}

class WiFiPositioningService {
    private let scanner = WiFiScanner()
    private let apiInterface = APIInterface()
    private var isTracking = false
    private var trackingTimer: Timer?
    
    func startLocationTracking(interval: TimeInterval = 3.0) {
        isTracking = true
        trackingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                await self.performPositioningRequest()
            }
        }
    }
    
    func stopLocationTracking() {
        isTracking = false
        trackingTimer?.invalidate()
        trackingTimer = nil
    }
    
    private func performPositioningRequest() async {
        do {
            let fingerprint = try await scanner.createFingerprint()

            let response = PositioningResponse(
                success: true,
                fingerprint: fingerprint,
                message: "success"
            )
            
            //try JSONDecoder().decode(PositioningResponse.self, from: data)
            
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .positioningUpdated,
                    object: response,
                )
            }
        } catch {
            print("Positioning request failed: \(error)")
        }
    }
    
    func collectTrainingData(roomText: String, sampleSiteText: String) async throws -> CollectDataResponse {
        let fingerprint = try await scanner.createFingerprint()
        print(fingerprint)
        print(roomText)
        print(sampleSiteText)
        let response = try await apiInterface.saveTrainingData(fingerprint, roomText: roomText, sampleSiteText: sampleSiteText)
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: .trainingDataCollected,
                object: response
            )
        }
        
        return response
    }
    
    private func jsonString(from object: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}
