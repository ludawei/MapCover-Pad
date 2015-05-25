//
//  TyphoonSpotAnnotation.m
//  中国天气通
//
//  Created by Sam Chen on 11/14/12.
//
//

#import "TyphoonSpotAnnotation.h"

@implementation TyphoonSpotAnnotation

- (id)init
{
    if (self = [super init]){
        
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
    //return @"title";
    return @"t";
}

- (NSString *)subtitle
{
    //return @"subtitle";
    return @"";
}

//- (void)dealloc
//{
//    [super dealloc];
//}

@end
