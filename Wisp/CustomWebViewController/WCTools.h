//
//  WCTools.h
//  WeatherChina-iPhone
//
//  Created by sam on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCTools : NSObject

enum LinkType
{
    WISP = 1,
    REMOTE_WEB = 2,
    REMOTE_WEB_SSL = 3,
    LOCAL_WEB = 4,
    TEL = 5
};

+ (NSString *)makeDateSolarString:(NSString *)dateSolar byFormat:(NSString *)dateFormat;

+ (NSString *)makeDateTimeSolarString:(NSString *)dateTime byFormat:(NSString *)dateTimeFormat;

+ (NSString *)makeUpdateTimeFromNow:(NSDate *)updateTime byFormat:(NSString *)dateFormat;

+ (int)getLinkTypeByUrl:(NSString *)linkURL;

+ (NSString *)makeShortDateWeekTerm:(NSString *)dateWeek;

+ (BOOL)isLocalTemplateFile:(NSString*)localWebURL;

+ (NSString *)getTargetURLTitle:(NSString*)targetURL;

+ (NSString *)getLocalTemplateFileFullPath:(NSString*)localWebURL;

+ (NSURL *)getLocalTemplateFileFullURL:(NSString *)localWebFullPath;

+ (NSString *)getURLWithLatLon:(NSString *)url;

+ (NSString *)getCityWeatherText:(NSDictionary *)weatherInfo;

+ (NSString *)getProvNameByID:(int)ProvId;

+ (NSString *)getProvWebSiteURLByID:(int)ProvId;

@end
