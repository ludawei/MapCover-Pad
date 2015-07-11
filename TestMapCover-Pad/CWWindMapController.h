//
//  CWWindMapController.h
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/14.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BaseViewController.h"

@interface CWWindMapController : BaseViewController

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,assign) BOOL hideNav;

@end
