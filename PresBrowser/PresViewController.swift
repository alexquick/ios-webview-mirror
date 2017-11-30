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
    var linkedWindow : UIWindow!
    
    var frame: CGRect {get {return self.view.frame}
        set(newFrame){
            print("Setting frame from \(self.view.frame) to \(newFrame)")
            self.view.frame = newFrame
        }

    }
    var size: CGSize {get{return self.frame.size}}
    var renderSize : CGSize = CGSize()
    var containerFrame : CGRect = CGRect()
    
    func navigate(url: URL) {
        self.url = url
        webView.load(URLRequest(url: self.url))
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
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func link(window: UIWindow){
        self.linkedWindow = window
        self.renderSize = window.bounds.size
        self.relayout()
    }
    
    func unlinkWindow(){
        self.linkedWindow = nil;
        self.renderSize = self.containerFrame.size
        self.relayout()
    }
    
    func relayout(){
        report()
        if self.view.superview == nil{
            return
        }
        self.updateContainer()
        let priorSize = self.size
        let priorScrollOffset = self.webView.scrollView.contentOffset
        if aspect == AspectType.scaled{
            self.frame = self.calculateFrame(bounds: containerFrame)
        }else{
            self.frame = CGRect(origin: CGPoint(), size: renderSize)
        }
        self.injectJavascript()
        if self.size == priorSize || priorSize.height == 0{
            return
        }
        let factor = self.size.height / priorSize.height
        let scrollOffset = CGPoint(x: priorScrollOffset.x, y: priorScrollOffset.y * factor)
        self.webView.scrollView.setContentOffset(scrollOffset, animated: false)
        print("scroll: \(scrollOffset) was: \(priorScrollOffset)")
        report()
    }
    
    func report(){
        print("aspect: \(aspect.rawValue) frame:\(self.frame) render:\(self.renderSize) container:\(self.containerFrame) scale:\(self.webView.contentScaleFactor)")
    }
    
    func updateContainer(){
        guard var newSize = self.view.superview?.frame.size else {
            return
        }
        newSize = CGSize(width:round(newSize.width), height:round(newSize.height))
        if newSize != containerFrame.size{
            containerFrame.size = newSize
            containerFrame.origin = CGPoint()
        }
        if(renderSize == CGSize()){
            renderSize = containerFrame.size
        }
    }
    
    func assume(aspect : AspectType){
        if self.aspect == aspect{
            return
        }
        self.aspect = aspect
        self.relayout()
    }
    func injectJavascript(){
        //nop
    }
    func calculateFrame(bounds: CGRect) -> CGRect{
        let augmentedSize = self.scaleSize(size: self.renderSize, maxSize: bounds.size)
        var frame = CGRect()
        frame.size = augmentedSize
        frame.origin = self.calculateCenter(size: augmentedSize, space: bounds)
        return frame
    }
    
    func scaleSize(size: CGSize, maxSize: CGSize ) -> CGSize{
        let ratio = size.width / size.height
        var newWidth = ratio * maxSize.height
        var newHeight = maxSize.width / ratio
        
        if(newWidth > maxSize.width){
            newWidth = maxSize.width
            newHeight = maxSize.width /  ratio
        }
        if(newHeight > maxSize.height){
            newHeight = maxSize.height
            newWidth = ratio * maxSize.height
        }
        
        return CGSize(width: round(newWidth), height: round(newHeight))
    }
    
    func calculateCenter(size: CGSize, space: CGRect) -> CGPoint{
        let x = (space.size.width - size.width) / 2 + space.origin.x;
        let y = (space.size.height - size.height) / 2 + space.origin.y;
        return CGPoint(x:x,y:y);
    }
    
    func screenshot() -> UIImage?{
        let size = self.frame.size;
        if size.height == 0 || size.width == 0{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, self.view.isOpaque, 0.0)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img;
    }
    
    func webView(_ webView: WKWebView,
                          didCommit navigation: WKNavigation!){
        print("Navigating to \(navigation)")
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
