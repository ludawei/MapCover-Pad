//
//  DetailViewController1.h
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/22.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController1 : UIViewController

@property (nonatomic,copy) NSString *detailItem;
@property (nonatomic,strong) MKMapView *mapView;

@end
