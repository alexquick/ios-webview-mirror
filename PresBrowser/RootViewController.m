//
//  RootViewController.m
//  PresBrowser
//
//  Created by alex on 1/21/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "RootViewController.h"
#import "WDSettings.h"
#import <UIKit/UIKit.h>

static NSString * const kDefaultSite = @"https://p.datadoghq.com/sb/7a2f199a2-d591505cca?tv_mode=true";

//static NSString * const kDefaultSite = @"http://google.com";
@interface RootViewController ()

@end

@implementation RootViewController

@synthesize urlField;
@synthesize rotateButton;
@synthesize presViewController;
@synthesize secondWindow;
@synthesize containingView;
@synthesize server;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        presViewController = [[PresViewController alloc] initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        
        server = [[WDServer alloc] initWithName: [[UIDevice currentDevice] name] delegate:  presViewController];
        containingView.backgroundColor = [UIColor grayColor];
        CALayer *layer = presViewController.view.layer;
        layer.shadowOffset = CGSizeMake(0, 3);
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowRadius = 5.0;
        layer.shadowOpacity = 0.5;
        
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
    secondWindow.imageView.image = image;
}

- (IBAction) rotate{
    [secondWindow rotate:[secondWindow successor:secondWindow.orientation] animate:YES];
    [presViewController relayout];
}

- (IBAction) refresh{
    [presViewController refresh];
}


- (void) handleDisplayChange{
    [presViewController relayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect externalFrame = CGRectMake(0, 0, 768, 1280);
    
    secondWindow = [[ExternalWindow alloc] initWithFrame:externalFrame];
    presViewController.linkedWindow = secondWindow;
    [presViewController setParent: containingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisplayChange)  name:kNotificationExternalDisplayChange object:nil];
    
    
    // Rendering timer
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    
    WDSettings * settings = [WDSettings instance];
    if(settings.urlHistory.count == 0){
        [settings pushUrl:kDefaultSite];
    }
    urlField.text = settings.urlHistory.lastObject;

    [presViewController navigateWithUrl: [NSURL URLWithString:urlField.text]];

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
    [presViewController refresh]; //to mitigate js leaks
}

@end
