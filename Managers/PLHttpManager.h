//
//  HCHttpManager.h
//  HighCourt
//
//  Created by ludawei on 13-9-24.
//  Copyright (c) 2013年 ludawei. All rights reserved.
//

#import "AFNetworking.h"
#import "PLHttpCmd.h"

@interface PLHttpManager:NSObject
{
}

+ (PLHttpManager *)sharedInstance;

@property (nonatomic,strong) NSMutableDictionary *someDatas;

-(void)fetchWeatherWithWarnAreaIds:(NSArray *)cityIds block:(void (^)())block;
-(void)fetchWarningWithWarnAreaId:(NSString *)cityId block:(void (^)())block;

- (void)parserRequest:(PLHttpCmd *)cmd;
-(AFHTTPSessionManager *)manager;

@end
