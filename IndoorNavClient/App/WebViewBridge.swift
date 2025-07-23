//
//  WebViewBridge.swift
//  IndoorNavClient
//
//  Created by Hai Bo on 2025/7/11.
//

import WebKit

protocol WebViewBridgeDelegate: AnyObject {
    func webViewBridge(_ bridge: WebViewBridge, didReceiveMessage message: Any)
}

class WebViewBridge: NSObject, WKScriptMessageHandler {
    weak var webView: WKWebView?
    weak var delegate: WebViewBridgeDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeApp" {
            print("Message from Frontend(Time: \(getCurrentTimeByHHmmssSSS()): \(message.body)")
            delegate?.webViewBridge(self, didReceiveMessage: message.body)
        }
    }
    
    func getPositioningUpdate(_ fingerprintJsonData: [String: Any]) {
        
        let string: String = dictToJsonString(fingerprintJsonData)!
        
        // print("send script to front-end:", string)
        // AppLogger.shared.debug("\(string)")

        let script = "window.getPositioningUpdate(\(string))"
        webView?.evaluateJavaScript(script)
    }
    
    func stopPositioningDisplay() {
        print("script is called")
        let script = "window.stopPositioningDisplay()"
        webView?.evaluateJavaScript(script)
    }
    
}
