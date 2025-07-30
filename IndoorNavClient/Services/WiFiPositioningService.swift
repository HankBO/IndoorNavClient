//
//  WiFiPositioningService.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import Foundation

extension Notification.Name {
    static let positioningUpdated = Notification.Name("positioningUpdated")
    static let positioningCancelled = Notification.Name("positioningCancelled")
    static let wifiScanCompleted = Notification.Name("wifiScanCompleted")
    static let trainingDataCollected = Notification.Name("trainingDataCollected")
}

class WiFiPositioningService {
    private let scanner = WiFiScanner()
    private let apiInterface = APIInterface()
    private var isTracking = false
    private var trackingTimer: Timer?
    
    func startLocationTracking(interval: TimeInterval = 2.0) {
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
        
        Task {
            await self.stopPositioningDisplay()
        }
    }
    
    private func performPositioningRequest() async {
        do {
            let fingerprint = try await scanner.createFingerprint()
            print("Scanning network finished, timestamp: \(getCurrentTimeByHHmmssSSS())")
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
    
    private func stopPositioningDisplay() async {
        await MainActor.run {
            NotificationCenter.default.post(
                name: .positioningCancelled,
                object: PositioningCancelledResponse(
                    success: true
                )
            )
        }
    }
    
    func collectTrainingData(roomText: String, sampleSiteText: String) async throws -> CollectDataResponse {
        let fingerprint = try await scanner.createFingerprint()
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
}
