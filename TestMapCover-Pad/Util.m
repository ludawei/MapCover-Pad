//
//  Util.m
//  TestMapCover
//
//  Created by 卢大维 on 15/3/31.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "Util.h"

@implementation Util

+(UIColor *)colorFromRGBString:(NSString *)rbgString
{
    unsigned long rgbValue = strtoul([[rbgString stringByReplacingOccurrencesOfString:@"#" withString:@"0x"] UTF8String], 0, 16);
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end
