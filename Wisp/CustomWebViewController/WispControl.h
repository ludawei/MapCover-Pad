//
//  WispControl.h
//  WeatherChina-iPhone
//
//  Created by sam on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomWebViewController.h"
#import "CustomMapViewController.h"
#import "CityMapViewController.h"

@interface WispControl : NSObject
{
    NSString * _wispController;
    NSString * _wispType;
    NSString * _wispParams;
}

@property (copy, nonatomic) NSString * wispController;
@property (copy, nonatomic) NSString * wispType;
@property (copy, nonatomic) NSString * wispParams;

- (id)initWithWispURL:(NSString *)wispUrl;

- (NSString *)getWispControllerClassName;

- (NSString *)getWispControllerViewName;

- (NSDictionary *)getVideoInfoFromUrl:(NSString *)params;

@end
