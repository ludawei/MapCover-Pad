//
//  WeatherAnnotation.h
//  MydTest
//
//  Created by Sam Chen on 10/30/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WCMYDAsyncTask.h"
#import "WCMydTaskControl.h"

@protocol AnnotationWeatherDisplayDelegate <NSObject>

@optional

- (void)displayWeatherInfo;
- (void)displayLoadingIndicator;

@end

@interface WeatherAnnotation : NSObject <MKAnnotation, MydDisplayDelegate>
{
    NSString * _cityId;
    NSString * _cityName;
    NSString * _cityWeatherInfoString;
    NSDictionary * _cityWeatherInfo;
    NSDate * _lastUpdated;
    double _latitude;
    double _longitude;
    id<AnnotationWeatherDisplayDelegate> _displayDelegate;
    WCMydTaskControl * _taskControl;
}

@property (copy, nonatomic) NSString * cityId;
@property (copy, nonatomic) NSString * cityName;
@property (copy, nonatomic) NSString * cityWeatherInfoString;
@property (retain, nonatomic) NSDictionary * cityWeatherInfo;
@property (retain, nonatomic) NSDate * lastUpdated;
@property double latitude;
@property double longitude;
@property (assign, nonatomic) id<AnnotationWeatherDisplayDelegate> displayDelegate;
@property (retain, nonatomic) WCMydTaskControl * taskControl;

- (void)getWeatherInfo;

@end
