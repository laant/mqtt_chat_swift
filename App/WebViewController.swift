//
//  WebViewController.swift
//  App
//
//  Created by TS0442 on 2016. 6. 28..
//  Copyright © 2016년 App. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    var webView: WKWebView?
    var reqUrl: NSURL?
    @IBOutlet weak var webViewFrame: UIView!
    @IBOutlet weak var urlInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Create our preferences on how the web page should be loaded */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let controller = WKUserContentController()
        controller.addScriptMessageHandler(self, name: "observe")
        
        /* Create a configuration for our preferences */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = controller
        
        /* Now instantiate the web view */
        var rect = webViewFrame.bounds
        rect.size.width = (self.navigationController?.topViewController!.view.frame.size.width)!
        rect.size.height = (self.navigationController?.topViewController!.view.frame.size.height)! - 20.0 - 44.0
        
        webView = WKWebView(frame: rect, configuration: configuration)
        
        if let theWebView = webView{
            /* Load a web page into our web view */
            let urlRequest = NSURLRequest(URL: reqUrl!)
            theWebView.loadRequest(urlRequest)
            theWebView.navigationDelegate = self
            webViewFrame.addSubview(theWebView)
            
        }
        
        urlInfo.text = reqUrl?.description
        
    }
    
    @IBAction func pressedBtnBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK - WKScriptMessageHandler
    //window.webkit.messageHandlers.observe.postMessage(내용);
    //webView.evaluateJavaScript:exec completionHandler:nil
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        print("Received event \(message.body)")
    }
    
    // MARK - WKNavigationDelegate
    /* Start the network activity indicator when the web view is loading */
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    /* Stop the network activity indicator when the loading finishes */
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        // Cookie
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
        let cookieData = NSKeyedArchiver.archivedDataWithRootObject(cookies!)
        NSUserDefaults.standardUserDefaults().setObject(cookieData, forKey: "Cookies")
        
        let url:NSURL = navigationAction.request.URL!
        
        if url.description.hasPrefix("http") {
            if (navigationAction.targetFrame?.mainFrame)! {
                decisionHandler(.Allow)
            }
            else {
            //if (navigationAction.targetFrame != nil) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        
        decisionHandler(.Cancel)
    }
    
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.mainFrame)! {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
    
    // MARK - WKUIDelegate
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (() -> Void)) {
        print("webView:\(webView) runJavaScriptAlertPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.URL?.host, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler()
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: ((Bool) -> Void)) {
        print("webView:\(webView) runJavaScriptConfirmPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.URL?.host, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler(true)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        print("webView:\(webView) runJavaScriptTextInputPanelWithPrompt:\(prompt) defaultText:\(defaultText) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.URL?.host, message: prompt, preferredStyle: .Alert)
        weak var alertTextField: UITextField!
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
