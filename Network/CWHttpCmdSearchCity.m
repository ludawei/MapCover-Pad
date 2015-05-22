//
//  CWHttpCmdSearchCity.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-11-6.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "CWHttpCmdSearchCity.h"
#import "Util.h"

@implementation CWHttpCmdSearchCity

-(NSString *)path
{
    NSMutableString *superPath = [NSMutableString stringWithString:[super path]];
    return [superPath stringByAppendingString:@"http://app.weather.com.cn/second/area/town/search.do"];
}

- (NSString *)method
{
    return @"POST";
}

- (NSData *)data
{
    NSMutableDictionary* queryJson = [NSMutableDictionary dictionary];
    
    NSMutableDictionary* condition = [NSMutableDictionary dictionary];
    if(self.nameZh)     [condition setValue: self.nameZh forKey: @"nameZh"];
    if(self.nameEn)     [condition setValue: self.nameEn forKey: @"nameEn"];
    if(self.areaId)     [condition setValue: self.areaId forKey: @"areaId"];
    if(self.postCode)   [condition setValue: self.postCode forKey: @"postCode"];
    if(self.telCode)    [condition setValue: self.telCode forKey: @"telCode"];
    if(self.keyWord)    [condition setValue: self.keyWord forKey: @"keyWord"];
    
    NSMutableDictionary* pagination = [NSMutableDictionary dictionary];
    [pagination setValue:[NSNumber numberWithInt:0] forKey: @"start"];
    [pagination setValue:[NSNumber numberWithInt:300] forKey: @"limit"];
    
    [queryJson setValue: condition forKey: @"condition"];
    [queryJson setValue: pagination forKey: @"pagination"];
    [queryJson setValue: [Util getAppKey] forKey: @"appKey"];
    
    return [NSJSONSerialization dataWithJSONObject:queryJson options:0 error:nil];
}

- (BOOL)isResponseZipped
{
    return YES;
}

@end
