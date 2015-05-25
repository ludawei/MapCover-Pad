//
//  CityMapViewController.h
//  中国天气通
//
//  Created by Sam Chen on 11/9/12.
//
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "WCMydAsyncTask.h"
#import "WeatherAnnotation.h"
#import "WeatherAnnotationView.h"
#import "WCCityLocations.h"

#define DEFAULT_WEATHER_ANNOTATION_UPDATE_TIMEINTERVAL 600

@interface CityMapViewController : UIViewController <MKMapViewDelegate>
{
    NSString * _toolBarTitleString;
    NSString * _requestType;
    NSString * _requestParams;
    NSString * _serviceId;
    NSMutableArray * _weatherAnnotations;
    NSMutableDictionary * _weatherInfos;
    BOOL _makeAnnotationsLock;
    WCCityLocations * _cityLocations;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (copy, nonatomic) NSString * toolBarTitleString;
@property (copy, nonatomic) NSString * requestType;
@property (copy, nonatomic) NSString * requestParams;
@property (copy, nonatomic) NSString * serviceId;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet MKMapView *weatherMapView;
@property (retain, nonatomic) NSMutableArray * weatherAnnotations;
@property (retain, nonatomic) NSMutableDictionary * weatherInfos;
@property (retain, nonatomic) WCCityLocations * cityLocations;
@property BOOL makeAnnotationsLock;


@end
