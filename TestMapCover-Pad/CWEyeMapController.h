//
//  CWEyeMapController.h
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/12.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BaseViewController.h"

@interface CWEyeMapController : BaseViewController

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,assign) BOOL hideNav;

@end
