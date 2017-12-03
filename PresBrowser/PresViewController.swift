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
enum AspectType : Int {
    case scaled
    case native
};

@objc
class PresViewController : UIViewController, WKUIDelegate, WKNavigationDelegate, WDServerDelegate{
    var shouldScaleWithJavascript: Bool = false
    var shouldScaleWithWebkit: Bool = false
    var url: URL!
    var aspect : AspectType = AspectType.scaled
    var webView : WKWebView!
    var linkedWindow : ExternalWindow!

    var frame: CGRect {get {return self.view.frame}}
    var size: CGSize {get{return self.frame.size}}
    var renderSize : CGSize { get {
        if !(self.linkedWindow?.isActive ?? false){
            return self.containerSize
        }
        return self.linkedWindow!.bounds.size
    
    } }
    var superview : UIView? { get {return self.view.superview } }
    var containerSize : CGSize { get { return self.view.superview?.bounds.size ?? CGSize.zero } }
    var currentNavigation : WKNavigation?
    
    func navigate(url: URL) {
        self.url = url
        webView.backgroundColor = UIColor.gray
        currentNavigation = webView.load(URLRequest(url: self.url))
        print("-> \(self.url.absoluteURL)")
    }
    
    func refresh() {
        print("Reloading \(url)")
        webView.reload()
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
    
    func setParent(_ parent: UIView){
        parent.addSubview(self.view)
        self.view.frame = CGRect(origin: CGPoint(), size: renderSize)
        self.relayout()
    }
    
    func calculateScale(size: CGSize, into: CGSize) -> CGFloat{
        //we want to make a layer that is size:into scale to size:size
        if size == CGSize.zero || into == CGSize.zero{
            return 1.0
        }
        let widthRatio = size.width / into.width
        let heightRatio = size.height / into.height
        if(heightRatio < widthRatio){
            return heightRatio
        }
        return widthRatio
    }
    
    func center(_ size: CGSize, containedIn: CGSize) -> CGPoint{
        let diffWidth = containedIn.width - size.width
        let diffHeight = containedIn.height - size.height
        return CGPoint(x:diffWidth/2, y:diffHeight/2)
    }
    
    func relayout(){
        if containerSize == CGSize.zero{
            return
        }
        self.view.transform = CGAffineTransform.identity
        let scale = self.calculateScale(size: containerSize, into: renderSize)
        let transform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        self.view.bounds.size = self.renderSize
        self.webView.frame.size = self.renderSize
        
        self.view.frame.origin = center(renderSize.applying(transform), containedIn: containerSize)
        self.view.layer.anchorPoint = CGPoint.zero
        self.view.transform = transform
        report()
    }
    
    func report(){
        print("frame:\(self.frame) render:\(self.renderSize) container:\(self.containerSize)")
    }
    
    func injectJavascript(){
        //nop
    }
    
    func screenshot() -> UIImage?{
        let size = self.webView.frame.size;
        if size.height == 0 || size.width == 0{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, self.view.isOpaque, 0.0)
        self.webView.layer.render(in: UIGraphicsGetCurrentContext()!)
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
