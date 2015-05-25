//
//  WeatherAnnotation.m
//  MydTest
//
//  Created by Sam Chen on 10/30/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "WeatherAnnotation.h"
#import "MBundle.h"

@implementation WeatherAnnotation

@synthesize cityId = _cityId;
@synthesize cityName = _cityName;
@synthesize cityWeatherInfoString = _cityWeatherInfoString;
@synthesize cityWeatherInfo = _cityWeatherInfo;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize displayDelegate = _displayDelegate;
@synthesize taskControl = _taskControl;

- (id)init
{
    if (self = [super init]){
        self->_displayDelegate = nil;
        self.taskControl = [[WCMydTaskControl alloc] init];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = self.latitude;
    theCoordinate.longitude = self.longitude;
    return theCoordinate;
}

- (NSString *)title
{
    return self.cityName;
}

- (NSString *)subtitle
{
    if ([self.cityWeatherInfoString isEqualToString:@""]) {
        return @"";
    }
    else {
        NSString * td = [[[self.cityWeatherInfo objectForKey:@"f"] objectAtIndex:0] objectForKey:@"td"];
        NSString * tn = [[[self.cityWeatherInfo objectForKey:@"f"] objectAtIndex:0] objectForKey:@"tn"];
        if ([td isEqualToString:@""]) {
            td = [[[self.cityWeatherInfo objectForKey:@"f"] objectAtIndex:1] objectForKey:@"td"];
            return [NSString stringWithFormat:@"%@℃ ~ %@℃", tn, td];
        }
        else {
            return [NSString stringWithFormat:@"%@℃ ~ %@℃", td, tn];
        }
    }
}

//- (void)getWeatherInfo
//{
//    WCMydAsyncTask * myd = [[[WCMydAsyncTask alloc] init] autorelease];
//    //NSArray * params = @[@"101010100"];
//    NSArray * params = @[MYD_SURROUNDINGS_CITY, self.cityId];
//    [myd setListener:self];
//    [myd execute:params];
//    //[self.displayDelegate displayLoadingIndicator];
//}

- (void)getWeatherInfo
{
    NSArray * params = @[MYD_SURROUNDINGS_CITY, self.cityId];
    self.taskControl.displayDelegate = self;
    [self.taskControl getMydFromServer:params];
}

//- (void)onTriggered:(id)result
- (void)displayMydData:(id)result taskControl:(id)taskControl
{
    //[taskControl release];
    MBundle * bundle = [[[MBundle alloc] init] autorelease];
    [bundle getBundle:(NSData*)result];
    
    if (bundle.fileType == TEXT_FILE) {
        MText * mText = (MText *)bundle.tags[0];
        NSLog(@"################# ret : %@ ############### len : %d, %d", mText.text, mText.tagLen, mText.text.length);
        NSError *error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[mText.text dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"dict->%@",error);
            return;
        }
        
        self.cityWeatherInfo = dict;
        self.cityWeatherInfoString = mText.text;
        self.lastUpdated = [NSDate dateWithTimeIntervalSinceNow:0.0f];
        [self.displayDelegate displayWeatherInfo];
    }
}

- (void)dealloc
{
    self.taskControl.displayDelegate = nil;
    _displayDelegate = nil;
    [_cityId release];
    [_cityName release];
    [_cityWeatherInfoString release];
    [_cityWeatherInfo release];
    [_lastUpdated release];
    [_taskControl release];
    [super dealloc];
}

@end
