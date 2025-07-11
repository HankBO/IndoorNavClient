//
//  ViewController.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/6/30.
//

import Cocoa
import WebKit

class MainViewController: NSViewController {

    var webView: WKWebView!
    var statusLabel: NSTextField!
    var startButton: NSButton!
    var stopButton: NSButton!
    
    var RoomInputField: NSTextField!
    var SampleSiteInputField: NSTextField!
    var saveLocationButton: NSButton!
    var trainingContainerView: NSView!
    
    // Services
    private let locationService = WiFiPositioningService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupWebView()
        setupNotificationService()
        setupInitialUI()
        loadWebInterface()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        
        // Create WebView if not connected via storyboard
        if webView == nil {
            webView = WKWebView(frame: view.bounds, configuration: configuration)
            webView.navigationDelegate = self
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.setValue(false, forKey: "drawsBackground")
            
            webView.isHidden = false
            
            view.addSubview(webView)
            
            // Setup constraints programmatically
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
    
    private func setupNotificationService() {
            NotificationCenter.default.addObserver(
                forName: .locationUpdated,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                if let location = notification.object as? LocationResponse {
                    self?.handleLocationUpdate(location)
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: .trainingDataCollected,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                if let response = notification.object as? CollectDataResponse {
                    self?.handleTrainingDataResponse(response)
                }
            }
        }
    
    private func setupInitialUI() {
        
        stopButton?.isEnabled = false
        statusLabel?.stringValue = "Ready to start location tracking"
        
        // If UI elements are not connected via storyboard, create them programmatically
        if statusLabel == nil {
            print("start to initialize UI elements")
            createUIElementsProgrammatically()
        }
    }
    
    private func createUIElementsProgrammatically() {
        // Create status label
        statusLabel = NSTextField(labelWithString: "Ready to start location tracking")
        statusLabel.textColor = NSColor.black
        statusLabel.alphaValue = 1.0
        statusLabel.backgroundColor = NSColor.lightGray
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Create buttons
        startButton = NSButton(title: "Start Tracking", target: self, action: #selector(startLocationTracking(_:)))
        startButton.alphaValue = 1.0
        startButton.isBordered = false
        startButton.wantsLayer = true
        startButton.layer?.backgroundColor = NSColor.systemGray.cgColor
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        
        stopButton = NSButton(title: "Stop Tracking", target: self, action: #selector(stopLocationTracking(_:)))
        stopButton.alphaValue = 1.0
        stopButton.isBordered = false
        stopButton.wantsLayer = true
        stopButton.layer?.backgroundColor = NSColor.systemGray.cgColor
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.isEnabled = false
        view.addSubview(stopButton)
        
        // Create training input container
        trainingContainerView = NSView()
        trainingContainerView.translatesAutoresizingMaskIntoConstraints = false
        trainingContainerView.isHidden = false
        view.addSubview(trainingContainerView)
        
        // Create training input fields
        let roomLabel = NSTextField(labelWithString: "Room:")
        roomLabel.textColor = NSColor.black
        roomLabel.alphaValue = 1.0
        roomLabel.backgroundColor = NSColor.lightGray
        roomLabel.translatesAutoresizingMaskIntoConstraints = false
        trainingContainerView.addSubview(roomLabel)
        
        RoomInputField = NSTextField()
        RoomInputField.alphaValue = 1.0
        RoomInputField.backgroundColor = NSColor.lightGray
        RoomInputField.translatesAutoresizingMaskIntoConstraints = false
        RoomInputField.placeholderString = "Enter Room Name"
        trainingContainerView.addSubview(RoomInputField)
        
        let sampleSiteLabel = NSTextField(labelWithString: "Sample Site:")
        sampleSiteLabel.textColor = NSColor.black
        sampleSiteLabel.alphaValue = 1.0
        sampleSiteLabel.backgroundColor = NSColor.lightGray
        sampleSiteLabel.translatesAutoresizingMaskIntoConstraints = false
        trainingContainerView.addSubview(sampleSiteLabel)
        
        SampleSiteInputField = NSTextField()
        SampleSiteInputField.alphaValue = 1.0
        SampleSiteInputField.backgroundColor = NSColor.lightGray
        SampleSiteInputField.translatesAutoresizingMaskIntoConstraints = false
        SampleSiteInputField.placeholderString = "Enter Sample Site"
        trainingContainerView.addSubview(SampleSiteInputField)
        
        saveLocationButton = NSButton(title: "Save Location", target: self, action: #selector(saveTrainingLocation(_:)))
        saveLocationButton.alphaValue = 1.0
        saveLocationButton.isBordered = false
        saveLocationButton.wantsLayer = true
        saveLocationButton.layer?.backgroundColor = NSColor.systemGray.cgColor
        saveLocationButton.translatesAutoresizingMaskIntoConstraints = false
        trainingContainerView.addSubview(saveLocationButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            startButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            
            stopButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            stopButton.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 10),
            stopButton.widthAnchor.constraint(equalToConstant: 120),
            
            // Training container constraints
            trainingContainerView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 5),
            trainingContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trainingContainerView.widthAnchor.constraint(equalToConstant: 260),
            trainingContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Training input controls
            roomLabel.leadingAnchor.constraint(equalTo: trainingContainerView.leadingAnchor),
            roomLabel.centerYAnchor.constraint(equalTo: trainingContainerView.centerYAnchor),
            roomLabel.widthAnchor.constraint(equalToConstant: 40),
            
            RoomInputField.leadingAnchor.constraint(equalTo: roomLabel.trailingAnchor, constant: 40),
            RoomInputField.centerYAnchor.constraint(equalTo: trainingContainerView.centerYAnchor),
            RoomInputField.widthAnchor.constraint(equalToConstant: 100),
            
            sampleSiteLabel.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 30),
            sampleSiteLabel.widthAnchor.constraint(equalToConstant: 40),
            
            SampleSiteInputField.leadingAnchor.constraint(equalTo: sampleSiteLabel.trailingAnchor, constant: 80),
            SampleSiteInputField.widthAnchor.constraint(equalToConstant: 100),
            
            saveLocationButton.leadingAnchor.constraint(equalTo: RoomInputField.trailingAnchor, constant: 10),
            saveLocationButton.centerYAnchor.constraint(equalTo: trainingContainerView.centerYAnchor),
            saveLocationButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func loadSimpleGrayPage() {
            let simpleHTML = """
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body { 
                        background-color: #808080; 
                        margin: 0; 
                        padding: 0; 
                        height: 100vh;
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        font-family: system-ui;
                        color: white;
                    }
                </style>
            </head>
            <body>
                <h2>Page could not be loaded</h2>
            </body>
            </html>
            """
            
            webView.loadHTMLString(simpleHTML, baseURL: nil)
    }

    private func loadWebInterface() {
        // load frontend service
             // Fallback to remote URL if local file not found
         let urlString = "http://indoor-nav.uksouth.cloudapp.azure.com/"
         // let urlString = "https://www.google.com/"
         if let url = URL(string: urlString) {
             let request = URLRequest(url: url)
             webView.load(request)
         } else {
             print("Invalid URL: \(urlString)")
         }
    }
    
    private func handleLocationUpdate(_ location: LocationResponse) {
        let locationText = "handleLocationUpdate success!"
        statusLabel.stringValue = locationText
    }
    
    private func handleTrainingDataResponse(_ response: CollectDataResponse) {
        if response.success {
            statusLabel.stringValue = "Training data saved successfully: \(response.message)"
            // Clear input fields
            // RoomInputField.stringValue = ""
        } else {
            statusLabel.stringValue = "Failed to save training data: \(response.message)"
        }
    }
    
    @objc @IBAction func startLocationTracking(_ sender: NSButton) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        statusLabel.stringValue = "Location tracking started..."
    }
    
    @objc @IBAction func stopLocationTracking(_ sender: NSButton) {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        statusLabel.stringValue = "Location tracking stopped"
    }
    
    @objc @IBAction func saveTrainingLocation(_ sender: NSButton) {
        guard let roomText = RoomInputField?.stringValue, roomText.count > 0 else {
            statusLabel.stringValue = "Please enter valid Room Name"
            return
        }
        
        guard let sampleSiteText = SampleSiteInputField?.stringValue, sampleSiteText.count > 0 else {
            statusLabel.stringValue = "Please enter valid Sample Site"
            return
        }
        
        Task {
            do {
                try await locationService.collectTrainingData(roomText: roomText, sampleSiteText: sampleSiteText)
            } catch {
                DispatchQueue.main.async {
                    self.statusLabel.stringValue = "Failed to submit training data: \(error.localizedDescription)"
                }
            }
        }
    }
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        print("Web interface loaded successfully")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        statusLabel.stringValue = "Failed to load map interface: \(error.localizedDescription)"
        loadSimpleGrayPage()
        print("WebView navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        statusLabel.stringValue = "Failed to load map interface: \(error.localizedDescription)"
        loadSimpleGrayPage()
        print("WebView provisional navigation failed: \(error)")
    }
    
}
