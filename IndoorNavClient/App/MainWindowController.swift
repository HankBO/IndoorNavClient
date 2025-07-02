//
//  MainWindowController.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/2.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.title = "Indoor Navigation App"
        window?.setContentSize(NSSize(width: 1200, height: 800))
        window?.center()
        window?.minSize = NSSize(width: 800, height: 600)
    }
}
