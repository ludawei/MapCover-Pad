//
//  CWHttpCmdHotCitys.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-11-6.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "CWHttpCmdHotCitys.h"

@implementation CWHttpCmdHotCitys

-(NSString *)path
{
    NSMutableString *superPath = [NSMutableString stringWithString:[super path]];
    return [superPath stringByAppendingString:@"http://data.weather.com.cn/adidata/hotcity.html"];
}

- (BOOL)isResponseZipped
{
    return YES;
}

@end
