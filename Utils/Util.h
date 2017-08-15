//
//  Util.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

+(UIImage *) createImageWithColor: (UIColor *) color width:(CGFloat)width height:(CGFloat)height;
+ (NSString*) getAppKey;
+ (NSString *)parseWeather:(NSString *)code;
+ (NSString *)parseWindDirection:(NSString *)code;
+ (NSString *)parseLiveWindForce:(NSString *)code;
+ (NSString *)parseHourWindForce:(NSString *)code;
+ (NSString *)parseDayWindForce:(NSString *)code;

+ (NSString *)requestEncodeWithString:(NSString *)url appId:(NSString *)appId privateKey:(NSString *)priKey;
+(NSString *)encodeByPublicKey:(NSString *)public_key privateKey:(NSString *)private_key;
+ (NSString *)URLDecode:(NSString *)str;
+ (NSString *)URLEncode:(NSString *)str;

+(UIColor *)colorFromRGBString:(NSString *)rbgString;
@end
