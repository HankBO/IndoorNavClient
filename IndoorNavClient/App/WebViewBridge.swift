//
//  WebViewBridge.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/11.
//

import WebKit

class WebViewBridge: NSObject, WKScriptMessageHandler {
    weak var webView: WKWebView?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeApp" {
            print("Message from Frontend: \(message.body)")
        }
    }
    
    func getPositioningUpdate(_ fingerprintJsonData: [String: Any]) {
        
        let string: String = dictToJsonString(fingerprintJsonData)!
        
        // print("send script to front-end:", string)
        // AppLogger.shared.debug("\(string)")

        let script = "window.getPositioningUpdate(\(string))"
        webView?.evaluateJavaScript(script)
    }
    
}
