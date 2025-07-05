//
//  WiFiPositioningService.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import Foundation

class WiFiPositioningService {
    private let scanner = WiFiScanner()
    private let apiInterface = APIInterface()
    
    func collectTrainingData(at location: Coordinate) async throws {
        let fingerprint = try await scanner.createFingerprint()
        try await apiInterface.uploadTrainingData(fingerprint, location: location)
    }
}
