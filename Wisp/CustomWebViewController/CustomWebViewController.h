//
//  CustomWebViewController.h
//  WeatherChina-iPhone
//
//  Created by sam on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCTools.h"
#import "WispControl.h"
#import "MediaPlayer/MPMoviePlayerViewController.h"

@interface CustomWebViewController : UIViewController <UIWebViewDelegate>
{
    NSURL * _webURL;
    UIActivityIndicatorView * _loadingIndicator;
    NSString * _toolBarTitleString;
    NSString * _requestType;
    NSString * _requestParams;
    NSString * _serviceId;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString * toolBarTitleString;
@property (retain, nonatomic) NSURL * webURL;
@property (retain, nonatomic) UIActivityIndicatorView * loadingIndicator;
@property (copy, nonatomic) NSString * requestType;
@property (copy, nonatomic) NSString * requestParams;
@property (copy, nonatomic) NSString * serviceId;


- (void)webViewDidStartLoad:(UIWebView *)webView;

- (void)webViewDidFinishLoad:(UIWebView *)webView;

- (void)showLoading;

- (void)hideLoading;

- (void)installLoadingIndicator;

@end
