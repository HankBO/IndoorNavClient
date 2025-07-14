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
        
    }
    
    func getPositioningUpdate(_ fingerprintJsonData: String?) {
        
        let string: String = fingerprintJsonData ?? ""
        
        print("send script to front-end:", string)
        AppLogger.shared.debug("\(string)")

        let script = "window.nativeBridge.getPositioningUpdate(\(string))"
        webView?.evaluateJavaScript(script)
    }
    
}
