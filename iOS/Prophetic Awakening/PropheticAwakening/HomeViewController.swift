//
//  HomeViewController.swift
//  Sweet Tooth
//
//  Created by Vijay Rathore on 20/03/20.
//  Copyright © 2020 OriginalDevelopment. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import Reachability
import LocalAuthentication
import SwiftGifOrigin

@available(iOS 14.5, *)
class HomeViewController: UIViewController, WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
       
    }
    
    
    
 let delegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressBar: UIProgressView!
    var lastURL : URL?
    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    let websiteLink = "https://www.propheticawakening.co.uk"
    
    let reachability = try? Reachability()
    
    
   override func viewDidLoad() {
        super.viewDidLoad()
    
       let refreshControl = UIRefreshControl()
      refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
     
       webView.scrollView.addSubview(refreshControl)
    //SUBSCRIBE TO TOPIC
    Messaging.messaging().subscribe(toTopic: "propheticawakening"){ error in
                if error == nil{
                    print("Subscribed to topic")
                }
                else{
                    print("Not Subscribed to topic")
                }
            }
    
        webView.uiDelegate  =  self
        webView.navigationDelegate = self
        progressBar.progress = 0.0
               progressBar.tintColor = UIColor.red
               webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
              webView.addSubview(progressBar)
    let wconfiguration  = webView.configuration
    wconfiguration.mediaTypesRequiringUserActionForPlayback = []
    wconfiguration.setValue(true, forKey: "_allowUniversalAccessFromFileURLs")
    
    let urls = URL(string: websiteLink)
    lastURL = urls
    var request = URLRequest(url: urls!)
//    let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "https://followgrown.com/admin-cp")!
   // webView.loadFileURL(url, allowingReadAccessTo: url)
    //var request = URLRequest(url: url)
    request.addValue("*", forHTTPHeaderField: "Access-Control-Allow-Origin")
    webView.load(request)
    
       // connected observer
       reachability?.whenReachable = { reachability in
           var request = URLRequest(url: self.lastURL!)
       //    let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "https://followgrown.com/admin-cp")!
          // webView.loadFileURL(url, allowingReadAccessTo: url)
           //var request = URLRequest(url: url)
           request.addValue("*", forHTTPHeaderField: "Access-Control-Allow-Origin")
           self.webView.load(request)
           
           self.webView.reload()
           self.imageBackView.isHidden = true
         
           
       }

       // disconnected observer
       reachability?.whenUnreachable = { _ in
           self.imageView.image = UIImage.gif(name: "No_Internet")
           self.imageBackView.isHidden = false
       }
       // start reachability observer
       do {
         try reachability?.startNotifier()
       } catch {
         print("Unable to start notifier")
       }
       
       //swipe left or right to go back or foward
       let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))
       let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(sender:)))

       leftSwipe.direction = .left
       rightSwipe.direction = .right
       
     
              let preferences = WKWebpagePreferences()
              preferences.allowsContentJavaScript = true
              webView.configuration.defaultWebpagePreferences = preferences
          

      
       view.addGestureRecognizer(leftSwipe)
       view.addGestureRecognizer(rightSwipe)

     
       NotificationCenter.default.addObserver(self, selector: #selector(doSomething), name:
                UIApplication.willEnterForegroundNotification, object: nil)
      
   }
    
    @objc private func doSomething() {
        
       
        
        if delegate.body != "message" {
            if delegate.websiteURL != "" {
              
                DispatchQueue.main.async {
                    let request = URLRequest(url: URL(string: self.delegate.websiteURL)!)
                    self.webView.load(request)
                }
                
            }
            
            let alert = UIAlertController(title: delegate.title, message: delegate.body, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
           
        }
    }

    
  


   //swipe left to go forward
    @objc func handleSwipes(sender:UISwipeGestureRecognizer) {
       if (sender.direction == .left) {
           if webView.canGoBack {
               webView.goBack()
           }
         

       }
   //swipe right to go backward
       if (sender.direction == .right) {
           if webView.canGoForward {
               webView.goForward()
           }

       }

   }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       
        if let url = navigationAction.request.url {
           
            let  sURL = url.path
            if sURL.contains("wpcfto_files") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
       
        
    decisionHandler(.allow)
    }
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
           if keyPath == "estimatedProgress" {
                     self.progressBar.alpha = 1.0
                      progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
                        self.lastURL = webView.url
                      if webView.estimatedProgress >= 1.0 {
                          UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                              self.progressBar.alpha = 0.0
                          }) { (BOOL) in
                              self.progressBar.progress = 0
                          }
                          
                      }
                      
                  }
       }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
       
      
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

}
