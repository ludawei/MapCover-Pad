//
//  HCHttpManager.m
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "PLHttpManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CWHttpCmdWeather.h"
#import "DecStr.h"
#import "ZipStr.h"
#import "CWDataManager.h"
#import "CWUserManager.h"
#import "Util.h"
#import "CWHttpCmdLogin.h"
#import "CWHttpCmdNewGeoArea.h"
#import "DeviceUtil.h"

@interface PLHttpManager ()

@property (nonatomic,strong) AFHTTPSessionManager *manager;

@end

@implementation PLHttpManager

+ (PLHttpManager *)sharedInstance
{
    static PLHttpManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    self.someDatas = [NSMutableDictionary dictionary];
    
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"application/octet-stream",@"multipart/form-data", @"text/html; charset=ISO-8859-1", @"application/javascript", @"text/plain", nil];
//    [(AFJSONResponseSerializer *)self.manager.responseSerializer setReadingOptions:NSJSONReadingAllowFragments];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return self;
}

-(void)parserRequest:(PLHttpCmd *)cmd
{
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:cmd.method URLString:cmd.path parameters:cmd.queries error:nil];
    
    if ([cmd isKindOfClass:[CWHttpCmdNewGeoArea class]])
    {
        request.timeoutInterval = 5;
    }
    
    if(cmd.headers)
    {
        NSArray *keys = cmd.headers.allKeys;
        for(NSString *key in keys)
        {
            [request addValue:[cmd.headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSData *data = cmd.data;
    if(data)
    {
        int len = (int)[data length];
        char* encryStr = (char*) malloc(len);
        if(encryStr)
        {
            memcpy(encryStr, [data bytes], len);
            [DecStr encrypt: encryStr length: len];
            NSData *_data = [NSData dataWithBytes:encryStr length:len];
            free(encryStr);
            
            [request setHTTPBody:_data];
        }
    }
    
    [[self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            [cmd didSuccess:responseObject];
        }
        else
        {
//            if (error.code == NSURLErrorTimedOut) {
//                //time out error here
//                if ([cmd isKindOfClass:[CWHttpCmdNewGeoArea class]]) {
//                    
//                    NSString *url = [NSString stringWithFormat:@"%@&log=test", [error.userInfo objectForKey:@"NSErrorFailingURLKey"]];
//                    [[PLHttpManager sharedInstance].manager GET:url parameters:nil progress:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        if (responseObject) {
//                            [cmd didSuccess:responseObject];
//                        }
//                        
//                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        [cmd didFailed:error];
//                        LOG(@"%@", operation);
//                        
//                    }];
//                    return;
//                }
//            }
            [cmd didFailed:nil];
        }
    }] resume];
}

-(AFHTTPSessionManager *)manager
{
    return _manager;
}

-(void)fetchWeatherWithWarnAreaIds:(NSArray *)cityIds block:(void (^)())block
{
    CWHttpCmdWeather *cmd = [CWHttpCmdWeather cmd];
    cmd.cityIds = cityIds;
    [cmd setSuccess:^(id object) {
        
        if (cityIds.count==1) {
            id value = [object objectForKey:cityIds.firstObject];
            if (value) {
                [self.someDatas setObject:value forKey:cityIds.firstObject];
                block();
            }
        }
        else
        {
            for (NSString *cityId in cityIds) {
                id value = [object objectForKey:cityId];
                if (value) {
                    [self.someDatas setObject:value forKey:cityId];
                    block();
                }
            }
        }
        
    }];
    [cmd setFail:^(AFHTTPRequestOperation *response) {
        LOG(@"CWHttpCmdWeather fail %@", response);
        
        [self fetchWeatherWithWarnAreaIds:cityIds block:block];
    }];
    [cmd startRequest];
}

-(void)fetchWarningWithWarnAreaId:(NSString *)warnAreaId block:(void (^)())block
{
    if (warnAreaId && warnAreaId.length > 0) {
//        NSString *url = [NSString stringWithFormat:@"https://decision.tianqi.cn/alarm12379/grepalarm2.php?areaid=%@", warnAreaId];
        NSString *url = [NSString stringWithFormat:@"https://decision-admin.tianqi.cn/Home/extra/getwarns?order=1&areaid=%@", warnAreaId];
        [[PLHttpManager sharedInstance].manager GET:url parameters:nil progress:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                NSArray *datas = [(NSDictionary *)responseObject objectForKey:@"data"];
                
                [self.someDatas setObject:datas forKey:warnAreaId];
                block();
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            LOG(@"%@", operation);
            
            [self fetchWarningWithWarnAreaId:warnAreaId block:block];
        }];
    }

}

@end
