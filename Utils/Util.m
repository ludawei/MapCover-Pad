//
//  Util.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "Util.h"
#include <CommonCrypto/CommonHMAC.h>
#import "CWDataManager.h"

@implementation Util

+ (UIImage *) createImageWithColor: (UIColor *) color width:(CGFloat)width height:(CGFloat)height
{
    CGRect rect=CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSString*) getAppKey
{
    NSString* appKey = @"";
    @try
    {
        NSString* str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEATHER_APPKEY"];
        if (str != nil)
            appKey = str;
    }
    @catch(NSException* e)
    {
    }
    return appKey;
}

+ (NSString *)parseWeather:(NSString *)code
{
    switch (code.intValue)
    {
        case 10:  return @"暴雨";
        case 11:  return @"大暴雨";
        case 12:  return @"特大暴雨";
        case 13:  return @"阵雪";
        case 14:  return @"小雪";
        case 15:  return @"中雪";
        case 16:  return @"大雪";
        case 17:  return @"暴雪";
        case 18:  return @"雾";
        case 19:  return @"冻雨";
        case 20:  return @"沙尘暴";
        case 21:  return @"小到中雨";
        case 22:  return @"中到大雨";
        case 23:  return @"大到暴雨";
        case 24:  return @"暴雨到大暴雨";
        case 25:  return @"大暴雨到特大暴雨";
        case 26:  return @"小到中雪";
        case 27:  return @"中到大雪";
        case 28:  return @"大到暴雪";
        case 29:  return @"浮尘";
        case 30:  return @"扬沙";
        case 31:  return @"强沙尘暴";
        case 32:  return @"浓雾";
        case 33:  return @"雪";
        case 34:  return @"阴";
        case 35:  return @"阵雨";
        case 36:  return @"阵雨";
        case 37:  return @"阵雨";
        case 38:  return @"阵雨";
        case 39:  return @"阴";
        case 40:  return @"阴";
        case 49:  return @"强浓雾";
        case 53:  return @"霾";
        case 54:  return @"中度霾";
        case 55:  return @"重度霾";
        case 56:  return @"严重霾";
        case 57:  return @"大雾";
        case 58:  return @"特强浓雾";
        case 99:  return @"无";
        case 0:   return @"晴";
        case 1:   return @"多云";
        case 2:   return @"阴";
        case 3:   return @"阵雨";
        case 4:   return @"雷阵雨";
        case 5:   return @"雷阵雨伴有冰雹";
        case 6:   return @"雨夹雪";
        case 7:   return @"小雨";
        case 8:   return @"中雨";
        case 9:   return @"大雨";
            
        default:
            break;
    }
    return @"?";
}

+ (NSString *)parseWindDirection:(NSString *)code
{
    // {\"0\":\"无持续风向\",\"1\":\"东北风\",\"2\":\"东风\",\"3\":\"东南风\",\"4\":\"南风\",\"5\":\"西南风\",\"6\":\"西风\",\"7\":\"西北风\",\"8\":\"北风\",\"9\":\"旋转风\"}
    
    switch (code.intValue)
    {
        case 0:   return @"无持续风向";
        case 1:   return @"东北风";
        case 2:   return @"东风";
        case 3:   return @"东南风";
        case 4:   return @"南风";
        case 5:   return @"西南风";
        case 6:   return @"西风";
        case 7:   return @"西北风";
        case 8:   return @"北风";
        case 9:   return @"旋转风";
            
        default:
            break;
    }
    return @"?";
}

+ (NSString *)parseLiveWindForce:(NSString *)code
{
    switch (code.intValue)
    {
        case 0:   return @"微风";
            
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@级", code];
}

+ (NSString *)parseHourWindForce:(NSString *)code
{
    NSString *value = @"--";
    
    NSArray *flags = @[@0.2, @1.5, @3.3, @5.4, @7.9, @10.7, @13.8, @17.1, @20.7, @24.4, @28.4, @32.6, @99999.0];
    for (NSInteger i=0; i<flags.count; i++) {
        if (code.floatValue < [[flags objectAtIndex:i] floatValue]) {
            if (i==0) {
                value = @"微风";
            }
            else
            {
                value = [NSString stringWithFormat:@"%td级", i];
            }
            break;
        }
    }
    
    return value;
}


+ (NSString *)parseDayWindForce:(NSString *)code
{
    NSDictionary *dict = @{
                           @"0":@"微风",
                           @"1":@"3-4级",
                           @"2":@"4-5级",
                           @"3":@"5-6级",
                           @"4":@"6-7级",
                           @"5":@"7-8级",
                           @"6":@"8-9级",
                           @"7":@"9-10级",
                           @"8":@"10-11级",
                           @"9":@"11-12级"
                           };
    NSString *value = [dict objectForKey:code];
    if (!value) {
        value = @"--";
    }
    
    return value;
}

+ (NSString *)requestEncodeWithString:(NSString *)url appId:(NSString *)appId privateKey:(NSString *)priKey
{
    NSDateFormatter *formatter = [CWDataManager sharedInstance].formatter;
    [formatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *now = [formatter stringFromDate:[NSDate date]];
    
    NSString *public_key = [NSString stringWithFormat:@"%@date=%@&appid=%@", url, now, appId];
    NSString *key = [self encodeByPublicKey:public_key privateKey:priKey];
    
    key = [self URLEncode:key];
    NSString *finalUrl = [NSString stringWithFormat:@"%@date=%@&appid=%@&key=%@", url, now, [appId substringToIndex:6], key];
    
    return finalUrl;
}

+(NSString *)encodeByPublicKey:(NSString *)public_key privateKey:(NSString *)private_key
{
    const char *cKey  = [private_key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [public_key cStringUsingEncoding:NSASCIIStringEncoding];
    
    //sha1
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
    
    return hash;
}

+ (NSString *)URLDecode:(NSString *)str
{
    return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)URLEncode:(NSString *)str
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+(UIColor *)colorFromRGBString:(NSString *)rbgString
{
    if ([rbgString hasPrefix:@"rgba"]) {
        return [UIColor clearColor];
    }
    unsigned long rgbValue = strtoul([[rbgString stringByReplacingOccurrencesOfString:@"#" withString:@"0x"] UTF8String], 0, 16);
    
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.7];
}
@end
