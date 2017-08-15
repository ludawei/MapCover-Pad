//
//  CWHttpCmdFeedback.m
//  ChinaWeather
//
//  Created by davlu on 7/19/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "CWHttpCmdFeedback.h"
#import "DeviceUtil.h"
#import "CWUserManager.h"
#import "Util.h"
#import "PLHttpManager.h"

@implementation CWHttpCmdFeedback

- (NSString *)method
{
    return @"POST";
}

- (NSString *)path
{
    return @"http://decision-admin.tianqi.cn/Home/work/request";
}

-(void)startRequest
{
    NSString* content = self.content ? self.content : @"";
    NSString* email = self.email ? self.email : @"";
    NSString* tel = self.tel ? self.tel : @"";
    
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setValue: [Util getAppKey] forKey: @"appid"];
    [data setValue: [CWUserManager sharedInstance].uid forKey: @"uid"];
    //    [data setValue: [DeviceUtil getMobileVersion] forKey: @"osVersion"];
    //    [data setValue: [DeviceUtil getSoftVersion: NO] forKey: @"softVersion"];
    [data setValue: content forKey: @"content"];
    [data setValue: email forKey: @"email"];
    [data setValue: tel forKey: @"mobile"];
    
    [[PLHttpManager sharedInstance].manager POST:self.path parameters:data progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        [self didSuccess:responseObject];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self didFailed:operation];
    }];
}


@end
