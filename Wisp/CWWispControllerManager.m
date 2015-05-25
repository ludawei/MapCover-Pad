//
//  CWWispControllerManager.m
//  ChinaWeather
//
//  Created by platomix on 13-8-20.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import "CWWispControllerManager.h"
#import "MediaPlayer/MPMoviePlayerViewController.h"
#import "WispControl.h"
#import "TyphoonMapViewController.h"
#import "RadarMapViewController.h"
#import "CityMapViewController.h"
#import "CustomMapViewController.h"
#import "CustomWebViewController.h"

#import "CWWispControllerManager.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@implementation CWWispControllerManager
static CWWispControllerManager *wispManager = nil;
static dispatch_once_t oncePredicate;
+(id)shardWispManager
{
    dispatch_once(&oncePredicate, ^{
        wispManager = [[self alloc] init];
    });
    return wispManager;
}

-(UIViewController *)responseControllerFromDataProcessWithTitle:(NSString *)title
{
    UIViewController *responseController = nil;
    NSArray * components = [self.urlString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#?"]];
    int i = 0;
    NSString *wispController = nil;
    NSString *wispParams = nil;
    NSString *wispType = nil;
    for (NSString * str in components)
    {
        if (i == 0)
            wispController = str;
        else if (i == 1)
            wispParams = str;
        else if (i == 2) {
            wispType = str;
        }
        i++;
    }    
    WispControl * wisp = [[WispControl alloc] initWithWispURL:self.urlString];
    if ([wispController isEqualToString:@"wisp://pAlarmList.wi"])
    {
        //当前城市   所有已关注的城市   预警列表
//        WeatherWarningListViewController *viewController = [[WeatherWarningListViewController alloc] initWithNibName:@"WeatherWarningListView" bundle:nil];
//        responseController = viewController;
    }
    else if ([wispController isEqualToString:@"wisp://pFeedback.wi"])
    {
        //用户反馈
        
    }
    else if ([wispController isEqualToString:@"wisp://pMapServices.wi"])
    {
        //天气雷达   台风路径  周边天气；          省级自定义？？？？
        NSString *string = [[wispParams componentsSeparatedByString:@"&"] objectAtIndex:0];
        if ([string isEqualToString:@"detail=peripheral"])
        {
            CityMapViewController *viewController = [[CityMapViewController alloc] initWithNibName:@"CityMapView" bundle:nil];
            [viewController setRequestType:wisp.wispType];
            [viewController setRequestParams:wisp.wispParams];
            responseController = viewController;
        }else if ([string isEqualToString:@"detail=typhoon"])
        {
            TyphoonMapViewController *viewController = [[TyphoonMapViewController alloc] initWithNibName:@"TyphoonMapView" bundle:nil];
            [viewController setRequestType:wisp.wispType];
            [viewController setRequestParams:wisp.wispParams];
            responseController = viewController;
        }else if ([string isEqualToString:@"detail=radar"])
        {
            RadarMapViewController *viewController = [[RadarMapViewController alloc] initWithNibName:@"RadarMapView" bundle:nil];
            [viewController setRequestType:wisp.wispType];
            [viewController setRequestParams:wisp.wispParams];
            responseController = viewController;
        }else if ([string isEqualToString:@"detail=custom"])
        {
            CustomMapViewController *viewController = [[CustomMapViewController alloc] initWithNibName:@"CustomMapView" bundle:nil];
            [viewController setRequestType:wisp.wispType];
            [viewController setRequestParams:wisp.wispParams];
            responseController = viewController;
        }
    }
    else if ([wispController isEqualToString:@"wisp://pVideoPlayer.wi"])
    {
        //视频地址   视频标题
        NSDictionary * videoInfo = [wisp getVideoInfoFromUrl:wisp.wispParams];
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videoInfo objectForKey:@"src"]]];
        [player.moviePlayer setShouldAutoplay:YES];
        [player.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
        [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [player.moviePlayer play];
        
        responseController = player;
    }
    else if ([wispController isEqualToString:@"wisp://sTel.wi"])
    {
        //打电话
        NSArray * components = [wisp.wispParams componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
        if ([components[0] isEqual:@"tel"]) {
            NSString * telUrl = [NSString stringWithFormat:@"tel://%@", components[1]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telUrl]];
        }
    }
    else if ([wispController hasPrefix:@"wisp://templates"])
    {
        CustomWebViewController * webController = [[CustomWebViewController alloc] initWithNibName:@"CustomWebView" bundle:nil];
        NSString * urlFullPath = [WCTools getLocalTemplateFileFullPath:[self.urlString substringFromIndex:7]];
        NSURL * localPathURL = [WCTools getLocalTemplateFileFullURL:urlFullPath];
        webController.hidesBottomBarWhenPushed = YES;
        webController.title = title;
        [webController setWebURL:localPathURL];
        responseController = webController;
    }
    return responseController;
}
@end
