//
//  ViewController.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/6/30.
//

import Cocoa
import WebKit

class MainViewController: NSViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupWebView()
        loadWebInterface()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func setupWebView() {
        // Configure WebView with JavaScript bridge
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Create WebView if not connected via storyboard
        if webView == nil {
            webView = WKWebView(frame: view.bounds, configuration: configuration)
            webView.navigationDelegate = self
            webView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(webView)
            
            // Setup constraints programmatically
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
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
}

extension MainViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web interface loaded successfully")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView navigation failed: \(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView provisional navigation failed: \(error)")
    }
    
}
