//
//  CWHttpCmdLogin.m
//  ChinaWeather
//
//  Created by lou on 13-7-31.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import "CWHttpCmdLogin.h"

@implementation CWHttpCmdLogin
// @"http://u.weather.com.cn/mobile/login"

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://u.weather.com.cn/mobile/login";
}

- (BOOL)isResponseZipped
{
    return YES;
}

- (NSData *)data
{
    NSString* username = self.username ? self.username : @"";
    NSString* password = self.password ? self.password : @"";
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    [queryJson setValue: username forKey: @"userName"];
    [queryJson setValue: password forKey: @"password"];
    
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

@end
