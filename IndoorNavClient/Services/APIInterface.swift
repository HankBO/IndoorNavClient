//
//  APIInterface.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import Foundation

class APIInterface {
    
    func sendFingerprint(_ fingerprint: WiFiFingerprint) async throws -> LocationResponse {
        
        return LocationResponse(
            estimatedLocation: Coordinate(x: 50.0, y: 50.0, floor: 1),
            confidence: 0.8,
            timestamp: Date()
        )
    }
    
    func uploadTrainingData(_ fingerprint: WiFiFingerprint, location: Coordinate) async throws {
        print(fingerprint)
    }
}
