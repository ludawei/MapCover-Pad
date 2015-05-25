//
//  TyphoonSpotAnnotation.h
//  中国天气通
//
//  Created by Sam Chen on 11/14/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TyphoonSpotAnnotation : NSObject
{
    NSDictionary * _typhoonSpotInfo;
    double _latitude;
    double _longitude;
}

@property (retain, nonatomic) NSDictionary * typhoonSpotInfo;
@property double latitude;
@property double longitude;

@end
