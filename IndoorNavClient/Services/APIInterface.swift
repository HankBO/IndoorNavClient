//
//  APIInterface.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/1.
//

import Foundation


class APIInterface {
    private let baseURL = URL(string: "https://your-frontend-domain.com/api/v1")!
    private let session = URLSession.shared
    private let csvFilename = "raw_fingerprints.csv"
    
    func saveTrainingData(_ fingerprint: WiFiFingerprint, roomText: String, sampleSiteText: String) async throws  -> CollectDataResponse {
        
        // field: bssid, siteid, rssi
        
        // 1.read local file
        // insert a record to csv file, with roomText and WifiFingerprint
        // close file
        // genenrate var ifSuccess
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(csvFilename)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let headers = "bssid, room_external_id, site_id, rssi\n"
            try headers.write(to: fileURL, atomically: true, encoding: .utf8)
        }
        
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        defer {
            fileHandle.closeFile()
        }
        
        fileHandle.seekToEndOfFile()
        
        for network in fingerprint.networks {
            let csvLine = "\(network.bssid),\(roomText),\(sampleSiteText),\(network.rssi)\n"
            
            if let data = csvLine.data(using: .utf8) {
                fileHandle.write(data)
            }
        }
        
        
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: "1.0", headerFields: ["test": "test"])
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.collectDataFailed
        }
        let jsonString = """
        {
            "success": true,
            "message": "Room: \(roomText), Site: \(sampleSiteText)",
        }
        """
        let data = jsonString.data(using: .utf8)!
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            return try JSONDecoder().decode(CollectDataResponse.self, from: data)
        } else {
            throw APIError.collectDataFailed
        }
    }
    
    func requestPositioning(_ fingerprint: WiFiFingerprint) async throws -> PositioningResponse {
        let url = baseURL.appendingPathComponent("positioning")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(fingerprint)
        request.httpBody = jsonData
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.positioningFailed
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(PositioningResponse.self, from: data)
        } else {
            throw APIError.positioningFailed
        }
    }
}
