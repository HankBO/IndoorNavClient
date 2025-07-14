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
