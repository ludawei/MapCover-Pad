//
//  CustomWebViewController.m
//  WeatherChina-iPhone
//
//  Created by sam on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomWebViewController.h"
//#import "StatAgent.h"
//#import "CWAppDelegate.h"
//#import "AppDelegate.h"
#import "MediaPlayer/MPMoviePlayerController.h"

@interface CustomWebViewController ()

@property (nonatomic,retain) UINavigationItem *navItem;

@end

@implementation CustomWebViewController
{
    MPMoviePlayerViewController * player;
    BOOL isWebViewInitLoading;
}

@synthesize webView;
@synthesize webURL = _webURL;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize toolBarTitleString = _toolBarTitleString;
@synthesize requestType = _requestType;
@synthesize requestParams = _requestParams;
@synthesize serviceId = _serviceId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isWebViewInitLoading = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.toolBarTitleString = self.title;

    // Setup the Toolbar
    [self setupToolBar];
    
    // Install the loading indicator
    [self installLoadingIndicator];
    
    // Load the web page
    webView.userInteractionEnabled = YES;
    webView.delegate = self;
    if (self.webURL) {
        [webView loadRequest:[[[NSURLRequest alloc] initWithURL:self.webURL] autorelease]];
    }
    isWebViewInitLoading = NO;
    
}

-(void)initNav
{
    //    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //    self.view = view;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    navBar.tintColor = [UIColor clearColor];
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor], UITextAttributeTextColor,
                                    nil]];
    [navBar setBackgroundImage:[UIImage imageNamed:@"title_bar"] forBarMetrics:UIBarMetricsDefault];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:self.title];
    [navBar setItems:@[navItem]];
    [self.view addSubview:navBar];
    self.navItem = navItem;
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    customButton.adjustsImageWhenHighlighted = NO;
    customButton.showsTouchWhenHighlighted = YES;
    [customButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    navItem.leftBarButtonItem = leftBarItem;
    
    //arrow_left_24.png
    
    UIButton *customButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    customButton1.adjustsImageWhenHighlighted = NO;
    customButton1.showsTouchWhenHighlighted = YES;
    [customButton1 setImage:[UIImage imageNamed:@"arrow_left_24"] forState:UIControlStateNormal];
    [customButton1 addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarItem1 = [[UIBarButtonItem alloc] initWithCustomView:customButton1];
    
    UIButton *customButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    customButton2.adjustsImageWhenHighlighted = NO;
    customButton2.showsTouchWhenHighlighted = YES;
    [customButton2 setImage:[UIImage imageNamed:@"arrow_right_24"] forState:UIControlStateNormal];
    [customButton2 addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarItem2 = [[UIBarButtonItem alloc] initWithCustomView:customButton2];
    navItem.rightBarButtonItems = @[rightBarItem1, rightBarItem2];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setupToolBar
{
    CGRect frame = self.webView.frame;
    frame.origin.y = 44;
    frame.size.height -= 44;
    self.webView.frame = frame;
    
    [self initNav];
    
    if (self.toolBarTitleString && self.toolBarTitleString.length>0) {
        self.navItem.title = self.toolBarTitleString;
    }
    else
    {
        self.navItem.title = self.title;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{  
    [self showLoading];  
    //NSLog(@"start load");  
}  

- (void)webViewDidFinishLoad:(UIWebView *)webView  
{  
    [self hideLoading];  
    //NSLog(@"finish load");
    
    if (!self.navItem.title || self.navItem.title.length == 0) {
        self.navItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}  

- (void)showLoading  
{  
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  
    self.loadingIndicator.hidden = NO;  
    [self.loadingIndicator startAnimating];  
}  

- (void)hideLoading  
{  
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  
    self.loadingIndicator.hidden = YES;  
    [self.loadingIndicator stopAnimating];  
}

- (void)installLoadingIndicator
{
    self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)] autorelease];
    CGPoint center = self.view.center;
    [self.loadingIndicator setCenter:center];
    [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.loadingIndicator];
}

- (void)onClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBack:(id)sender {
    [self.webView goBack];
}

- (void)goForward:(id)sender {
    [self.webView goForward];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (isWebViewInitLoading == YES) {
        return YES;
    }
    
    if ( UIWebViewNavigationTypeLinkClicked==navigationType) {
        NSString *strUrl = [[request mainDocumentURL] absoluteString];
//        NSLog(@"mainDocumentURL URL : %@", strUrl);
        int linkType = 0;
        linkType = [WCTools getLinkTypeByUrl:strUrl];
        
        if (linkType == WISP) {
            WispControl * wisp = [[WispControl alloc] initWithWispURL:strUrl];
            NSString * controllerClass = [wisp getWispControllerClassName];
            NSString * controllerViewName = [wisp getWispControllerViewName];
            
            if ([controllerClass isEqualToString:@"CustomVideoViewController"]) {
                NSDictionary * videoInfo = [wisp getVideoInfoFromUrl:wisp.wispParams];
                player = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videoInfo objectForKey:@"src"]]] autorelease];
                [player.moviePlayer prepareToPlay];
                [player.moviePlayer setShouldAutoplay:NO];
                [player.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
                [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
                
                //[self.view addSubview:player.view];

//#if 1
//                CWAppDelegate *appDelegate = (CWAppDelegate *)[UIApplication sharedApplication].delegate;
//                [appDelegate.navViewController presentMoviePlayerViewControllerAnimated:player];
//#else
//                [self presentMoviePlayerViewControllerAnimated:player];
//#endif
//                [player.moviePlayer play];
//                
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doVideoPlayFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
            }
            else if ([controllerClass isEqualToString:@"CustomWebViewController"]) {
                UIViewController * wispView = [[NSClassFromString(controllerClass) alloc] initWithNibName:controllerViewName bundle:nil];
                [wispView setRequestType:wisp.wispType];
                [wispView setRequestParams:wisp.wispParams];
                [wispView setToolBarTitleString:@"天气资讯"];
                if (self.navigationController == nil) {
                    [[self.view nextResponder] presentModalViewController:wispView animated:YES];
                }
                else {
                    [self.navigationController pushViewController:wispView animated:YES];
                }
                [wispView release];
            }
            else if ([controllerClass isEqualToString:@"CityMapViewController"]) {
                CityMapViewController * wispView = [[CityMapViewController alloc] initWithNibName:controllerViewName bundle:nil];
                [wispView setRequestType:wisp.wispType];
                [wispView setRequestParams:wisp.wispParams];
                [wispView setToolBarTitleString:@"周边天气"];
                if (self.navigationController == nil) {
                    [[self.view nextResponder] presentModalViewController:wispView animated:YES];
                }
                else {
                    [self.navigationController pushViewController:wispView animated:YES];
                }
                [wispView release];
            }
            else if ([controllerClass isEqualToString:@"CustomMapViewController"]) {
                UIViewController * wispView = [[NSClassFromString(controllerClass) alloc] initWithNibName:controllerViewName bundle:nil];
                [wispView setRequestType:wisp.wispType];
                [wispView setRequestParams:wisp.wispParams];
                [wispView setToolBarTitleString:@"天气地图"];
                if (self.navigationController == nil) {
                    [[self.view nextResponder] presentModalViewController:wispView animated:YES];
                }
                else {
                    [self.navigationController pushViewController:wispView animated:YES];
                }
                [wispView release];
            }
            else if ([controllerClass isEqualToString:@"FeedbackViewController"]) {
                UIViewController * wispView = [[NSClassFromString(controllerClass) alloc] initWithNibName:controllerViewName bundle:nil];
                [[self.view nextResponder] presentModalViewController:wispView animated:YES];
                [wispView release];
            }
            else if ([controllerClass isEqualToString:@"TelephoneCallController"]) {
                NSArray * components = [wisp.wispParams componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
                if ([components[0] compare:@"tel"] == 0) {
                    NSString * telUrl = [NSString stringWithFormat:@"tel://%@", components[1]];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telUrl]];
                }
            }
            else if ([controllerClass isEqualToString:@"LocalWebViewController"]) {
                CustomWebViewController * webController = [[CustomWebViewController alloc] initWithNibName:@"CustomWebView" bundle:nil];
                strUrl = [strUrl substringFromIndex:7];
                [webController setWebURL:[[[NSURL alloc] initWithString:strUrl] autorelease]];
                NSString * title = [WCTools getTargetURLTitle:strUrl];
                [webController setTitle:title];
                webController.hidesBottomBarWhenPushed = YES;
                if (self.navigationController == nil) {
                    [[self.view nextResponder] presentModalViewController:webController animated:YES];
                }
                else {
                    [self.navigationController pushViewController:webController animated:YES];
                }
                [webController release];
                return NO;
            }
            else {
                UIViewController * wispView = [[NSClassFromString(controllerClass) alloc] initWithNibName:controllerViewName bundle:nil];
                [wispView setTitle:@"Map"];
                [wispView setRequestType:wisp.wispType];
                [wispView setRequestParams:wisp.wispParams];
                wispView.hidesBottomBarWhenPushed = YES;
                if (self.navigationController == nil) {
                    [[self.view nextResponder] presentModalViewController:wispView animated:YES];
                }
                else {
                    [self.navigationController pushViewController:wispView animated:YES];
                }
                [wispView release];
            }
            [wisp release];
        }
        else if (linkType == REMOTE_WEB || linkType == REMOTE_WEB_SSL) {
            //
        }
        else if (linkType == LOCAL_WEB) {
            CustomWebViewController * webController = [[CustomWebViewController alloc] initWithNibName:@"CustomWebView" bundle:nil];
            [webController setWebURL:[[[NSURL alloc] initWithString:strUrl] autorelease]];
            NSString * title = [WCTools getTargetURLTitle:strUrl];
            [webController setTitle:title];
            webController.hidesBottomBarWhenPushed = YES;
            if (self.navigationController == nil) {
                [[self.view nextResponder] presentModalViewController:webController animated:YES];
            }
            else {
                [self.navigationController pushViewController:webController animated:YES];
            }
            [webController release];
            return NO;
        }
        else if (linkType == TEL) {
            //
        }
    }
    return YES;
}

- (void)doVideoPlayFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    //[player.view removeFromSuperview];
    player = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    // StatAgent
//    [StatAgent onResume:@"WebServiceView"];
//    AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
//    myAppDelegate.currentServiceId = self.serviceId;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [StatAgent onPause:self.serviceId];
}

- (void)dealloc {
    [webView release];
    [_loadingIndicator release];
    [_toolBarTitleString release];
    [_webURL release];
    [_requestType release];
    [_requestParams release];
    [_serviceId release];
    [super dealloc];
}
@end
