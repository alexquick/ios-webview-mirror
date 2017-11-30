//
//  OwnableWebview.h
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExternalWindow.h"
#import "PresBrowser-Swift.h"

static  NSString * const kNotificationUserActivity = @"WDUserActivity";

@interface PresWebViewOld : UIWebView <UIWebViewDelegate, WDServerDelegate>

@property (nonatomic) CGRect containerFrame;
@property (nonatomic) CGSize renderSize;
@property (nonatomic) bool scaleViewport;

@property (nonatomic) AspectType currentAspect;
@property (strong, nonatomic) ExternalWindow *linkedWindow;

- (void) relayout;
- (void) refresh;
- (void)rescaleWebViewContent;
- (UIImage*)screenshot;
- (void) assumeAspect: (AspectType) aspect;
- (void) linkWindow:(ExternalWindow*) window;
- (void) unlinkWindow;
-(CGRect) frameInContainer: (CGRect) container;
- (void)navigateWithUrl: (NSString *) url;

@end
