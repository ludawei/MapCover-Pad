//
//  CWHttpCmdUserId.m
//  ChinaWeather
//
//  Created by 曹 君平 on 7/24/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdUserId.h"
#import "Util.h"

// http://app.weather.com.cn/smartWeather

@implementation CWHttpCmdUserId

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://app.weather.com.cn/smartWeather";
}

- (NSData *)data
{
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    [queryJson setValue: @"uuid" forKey: @"method"];
    [queryJson setValue: [Util getAppKey] forKey: @"appKey"];
    
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

- (void)didSuccess:(id)object
{
    NSString *str = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];

    [super didSuccess:str];
}

@end
