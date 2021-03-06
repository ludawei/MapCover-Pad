//
//  HCHttpCmd.h
//  HighCourt
//
//  Created by ludawei on 13-9-23.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define AFHTTPRequestOperation NSURLSessionDataTask

typedef void (^HCHttpCmdSuccess)(id object);
typedef void (^HCHttpCmdFailed)(AFHTTPRequestOperation *response);

typedef void (^PLProgressBlock)(NSUInteger bytes, long long totalBytes, long long totalBytesExpected);

@interface PLHttpCmd : NSObject

@property (nonatomic,copy) HCHttpCmdSuccess success;
@property (nonatomic,copy) HCHttpCmdFailed fail;

- (BOOL)isResponseZipped;

@property (weak, nonatomic) UIView *view;

+ (id)cmd;

- (NSString *)method;
- (NSString *)path;
- (NSDictionary *)headers;
- (NSDictionary *)queries;
- (NSData *)data;

- (void)didSuccess:(id)object;
- (void)didFailed:(AFHTTPRequestOperation *)response;

- (void)startRequest;
- (void)startRequestWithOutAnimation;

@end
