//
//  PresWebview.swift
//  PresBrowser
//
//  Created by alex on 11/30/17.
//  Copyright © 2017 Oz Michaeli. All rights reserved.
//

import Foundation
import UIKit
import WebKit

@objc
class PresViewController : UIViewController, WKUIDelegate, WKNavigationDelegate, WDServerDelegate{
    private var webView : WKWebView!
    private var superview : UIView? { return view.superview }
    private var containerSize : CGSize { return view.superview?.bounds.size ?? CGSize.zero }
    private var currentNavigation : WKNavigation?
    private var frame: CGRect { return view.frame}
    
    var url: URL?
    
    @objc
    var linkedWindow : ExternalWindow!
    
    var renderSize : CGSize {
        if !(linkedWindow?.isActive ?? false){
            return containerSize
        }
        return linkedWindow!.size
    }
    
    var orientation: UIInterfaceOrientation {
        return linkedWindow?.orientation() ?? UIInterfaceOrientation.portrait
    }
    
    func navigate(url: URL) {
        self.url = url
        webView.backgroundColor = UIColor.gray
        currentNavigation = webView.load(URLRequest(url: url))
        print("-> \(url.absoluteURL)")
    }
    
    func refresh() {
        if let url = url{
            print("Reloading \(url)")
            webView.reload()
        }
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = UIView()
        view.addSubview(webView)
        webView.backgroundColor = UIColor.cyan
        view.backgroundColor = UIColor.brown
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc
    func setParent(_ parent: UIView){
        parent.addSubview(view)
        view.frame = CGRect(origin: CGPoint(), size: renderSize)
        relayout()
    }
    
    @objc
    func relayout(){
        if containerSize == CGSize.zero{
            return
        }
        view.transform = CGAffineTransform.identity
        let scale = calculateScale(size: containerSize, into: renderSize)
        let transform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        view.bounds.size = renderSize
        webView.frame.size = renderSize
        
        view.frame.origin = center(renderSize.applying(transform), containedIn: containerSize)
        view.layer.anchorPoint = CGPoint.zero
        view.transform = transform
        report()
    }
    
    func report(){
        print("frame:\(frame) render:\(renderSize) container:\(containerSize)")
    }
    
    @objc
    func screenshot() -> UIImage?{
        let size = webView.frame.size;
        if size.height == 0 || size.width == 0{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, view.isOpaque, 0.0)
        webView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img;
    }
    
    func webView(_ webView: WKWebView,
                          didCommit navigation: WKNavigation!){
        print("Navigating to \(navigation.debugDescription)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigtion: WKNavigation!) {
        if (navigtion == currentNavigation){
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func webView(_: WKWebView, didFinish navigation: WKNavigation!) {
        if navigation == currentNavigation{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error){
        print("Error: \(navigation) -> \(error)")
    }
    
    func webView(_ webView: WKWebView,
                 didFail: WKNavigation!,
                 withError error: Error){
        print("Error: \(didFail) -> \(error)")
    }
}
