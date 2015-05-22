//
//  CWEyeMapController.m
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/12.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "CWEyeMapController.h"
#import <MapKit/MapKit.h>

#import "WebController.h"
#import "PLHttpManager.h"
#import "MKMapView+ZoomLevel.h"
#import "MBProgressHUD.h"

@interface CWEyeMapController ()<MKMapViewDelegate>

@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) MKMapView *mapView;
//@property (nonatomic,strong) UIWebView *webView;

@end

@implementation CWEyeMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.title = @"天气网眼";
    
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    
    [self initMapView];
    
//    [self initWebView];
}

-(void)initMapView
{
    self.mapView = [[MKMapView alloc] init];
    self.mapView.frame = self.backView.bounds;
    self.mapView.delegate = self;
    //    self.mapView.showsUserLocation = YES;
    [self.backView addSubview:self.mapView];
    [self.backView sendSubviewToBack:self.mapView];
}

-(void)addAnnotationWithServerDatas:(NSArray *)datas
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
        anno.coordinate = CLLocationCoordinate2DMake([dict[@"lat"] floatValue], [dict[@"lon"] floatValue]);
        anno.title      = dict[@"name"];
        anno.subtitle   = dict[@"url"];
        [annos addObject:anno];
    }
    
    [self.mapView addAnnotations:annos];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- self methods
-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"pointIdentifier";
        
        MKAnnotationView *poiAnnotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (!poiAnnotationView)
        {
            poiAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            animation.duration = (arc4random_uniform(10)/10.0f);
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:1.0f];
            
            [poiAnnotationView.layer addAnimation:animation forKey:@"animate"];
        }
        
        poiAnnotationView.canShowCallout = NO;
        poiAnnotationView.image = [UIImage imageNamed:@"weather_camera_icon"];
//        poiAnnotationView.centerOffset = CGPointMake(0, -20);
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSString *url = [view.annotation subtitle];
    if (url) {
        NSDictionary *info = @{@"l2": url};
        
        WebController *next = [[WebController alloc] init];
        next.info = info;
        next.hideCollButton = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:next];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[PLHttpManager sharedInstance].manager GET:@"http://decision.tianqi.cn//data/video/videoweather.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            NSArray *datas = (NSArray *)responseObject;
            [self addAnnotationWithServerDatas:datas];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
//    if (mapView.zoomLevel > 4.8) {
//        [mapView setZoomLevel:4.8 center:mapView.centerCoordinate animated:YES];
//    }
}

@end
