//
//  Util.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/14.
//

import Foundation

func dictToJsonString(_ dict: [String: Any]) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print("Error converting to JSON: \(error)")
        return nil
    }
}

func getCurrentTimeByHHmmssSSS() -> String {
    let timestamp = NSDate().timeIntervalSince1970
    let date = Date(timeIntervalSince1970: timestamp)
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    let formattedTime = formatter.string(from: date)
    // print(formattedTime) // Output: "14:30:25.123"
    return formattedTime
}
