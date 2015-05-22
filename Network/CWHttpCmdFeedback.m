//
//  CWHttpCmdFeedback.m
//  ChinaWeather
//
//  Created by 曹 君平 on 7/19/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdFeedback.h"
#import "DeviceUtil.h"
#import "CWUserManager.h"
#import "Util.h"

// http://app.weather.com.cn/second/feedback/upload

@implementation CWHttpCmdFeedback

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://app.weather.com.cn/second/feedback/upload";
}

- (BOOL)isResponseZipped
{
    return YES;
}

- (NSData *)data
{
    NSString* content = self.content ? self.content : @"";
    NSString* email = self.email ? self.email : @"";
    NSString* tel = self.tel ? self.tel : @"";

    NSMutableDictionary *queryJson = [NSMutableDictionary dictionary];
    [queryJson setValue: [Util getAppKey] forKey: @"appKey"];

    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setValue: @"080114372073401" forKey: @"userId"];
    [data setValue: [CWUserManager sharedInstance].uid forKey: @"uId"];
//    [data setValue: [StatisticUtil getOsVersion] forKey: @"osVersion"];
    [data setValue: [DeviceUtil getSoftVersion: NO] forKey: @"softVersion"];
    [data setValue: content forKey: @"content"];
    [data setValue: email forKey: @"email"];
    [data setValue: tel forKey: @"tel"];
    
    [queryJson setValue: data forKey: @"data"];
    
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

@end
