//
//  ExternalWindow.m
//  PresBrowser
//
//  Created by alex on 1/15/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "ExternalWindow.h"
#import "WDSettings.h"

@implementation ExternalWindow

@synthesize imageView;
@synthesize size;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set up the AirPlay code
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        
        [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                       name:UIScreenDidConnectNotification object:nil];
        [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                       name:UIScreenDidDisconnectNotification object:nil];
        
        currentOrientation = [[WDSettings instance] orientation];
        
        // Create an image inside the window so that we can draw
        // the web view into it.
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.backgroundColor = [UIColor redColor];
        }
        self.backgroundColor = [UIColor orangeColor];
        self.hidden = YES;
        [self addSubview:imageView];
        [self checkForInitialScreen];
    }
    return self;
}

- (void) onScreen: (UIScreen *)screen animate: (BOOL) animate{
    self.screen = screen;
	self.screen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
    [self rotate:currentOrientation animate:false];
    // Finish it
	self.isActive = YES;
    self.size = screen.bounds.size;
    self.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName: kNotificationExternalDisplayChange object:self];
}

- (void)rotate:(UIInterfaceOrientation)orientation animate:(BOOL)animate{
    float angle = [self transformAngle:UIInterfaceOrientationLandscapeRight to:orientation];
    
    CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
    
    CGRect screenBounds = self.screen.bounds;
    CGRect windowBounds = screenBounds;
    
    if(UIInterfaceOrientationIsPortrait(orientation)){
        windowBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
    }
    CGPoint center = CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2);
    
    self.transform = CGAffineTransformIdentity;
    self.frame = windowBounds;
    self.center = center;
    self.transform = trans;

    imageView.hidden = false;
    imageView.frame = windowBounds;
    
    currentOrientation = orientation;
    self.size = self.bounds.size;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationExternalDisplayChange object:self];
}

- (float) transformAngle: (UIInterfaceOrientation) from to: (UIInterfaceOrientation) to{
    float diff = (float)([self orientationOrder:to] - [self orientationOrder:from]);
    if(diff == 0){
        return 0.0f;
    }else if (diff > 0){
        return diff * M_PI_2;
    }else{
        return (4+diff) * M_PI_2;
    }
    return -1;
}

- (int) orientationOrder: (UIInterfaceOrientation) orientation{
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationLandscapeRight:
            return 0;
        case UIInterfaceOrientationPortrait:
            return 1;
        case UIInterfaceOrientationLandscapeLeft:
            return 2;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 3;
    }
    return -1;
}

- (UIInterfaceOrientation)successor: (UIInterfaceOrientation)current{
    switch (current) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationPortrait;
        case UIInterfaceOrientationPortrait:
            return UIInterfaceOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeLeft:
            return UIInterfaceOrientationPortraitUpsideDown;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientation)orientation{
    return currentOrientation;
}

- (void)checkForInitialScreen{
    if ([[UIScreen screens] count] > 1) {
        // Get the screen object that represents the external display.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        [self onScreen:secondScreen animate: false];
    }
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    UIScreen *newScreen = [aNotification object];
	[self onScreen:newScreen animate: true];
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    self.isActive = NO;
    self.screen = [UIScreen mainScreen];
    self.hidden = YES;
    self.size = CGSizeZero;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationExternalDisplayChange object:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
