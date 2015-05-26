//
//  MapAnimController.h
//  NextRain
//
//  Created by 卢大维 on 14-10-28.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BaseViewController.h"

@interface MapAnimController : BaseViewController

@property (nonatomic) NSInteger type;
@property (nonatomic) CLLocationCoordinate2D coor;
@property (nonatomic,strong) MKMapView *mapView;

@end
