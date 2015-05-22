//
//  DetailViewController1.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/22.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "DetailViewController1.h"
#import "Masonry.h"
#import "MyOverlayImageRenderer.h"
#import "MyOverlay.h"

@interface DetailViewController1 ()<MKMapViewDelegate>

@end

@implementation DetailViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.mapView) {
        self.mapView = [[MKMapView alloc] init];
    }
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(20);
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGFloat modify = 0.0f;
    
    MyOverlay *over = [[MyOverlay alloc] initWithNorthEast:CLLocationCoordinate2DMake(80.9437+modify, -180) southWest:CLLocationCoordinate2DMake(-82.0829+modify, 179.804)];
    [self.mapView addOverlay:over];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer = nil;
    if ([overlay isKindOfClass:[MyOverlay class]]) {
        MyOverlayImageRenderer *routineView = [[MyOverlayImageRenderer alloc] initWithOverlay:overlay];
        routineView.image = [UIImage imageNamed:@"14122008.000"];
        
        renderer = routineView;
    }
    
    return renderer;
}

@end
