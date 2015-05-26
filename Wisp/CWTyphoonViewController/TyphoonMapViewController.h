//
//  TyphoonMapViewController.h
//  中国天气通
//
//  Created by Sam Chen on 11/10/12.
//
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "WCMydAsyncTask.h"
#import "TyphoonSpotAnnotation.h"
#import "TyphoonSpotAnnotationView.h"
#import "WCMydTaskControl.h"

#import "BaseViewController.h"

@interface TyphoonMapViewController : BaseViewController <MKMapViewDelegate, MydDisplayDelegate, NSXMLParserDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSString * _toolBarTitleString;
    NSString * _requestType;
    NSString * _requestParams;
    NSString * _serviceId;
    NSMutableArray * _typhoonList;
    NSMutableArray * _typhoonInfo;
    NSMutableArray * _typhoonIncPoints;
    NSMutableArray * _typhoonSpotAnnotations;
    NSString * _typhoonName;
    MKPolyline * _typhoonRoutine;
    MKPolyline * _typhoonForecastRoutine;
    MKPolygon * _typhoonForecastRegion;
    MKCircle * _typhoon7circle;
    MKCircle * _typhoon10circle;
    WCMydTaskControl * _mydControl;
}

@property (copy, nonatomic) NSString * toolBarTitleString;
@property (copy, nonatomic) NSString * requestType;
@property (copy, nonatomic) NSString * requestParams;
@property (copy, nonatomic) NSString * serviceId;
@property (retain, nonatomic) NSMutableArray * typhoonList;
@property (retain, nonatomic) NSMutableArray * typhoonInfo;
@property (retain, nonatomic) NSMutableArray * typhoonIncPoints;
@property (retain, nonatomic) NSMutableArray * typhoonSpotAnnotations;
@property (retain, nonatomic) WCMydTaskControl * mydControl;
@property (retain, nonatomic) IBOutlet MKMapView *weatherMapView;
@property (retain, nonatomic) IBOutlet UILabel *typhoonLabel;
@property (retain, nonatomic) IBOutlet UIPickerView *typhoonPicker;
@property (copy, nonatomic) NSString * typhoonName;
@property (retain, nonatomic) MKPolyline * typhoonRoutine;
@property (retain, nonatomic) MKPolyline * typhoonForecastRoutine;
@property (retain, nonatomic) MKPolygon * typhoonForecastRegion;
@property (retain, nonatomic) MKCircle * typhoon7circle;
@property (retain, nonatomic) MKCircle * typhoon10circle;

@property (retain, nonatomic) IBOutlet UILabel *spotTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotLocationLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotPressureLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotWindSpeedLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotMoveDirLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotMoveSpeedLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotB7CircleLabel;
@property (retain, nonatomic) IBOutlet UILabel *spotB10CircleLabel;
@property (retain, nonatomic) IBOutlet UIView *spotInfoPanel;

@end
