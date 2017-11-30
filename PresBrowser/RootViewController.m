//
//  RootViewController.m
//  PresBrowser
//
//  Created by alex on 1/21/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "RootViewController.h"
#import <UIKit/UIKit.h>

static NSString * const kDefaultSite = @"https://p.datadoghq.com/sb/7a2f199a2-d591505cca?tv_mode=true";
@interface RootViewController ()

@end

@implementation RootViewController

@synthesize urlField;
@synthesize rotateButton;
@synthesize imageView;
@synthesize presViewController;
@synthesize secondWindow;
@synthesize containingView;
@synthesize server;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        presViewController = [[PresViewController alloc] initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        
        server = [[WDServer alloc] initWithName: [[UIDevice currentDevice] name] delegate:  presViewController];
        idleTimer = [WDResettableTimer resettableTimerWithTimeInterval:kIdleTimeout target:self selector:@selector(didGoIdle) repeats:true];
        NSError *error = nil;
        BOOL ok = [server startAndReturnError:(&error)];
        if(!ok){
            NSLog(@"%@ error with starting", error);
        }
        
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    NSURL *url = [NSURL URLWithString:textField.text];
    [presViewController navigateWithUrl: url];
}

- (void) onTick{
    UIImage *image = [presViewController screenshot];
    //imageView.image = image;
    //secondWindow.imageView.image = image;
}

- (IBAction) rotate{
    [secondWindow rotate:[secondWindow successor:secondWindow.orientation] animate:YES];
    imageView.frame = [presViewController calculateFrameWithBounds: containingView.bounds];
}

- (void) handleDisplayChange{
    if(secondWindow.isActive){
        [idleTimer start];
        [presViewController linkWithWindow:secondWindow];
    }else{
        [idleTimer stop];
        [presViewController unlinkWindow];
        if(onExternal){
            [self setWebOnFirstScreen];
        }
    }
}

- (void) setWebOnFirstScreen{
    [idleTimer start];
    if(!onExternal){
        NSLog(@"Attempted to swap to primary screen while already there");
        return;
    }
    [self.containingView addSubview:presViewController.view];
    [presViewController assumeWithAspect:AspectTypeScaled];
    imageView.hidden = YES;
    secondWindow.imageView.hidden = NO;
    onExternal = false;
}

- (void) setWebOnSecondScreen{

    [idleTimer stop];
    if(onExternal){
        NSLog(@"Attempted to swap to external while already on external");
        return;
    }
    
    if(!secondWindow.isActive){
        NSLog(@"Attempted to swap to external while it was inactive");
        return;
    }
    imageView.frame = presViewController.view.frame;
    [secondWindow addSubview:presViewController.view];
    [presViewController assumeWithAspect:AspectTypeNative];
    [self onTick];
    secondWindow.imageView.hidden = YES;
    imageView.hidden = NO;
    onExternal = true;
}

- (void) didGoIdle{
    NSLog(@"User went idle, trying to go to second screen");
    [self setWebOnSecondScreen];
}

- (void) didResumeFromIdle{
    NSLog(@"User went unidle");
    [self setWebOnFirstScreen];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [containingView addSubview:presViewController.view];
    [containingView addSubview:imageView];
    
    presViewController.view.frame = containingView.bounds;
    imageView.frame = containingView.bounds;
    
    onExternal = false;
    
    imageView.hidden = YES;
    imageView.alpha = 0.5;
    imageView.backgroundColor = [UIColor purpleColor];
    imageView.userInteractionEnabled = YES;
    
    [presViewController assumeWithAspect:AspectTypeScaled];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisplayChange)  name:kNotificationExternalDisplayChange object:nil];
    
    // Idle timer
    [[NSNotificationCenter defaultCenter] addObserver:idleTimer selector:@selector(reset) name:kNotificationUserActivity object:nil];
    
    // Rendering timer
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    
    CGRect externalFrame = CGRectMake(0, 0, 768, 1280);
    
    secondWindow = [[ExternalWindow alloc] initWithFrame:externalFrame];
    [secondWindow checkForInitialScreen];
    [presViewController navigateWithUrl: [NSURL URLWithString:kDefaultSite]];

    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated{
    [presViewController relayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [presViewController relayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(!onExternal){
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    // catch touches on the imageview that's behind the webview so that
    // we know when to bring the webview back from the external screen
    UITouch *touch = [touches anyObject];
    UIView *touchedView = [touch view];
    if(touchedView == imageView){
        [self didResumeFromIdle];
    }
}

@end
