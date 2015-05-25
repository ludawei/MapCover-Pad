//
//  OtherMapController.h
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/19.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface OtherMapController : UIViewController

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic) BOOL isShowTemp;

@end
