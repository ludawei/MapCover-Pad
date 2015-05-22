//
//  NavListHttpCmd.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-20.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "NavListHttpCmd.h"

@implementation NavListHttpCmd

-(NSString *)path
{
    NSMutableString *superPath = [NSMutableString stringWithString:[super path]];
    return [superPath stringByAppendingString:@"http://decision.tianqi.cn/data/page/navlist.html"];
}

@end
