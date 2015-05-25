//
//  WeatherAnnotationView.h
//  MydTest
//
//  Created by Sam Chen on 10/28/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "WeatherAnnotation.h"

@interface WeatherAnnotationView : MKAnnotationView <AnnotationWeatherDisplayDelegate>
{
    UIActivityIndicatorView * _loadingIndicator;
}

@property (retain, nonatomic) UIActivityIndicatorView * loadingIndicator;
@property (copy, nonatomic) NSString * info;

@end
