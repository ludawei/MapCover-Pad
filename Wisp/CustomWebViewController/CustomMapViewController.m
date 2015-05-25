//
//  CustomMapViewController.m
//  WeatherChina-iPhone
//
//  Created by sam on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomMapViewController.h"
//#import "StatAgent.h"
//#import "AppDelegate.h"

@interface CustomMapViewController ()

@end

@implementation CustomMapViewController

@synthesize requestType = _requestType;
@synthesize requestParams = _requestParams;
@synthesize serviceId = _serviceId;
@synthesize toolBar = _toolBar;
@synthesize toolBarTitle = _toolBarTitle;
@synthesize mapView = _mapView;
@synthesize toolBarTitleString = _toolBarTitleString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Setup the Toolbar
    [self setupToolBar];
    
    
    NSLog(@"Type : %@, Params : %@", self.requestType, self.requestParams);
    NSString * messageStr = [NSString stringWithFormat:@"本功能暂未开放使用"];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"抱歉" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil] autorelease];
    [alert show];
}

- (void)viewDidUnload
{
    [self setToolBar:nil];
    [self setToolBarTitle:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    // StatAgent
    //[StatAgent onResume:@"MapServiceView"];
    //AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    //myAppDelegate.currentServiceId = self.serviceId;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // StatAgent
//    [StatAgent onPause:self.serviceId];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupToolBar
{
    if (self.navigationController == nil) {
        CGRect frame = self.mapView.frame;
        frame.origin.y = 44;
        self.mapView.frame = frame;
        
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"title_bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self displayToolBarTitle];
    }
    else {
        [self.toolBar removeFromSuperview];
    }
}


- (void)displayToolBarTitle
{
    self.toolBarTitle.title = self.toolBarTitleString;
}

- (void)dealloc {
    [_requestType release];
    [_requestParams release];
    [_serviceId release];
    [_toolBarTitleString release];
    [_toolBar release];
    [_toolBarTitle release];
    [_mapView release];
    [super dealloc];
}

- (IBAction)onClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
