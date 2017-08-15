//
//  CWHttpCmdLogin.m
//  ChinaWeather
//
//  Created by lou on 13-7-31.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import "CWHttpCmdLogin.h"
#import "PLHttpManager.h"
#import "Util.h"
#import "DeviceUtil.h"

@implementation CWHttpCmdLogin

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://decision-admin.tianqi.cn/home/work/login";
}

-(void)startRequest
{
    NSString* username = self.username ? self.username : @"";
    NSString* password = self.password ? self.password : @"";
    NSString* lat = self.lat ? self.lat : @"";
    NSString* lon = self.lon ? self.lon : @"";
    
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    [queryJson setValue: username forKey: @"username"];
    [queryJson setValue: password forKey: @"password"];
    [queryJson setValue:[Util getAppKey] forKey:@"appid"];
    [queryJson setValue:[DeviceUtil getSoftVersion:NO] forKey:@"software_version"];
    [queryJson setValue:[DeviceUtil getMobileVersion] forKey:@"os_version"];
    [queryJson setValue:[DeviceUtil getDeviceType] forKey:@"mobile_type"];
    [queryJson setValue:@"iOS" forKey:@"platform"];
    //    [queryJson setValue:@"" forKey:@"address"];
    [queryJson setValue:lat forKey:@"lat"];
    [queryJson setValue:lon forKey:@"lng"];
    
    [[PLHttpManager sharedInstance].manager POST:self.path parameters:queryJson progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self didSuccess:responseObject];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self didFailed:operation];
    }];
}

@end
