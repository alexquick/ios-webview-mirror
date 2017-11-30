//
//  RootViewController.h
//  PresBrowser
//
//  Created by alex on 1/21/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExternalWindow.h"
#import "PresWebview.h"
#import "WDResettableTimer.h"
#import "WDTableAutocompletionController.h"
#import "PresBrowser-Swift.h"

static const NSTimeInterval kIdleTimeout = 10.0;

@interface RootViewController : UIViewController
{
    BOOL onExternal;
    WDResettableTimer *idleTimer;
}

- (IBAction) rotate;

@property (strong, nonatomic) ExternalWindow IBOutlet *secondWindow;
@property (strong, nonatomic) PresViewController IBOutlet *presViewController;
@property (strong, nonatomic) UIImageView IBOutlet *imageView;
@property (strong, nonatomic) UIView IBOutlet *containingView;
@property (strong, nonatomic) UIButton IBOutlet *rotateButton;
@property (strong, nonatomic) UITextField IBOutlet *urlField;
@property (strong, nonatomic) WDTableAutocompletionController IBOutlet *autocompletionController;
@property (strong, nonatomic) WDServer *server;

@end
