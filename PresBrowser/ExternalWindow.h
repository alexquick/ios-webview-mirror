//
//  ExternalWindow.h
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * const kNotificationExternalDisplayChange = @"WDNotificationExternalDisplayChange";
@interface ExternalWindow : UIWindow{
    UIInterfaceOrientation currentOrientation;
}
@property (nonatomic) BOOL isActive;
@property (strong, nonatomic) UIImageView* imageView;

- (UIInterfaceOrientation) orientation;
- (void) rotate: (UIInterfaceOrientation) orientation animate: (BOOL) animate;
- (UIInterfaceOrientation) successor: (UIInterfaceOrientation) current;
@end
