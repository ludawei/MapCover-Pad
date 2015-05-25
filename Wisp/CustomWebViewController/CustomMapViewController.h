//
//  CustomMapViewController.h
//  WeatherChina-iPhone
//
//  Created by sam on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@interface CustomMapViewController : UIViewController 
{
    NSString * _toolBarTitleString;
    NSString * _requestType;
    NSString * _requestParams;
    NSString * _serviceId;
}

@property (copy, nonatomic) NSString * toolBarTitleString;
@property (copy, nonatomic) NSString * requestType;
@property (copy, nonatomic) NSString * requestParams;
@property (copy, nonatomic) NSString * serviceId;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *toolBarTitle;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)onClose:(id)sender;

@end
