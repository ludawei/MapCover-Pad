//
//  DetailViewController.h
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/21.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (nonatomic,strong) MKMapView *mapView;

@end

