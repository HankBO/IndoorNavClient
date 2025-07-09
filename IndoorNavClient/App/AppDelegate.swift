//
//  AppDelegate.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/6/30.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: MainWindowController?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        mainWindowController = storyboard.instantiateController(withIdentifier: "MainWindowController") as? MainWindowController
        
        /*
        let wifiPositioningService = WiFiPositioningService()
        Task {
            do {
                try await wifiPositioningService.collectTrainingData(at: Coordinate(x: 0, y: 0, floor: 1))
                
                print("Successfully run GetFingerprint")
            } catch {
                print("Failed to collect fingerprint")
            }
        }
         */
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

