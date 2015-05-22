//
//  CWHttpCmdVersionUpdate.m
//  ChinaWeather
//
//  Created by 曹 君平 on 7/26/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdVersionUpdate.h"
#import "DeviceUtil.h"
#import "Util.h"

@implementation CWHttpCmdVersionUpdate


- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://app.weather.com.cn/smartWeather";
}

- (NSDictionary *)headers
{
    return @{@"Accept" :@"application/json"};
}

- (BOOL)isResponseZipped
{
    return YES;
}

- (NSData *)data
{
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    [queryJson setValue: @"upgrade" forKey: @"method"];
    
    NSMutableDictionary* param = [NSMutableDictionary dictionary];
    [param setValue: [DeviceUtil getMobileVersion] forKey: @"mobileVersion"];
    [param setValue: @"" forKey: @"userId"];
    [param setValue: [DeviceUtil getSoftVersion: FALSE] forKey: @"softwareVersion"];
    [param setValue: [DeviceUtil getDeviceType] forKey: @"deviceType"];
    [param setValue: @"ChinaDecision2.x"/*[DeviceUtil getVersionType]*/ forKey: @"versionType"];
    [param setValue: @"mobile" forKey: @"CATEGORY"];
    
    
    [queryJson setValue: param forKey: @"param"];
    [queryJson setValue: [Util getAppKey] forKey: @"appKey"];

    
//     NSString* queryString = [[NSString alloc] initWithData: [NSJSONSerialization dataWithJSONObject: queryJson options: 0 error: nil] encoding: NSUTF8StringEncoding];
//    NETWORK(@"queryString=%@",queryString);
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

@end
