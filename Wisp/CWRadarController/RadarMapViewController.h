
//
//  RadarMapViewController.h
//  中国天气通
//
//  Created by Sam Chen on 11/10/12.
//
//

#import <UIKit/UIKit.h>
#import "TaskListener.h"
#import "MapKit/MapKit.h"
#import "WCMydAsyncTask.h"
#import "WCMydTaskControl.h"

@interface RadarMapViewController : UIViewController <MKMapViewDelegate, MydDisplayDelegate, NSXMLParserDelegate>
{
    NSString * _toolBarTitleString;
    NSString * _requestType;
    NSString * _requestParams;
    NSString * _serviceId;
    NSMutableArray * _radarList;
    NSString * _timeStamp;
    WCMydTaskControl * _mydControl;
}

@property (copy, nonatomic) NSString * toolBarTitleString;
@property (copy, nonatomic) NSString * requestType;
@property (copy, nonatomic) NSString * requestParams;
@property (copy, nonatomic) NSString * serviceId;
@property (retain, nonatomic) NSMutableArray * radarList;
@property (copy, nonatomic) NSString * timeStamp;
@property (retain, nonatomic) WCMydTaskControl * mydControl;
@property (retain, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *toolBarTitle;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet MKMapView *weatherMapView;
- (IBAction)onClose:(id)sender;

@end
