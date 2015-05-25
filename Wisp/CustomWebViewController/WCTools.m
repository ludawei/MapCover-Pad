//
//  WCTools.m
//  WeatherChina-iPhone
//
//  Created by sam on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCTools.h"
//#import "AppDelegate.h"

@implementation WCTools


+ (NSString *)makeDateSolarString:(NSString *)dateSolar byFormat:(NSString *)dateFormat
{
    NSString * year = [dateSolar substringWithRange:NSMakeRange(0, 4)];
    NSString * month = [dateSolar substringWithRange:NSMakeRange(4, 2)];
    NSString * day = [dateSolar substringWithRange:NSMakeRange(6, 2)];
    
    NSString * dateSolarStr = @"";
    
    month = [NSString stringWithFormat:@"%d", [month intValue]];
    day = [NSString stringWithFormat:@"%d", [day intValue]];
    
    if ([dateFormat isEqualToString:@"YMD"]) {
        dateSolarStr = [NSString stringWithFormat:@"%@年%@月%@日", year, month, day];
    }
    else if ([dateFormat isEqualToString:@"Y/M/D"]) {
        dateSolarStr = [NSString stringWithFormat:@"%@/%@/%@", year, month, day];
    }
    else if ([dateFormat isEqualToString:@"MD"]) {
        dateSolarStr = [NSString stringWithFormat:@"%@月%@日", month, day];
    }
    else if ([dateFormat isEqualToString:@"M/D"]) {
        dateSolarStr = [NSString stringWithFormat:@"%@/%@", month, day];
    }
    else if ([dateFormat isEqualToString:@"D"]) {
        dateSolarStr = [NSString stringWithFormat:@"%@", day];
    }
    else if ([dateFormat isEqualToString:@"YM"]) {
        dateSolarStr = [NSString stringWithFormat:@"%@年%@月", year, month];
    }
    
    return dateSolarStr;
}

+ (NSString *)makeDateTimeSolarString:(NSString *)dateTime byFormat:(NSString *)dateTimeFormat
{
    NSString * year;
    NSString * month;
    NSString * day;
    NSString * hour;
    NSString * minute;
    NSString * second;
    if (dateTime.length == 12) {
        year = [dateTime substringWithRange:NSMakeRange(0, 4)];
        month = [dateTime substringWithRange:NSMakeRange(4, 2)];
        day = [dateTime substringWithRange:NSMakeRange(6, 2)];
        hour = [dateTime substringWithRange:NSMakeRange(8, 2)];
        minute = [dateTime substringWithRange:NSMakeRange(10, 2)];
    }
    else if (dateTime.length == 10) {
        year = [dateTime substringWithRange:NSMakeRange(0, 4)];
        month = [dateTime substringWithRange:NSMakeRange(4, 2)];
        day = [dateTime substringWithRange:NSMakeRange(6, 2)];
        hour = [dateTime substringWithRange:NSMakeRange(8, 2)];
        minute = @"00";
    }
    else if (dateTime.length == 8) {
        year = [dateTime substringWithRange:NSMakeRange(0, 4)];
        month = [dateTime substringWithRange:NSMakeRange(4, 2)];
        day = [dateTime substringWithRange:NSMakeRange(6, 2)];
        hour = @"00";
        minute = @"00";
    }
    else if (dateTime.length == 14) {
        year = [dateTime substringWithRange:NSMakeRange(0, 4)];
        month = [dateTime substringWithRange:NSMakeRange(4, 2)];
        day = [dateTime substringWithRange:NSMakeRange(6, 2)];
        hour = [dateTime substringWithRange:NSMakeRange(8, 2)];
        minute = [dateTime substringWithRange:NSMakeRange(10, 2)];
        second = [dateTime substringWithRange:NSMakeRange(12, 2)];
    }
    else {
        return @"";
    }
    
    NSString * dateTimeStr = @"";
    
    month = [NSString stringWithFormat:@"%d", [month intValue]];
    day = [NSString stringWithFormat:@"%d", [day intValue]];
    //hour = [NSString stringWithFormat:@"%d", [hour intValue]];
    //minute = [NSString stringWithFormat:@"%d", [minute intValue]];
    
    if ([dateTimeFormat isEqualToString:@"YMDHM"]) {
        dateTimeStr = [NSString stringWithFormat:@"%@年%@月%@日%@:%@", year, month, day, hour, minute];
    }
    else if ([dateTimeFormat isEqualToString:@"MDH"]) {
        dateTimeStr = [NSString stringWithFormat:@"%@月%@日%@时", month, day, hour];
    }
    else if ([dateTimeFormat isEqualToString:@"DH"]) {
        dateTimeStr = [NSString stringWithFormat:@"%@日%@时", day, hour];
    }
    else if ([dateTimeFormat isEqualToString:@"MDHM"]) {
        dateTimeStr = [NSString stringWithFormat:@"%@月%@日%@:%@", month, day, hour, minute];
    }
    else if ([dateTimeFormat isEqualToString:@"Y-M-D H:M"]) {
        dateTimeStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", year, month, day, hour, minute];
    }
    
    return dateTimeStr;
}

+ (NSString *)makeUpdateTimeFromNow:(NSDate *)updateTime byFormat:(NSString *)dateFormat
{
    if (!updateTime) {
        return @"";
    }
    
    NSTimeInterval timeInterval = [updateTime timeIntervalSinceNow];
    
    if (timeInterval > -86400) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"HH:mm"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *formattedDateString = [dateFormatter stringFromDate:updateTime];
        return [NSString stringWithFormat:@"%@更新", formattedDateString];
    }
    else {
        int day = timeInterval / -86400;
        return [NSString stringWithFormat:@"%d天前更新", day];
    }
}

+ (NSString *)makeShortDateWeekTerm:(NSString *)dateWeek
{
    if (dateWeek) {
        return [dateWeek stringByReplacingOccurrencesOfString:@"星期" withString:@"周"];
    }
    else return nil;
}

+ (int)getLinkTypeByUrl:(NSString *)linkURL
{
    int linkType = 0;
//    NSRange range = NSMakeRange(0, 7);
//    NSString * type = [linkURL substringWithRange:range];
//    if ([type isEqualToString:@"http://"]) {
//        linkType = REMOTE_WEB;
//    }
//    else if ([type isEqualToString:@"https://"]) {
//        linkType = REMOTE_WEB_SSL;
//    }
//    else if ([type isEqualToString:@"wisp://"]) {
//        linkType = WISP;
//    }
//    else {
//        linkType = LOCAL_WEB;
//    }
    
    if ([linkURL rangeOfString:@"http://"].length == 7 && [linkURL rangeOfString:@"http://"].location == 0) {
        linkType = REMOTE_WEB;
    }
//    else if ([linkURL rangeOfString:@"wisp://templates"].length == 16 && [linkURL rangeOfString:@"wisp://templates"].location == 0) {
//        linkType = LOCAL_WEB;
//    }
//    else if ([linkURL rangeOfString:@"wisp://sTel.wi"].length == 14 && [linkURL rangeOfString:@"tel://"].location == 0) {
//        linkType = TEL;
//    }
    else if ([linkURL rangeOfString:@"wisp://"].length == 7 && [linkURL rangeOfString:@"wisp://"].location == 0) {
        linkType = WISP;
    }
    else if ([linkURL rangeOfString:@"https://"].length == 8 && [linkURL rangeOfString:@"https://"].location == 0) {
        linkType = REMOTE_WEB_SSL;
    }
    else if ([linkURL rangeOfString:@"tel://"].length == 6 && [linkURL rangeOfString:@"tel://"].location == 0) {
        linkType = TEL;
    }
    else {
        linkType = LOCAL_WEB;
    }
    
    return linkType;
}

+ (BOOL)isLocalTemplateFile:(NSString*)localWebURL
{
    NSArray * urlComponents = [localWebURL componentsSeparatedByString:@"?"];
    NSURL * url = [NSURL URLWithString:urlComponents[0]];
    NSString *lastPathComp = [url lastPathComponent];
    
    NSString * path = nil;
    path = [[NSBundle mainBundle] pathForResource:lastPathComp ofType:nil];

    if (path == nil) {
        return NO;
    }
    
    if ([lastPathComp rangeOfString:@"template"].length > 0
        && [lastPathComp rangeOfString:@"template"].location == 0
        && [lastPathComp rangeOfString:@"main.html"].length > 0){
        return YES;
    }
    else {
        return NO;
    }    
    
}

+ (NSString *)getTargetURLTitle:(NSString*)targetURL
{
    if ([[targetURL componentsSeparatedByString:@"title="] count] >= 2) {
        NSString * titleStr = [targetURL componentsSeparatedByString:@"title="][1];
        NSString * title = [titleStr componentsSeparatedByString:@"&"][0];
        NSString * result = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"result = %@", result);
        return result;
    }
    else {
        return @"";
    }
}

+ (NSString *)getLocalTemplateFileFullPath:(NSString*)localWebURL
{
    NSArray * urlComponents = [localWebURL componentsSeparatedByString:@"?"];
    
    NSString * path = nil;
    if ([urlComponents count] == 1) {
        path = [[NSBundle mainBundle] pathForResource:urlComponents[0] ofType:nil];
    }
    else if ([urlComponents count] == 2) {
        NSString * pathWithoutParams = [[NSBundle mainBundle] pathForResource:urlComponents[0] ofType:nil];
        path = [NSString stringWithFormat:@"%@?%@", pathWithoutParams, urlComponents[1]];
    }
    else {
        return nil;
    }
    
    return path;
}

+ (NSURL *)getLocalTemplateFileFullURL:(NSString *)localWebFullPath
{
    NSArray * urlComponents = [localWebFullPath componentsSeparatedByString:@"?"];
    NSURL * localPathURL = nil;
    if ([urlComponents count] == 1) {
        localPathURL = [NSURL fileURLWithPath:urlComponents[0]];
    }
    else if ([urlComponents count] == 2) {
        localPathURL = [NSURL fileURLWithPath:urlComponents[0]];
        NSString * url = [NSString stringWithFormat:@"%@?%@", localPathURL, urlComponents[1]];
        localPathURL = [NSURL URLWithString:url];
    }
    else {
        return nil;
    }

    return localPathURL;
}

+ (NSString *)getURLWithLatLon:(NSString *)url
{
    if (!url || url.length == 0) {
        return @"";
    }

    NSString * urlWithLatLon = @"";
    //AppDelegate * myAppDelegate = [[UIApplication sharedApplication] delegate];
    NSString * openGPS = nil;//++[myAppDelegate.userSettings.settings objectForKey:@"openGPS"];
    //NSString * lastCity = [myAppDelegate.userSettings.settings objectForKey:@"lastCity"];
    NSString * lastLocation = nil;//++[myAppDelegate.userSettings.settings objectForKey:@"lastLocation"];
    NSString * lat = nil;
    NSString * lon = nil;
    if ([openGPS compare:@"YES"] == 0 && lastLocation.length > 0) {
        lat = [[lastLocation componentsSeparatedByString:@"|"] objectAtIndex:0];
        lon = [[lastLocation componentsSeparatedByString:@"|"] objectAtIndex:1];
    }
    else {
        return url;
    }

    if (lat && lon) {
        if ([url rangeOfString:@"?"].length > 0) {
            urlWithLatLon = [url stringByAppendingFormat:@"&lon=%@&lat=%@", lon, lat];
        }
        else {
            urlWithLatLon = [url stringByAppendingFormat:@"?lon=%@&lat=%@", lon, lat];
        }
    }

    return urlWithLatLon;
}

+ (NSString *)getCityWeatherText:(NSDictionary *)weatherInfo
{
    if (!weatherInfo) {
        return @"";
    }
    
    NSString * text = @"";
    NSString * cityName = [weatherInfo objectForKey:@"cityName"];
    NSString * fcDateWeek = [weatherInfo objectForKey:@"dateWeek"];
    fcDateWeek = [fcDateWeek stringByReplacingOccurrencesOfString:@"星期" withString:@"周"];
    //fcDateWeek = [fcDateWeek stringByReplacingOccurrencesOfString:@"周天" withString:@"周日"];
    NSArray * dateWeek = [fcDateWeek componentsSeparatedByString:@"|"];
    NSString * fcWeatherCodesCN = [weatherInfo objectForKey:@"fcWeatherCodesCN"];
    NSArray * weatherCodesCN = [fcWeatherCodesCN componentsSeparatedByString:@"|"];
    NSString * fcWeatherTemps = [weatherInfo objectForKey:@"fcWeatherTemps"];
    NSArray * weatherTemps = [fcWeatherTemps componentsSeparatedByString:@"|"];
    NSString * fcWeatherWindSpanCN = [weatherInfo objectForKey:@"fcWeatherWindSpanCN"];
    NSArray * weatherWindSpanCN = [fcWeatherWindSpanCN componentsSeparatedByString:@"|"];
    
    // Day 1
    NSString * tempSpanStr = @"";
    NSString * weatherSpanStr = @"";
    if ([[weatherInfo objectForKey:@"dayNightFlag"] isEqualToString:@"day"]) {
        tempSpanStr = [NSString stringWithFormat:@"%@℃~%@℃", [weatherTemps objectAtIndex:0], [weatherTemps objectAtIndex:1]];
        if ([[weatherCodesCN objectAtIndex:0] isEqualToString:[weatherCodesCN objectAtIndex:1]]) {
            weatherSpanStr = [NSString stringWithString:[weatherCodesCN objectAtIndex:0]];
        }
        else {
            weatherSpanStr = [NSString stringWithFormat:@"%@转%@", [weatherCodesCN objectAtIndex:0], [weatherCodesCN objectAtIndex:1]];
        }
        
        text = [NSString stringWithFormat:@"%@，%@%@，%@，%@；",
                cityName,
                [dateWeek objectAtIndex:0], weatherSpanStr, tempSpanStr,[weatherWindSpanCN objectAtIndex:0]];
    }
    else {
        tempSpanStr = [NSString stringWithFormat:@"最低%@℃", [weatherTemps objectAtIndex:1]];
        weatherSpanStr = [weatherCodesCN objectAtIndex:1];
        text = [NSString stringWithFormat:@"%@，%@夜间%@，%@，%@；",
                cityName,
                [dateWeek objectAtIndex:0], weatherSpanStr, tempSpanStr,[weatherWindSpanCN objectAtIndex:0]];
    }
    
    // Day 2
    tempSpanStr = [NSString stringWithFormat:@"%@℃~%@℃", [weatherTemps objectAtIndex:2], [weatherTemps objectAtIndex:3]];
    if ([[weatherCodesCN objectAtIndex:2] isEqualToString:[weatherCodesCN objectAtIndex:3]]) {
        weatherSpanStr = [NSString stringWithString:[weatherCodesCN objectAtIndex:2]];
    }
    else {
        weatherSpanStr = [NSString stringWithFormat:@"%@转%@", [weatherCodesCN objectAtIndex:2], [weatherCodesCN objectAtIndex:3]];
    }
    text = [text stringByAppendingFormat:@"%@%@，%@，%@；", [dateWeek objectAtIndex:1],
            weatherSpanStr, tempSpanStr, [weatherWindSpanCN objectAtIndex:1]];
    
    // Day 3
    tempSpanStr = [NSString stringWithFormat:@"%@℃~%@℃", [weatherTemps objectAtIndex:4], [weatherTemps objectAtIndex:5]];
    if ([[weatherCodesCN objectAtIndex:4] isEqualToString:[weatherCodesCN objectAtIndex:5]]) {
        weatherSpanStr = [NSString stringWithString:[weatherCodesCN objectAtIndex:4]];
    }
    else {
        weatherSpanStr = [NSString stringWithFormat:@"%@转%@", [weatherCodesCN objectAtIndex:4], [weatherCodesCN objectAtIndex:5]];
    }
    text = [text stringByAppendingFormat:@"%@%@，%@，%@。@中国天气通", [dateWeek objectAtIndex:2],
            weatherSpanStr, tempSpanStr, [weatherWindSpanCN objectAtIndex:2]];
    
    return text;
//    (1)7天预报的第一天只有夜间数据时，分享前三天的数据，内容如下：
//    北京，周一夜间晴，-2 °C，东北风3-4级； 周二晴转多云， -1°C～11°C， 无持续风向微风；周三阴，0°C～10°C，北风2级。@中国天气通
//    (2)7天预报的第一天白天夜间数据都存在时，分享前三天的数据，内容如下：
//    北京，周一多云转晴，-2 °C～7°C，东北风3-4级； 周二晴转多云， -1°C～11°C， 无持续风向微风； 周三阴，0°C～10°C，北风2级。@中国天气通
}

+ (NSString *)getProvNameByID:(int)ProvId
{
    switch (ProvId) {
        case 10122:
            return @"安徽";
            break;
        case 10133:
            return @"澳门";
            break;
        case 10101:
            return @"北京";
            break;
        case 10104:
            return @"重庆";
            break;
        case 10123:
            return @"福建";
            break;
        case 10116:
            return @"甘肃";
            break;
        case 10128:
            return @"广东";
            break;
        case 10130:
            return @"广西";
            break;
        case 10126:
            return @"贵州";
            break;
        case 10131:
            return @"海南";
            break;
        case 10109:
            return @"河北";
            break;
        case 10105:
            return @"黑龙江";
            break;
        case 10118:
            return @"河南";
            break;
        case 10120:
            return @"湖北";
            break;
        case 10125:
            return @"湖南";
            break;
        case 10119:
            return @"江苏";
            break;
        case 10124:
            return @"江西";
            break;
        case 10106:
            return @"吉林";
            break;
        case 10107:
            return @"辽宁";
            break;
        case 10108:
            return @"内蒙古";
            break;
        case 10117:
            return @"宁夏";
            break;
        case 10115:
            return @"青海";
            break;
        case 10112:
            return @"山东";
            break;
        case 10102:
            return @"上海";
            break;
        case 10111:
            return @"陕西";
            break;
        case 10110:
            return @"山西";
            break;
        case 10127:
            return @"四川";
            break;
        case 10103:
            return @"天津";
            break;
        case 10134:
            return @"台湾";
            break;
        case 10132:
            return @"香港";
            break;
        case 10113:
            return @"新疆";
            break;
        case 10114:
            return @"西藏";
            break;
        case 10129:
            return @"云南";
            break;
        case 10121:
            return @"浙江";
            break;
        default:
            return @"";
            break;
    }

}

+ (NSString *)getProvWebSiteURLByID:(int)ProvId
{
    switch (ProvId) {
        case 10122:
            return @"http://ah.weather.com.cn";
            break;
        case 10133:
            return @"http://mo.weather.com.cn";
            break;
        case 10101:
            return @"http://bj.weather.com.cn";
            break;
        case 10104:
            return @"http://cq.weather.com.cn";
            break;
        case 10123:
            return @"http://fj.weather.com.cn";
            break;
        case 10116:
            return @"http://gs.weather.com.cn";
            break;
        case 10128:
            return @"http://gd.weather.com.cn";
            break;
        case 10130:
            return @"http://gx.weather.com.cn";
            break;
        case 10126:
            return @"http://gz.weather.com.cn";
            break;
        case 10131:
            return @"http://hainan.weather.com.cn";
            break;
        case 10109:
            return @"http://hebei.weather.com.cn";
            break;
        case 10105:
            return @"http://hlj.weather.com.cn";
            break;
        case 10118:
            return @"http://henan.weather.com.cn";
            break;
        case 10120:
            return @"http://hubei.weather.com.cn";
            break;
        case 10125:
            return @"http://hunan.weather.com.cn";
            break;
        case 10119:
            return @"http://js.weather.com.cn";
            break;
        case 10124:
            return @"http://jx.weather.com.cn";
            break;
        case 10106:
            return @"http://jl.weather.com.cn";
            break;
        case 10107:
            return @"http://ln.weather.com.cn";
            break;
        case 10108:
            return @"http://nmg.weather.com.cn";
            break;
        case 10117:
            return @"http://nx.weather.com.cn";
            break;
        case 10115:
            return @"http://qh.weather.com.cn";
            break;
        case 10112:
            return @"http://sd.weather.com.cn";
            break;
        case 10102:
            return @"http://sh.weather.com.cn";
            break;
        case 10111:
            return @"http://shaanxi.weather.com.cn";
            break;
        case 10110:
            return @"http://shanxi.weather.com.cn";
            break;
        case 10127:
            return @"http://sc.weather.com.cn";
            break;
        case 10103:
            return @"http://tj.weather.com.cn";
            break;
        case 10134:
            return @"http://www.weather.com.cn/html/province/taiwan.shtml";
            break;
        case 10132:
            return @"http://www.weather.com.cn/html/province/taiwan.shtml";
            break;
        case 10113:
            return @"http://xj.weather.com.cn";
            break;
        case 10114:
            return @"http://xz.weather.com.cn";
            break;
        case 10129:
            return @"http://yn.weather.com.cn";
            break;
        case 10121:
            return @"http://zj.weather.com.cn";
            break;
        default:
            return @"";
            break;
    }
    
}

@end
