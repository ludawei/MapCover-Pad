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

#import "Masonry.h"

@interface CWEyeMapController ()<MKMapViewDelegate>

@property (nonatomic,strong) UIView *backView;
//@property (nonatomic,strong) UIWebView *webView;

@end

@implementation CWEyeMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.title = @"天气网眼";
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self initMapView];
    
    [self initBottomViews];
//    [self initWebView];
    
    if (self.hideNav) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

-(void)initMapView
{
//    self.mapView = [[MKMapView alloc] init];
//    self.mapView.frame = self.backView.bounds;
    self.mapView.delegate = self;
    //    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeHybrid;
    [self.backView addSubview:self.mapView];
    [self.backView sendSubviewToBack:self.mapView];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.backView);
    }];
}

-(void)initBottomViews
{
    UIButton *leftbutton = [UIButton new];
    [leftbutton setImage:[UIImage imageNamed:@"last_page"] forState:UIControlStateNormal];
    [leftbutton addTarget:self action:@selector(clickLastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:leftbutton];
    [leftbutton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView).offset(10);
        make.left.mas_equalTo(self.backView).offset(10);
    }];
    [leftbutton sizeToFit];
    
    UIButton *button = [UIButton new];
    button.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [button setImage:[UIImage imageNamed:@"weather_camera_icon"] forState:UIControlStateNormal];
    [button setTitle:@"天气网眼" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showHideNav) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.backView);
        make.right.mas_equalTo(self.backView);
    }];
    [button sizeToFit];
    
    CGFloat height = 50;
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.3];
    [self.backView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView);
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.width.mas_equalTo(self.backView).multipliedBy(0.5);
        make.height.mas_equalTo(height);
    }];
    
    UILabel *titleLbl = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:30]];
    titleLbl.textColor = UIColorFromRGB(0x929292);
    titleLbl.text = @"实景天气";
    [backView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(backView);
        make.centerX.mas_equalTo(backView.mas_centerX);
    }];
}

-(UILabel *)createLabelWithFont:(UIFont *)font
{
    UILabel *lbl = [UILabel new];
    lbl.font = font;
    lbl.adjustsFontSizeToFitWidth = YES;
    lbl.minimumScaleFactor = 0.5;
    
    return lbl;
}

-(void)showHideNav
{
    if (self.navigationController.navigationBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat navHeight = 0;
    CGFloat multi = 1;
    
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (!self.navigationController.navigationBarHidden) {
        navHeight = self.navigationController.navigationBar.height;
    }
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        multi = 0.7;
    }
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navHeight+statusHeight);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.navigationController.navigationBarHidden) {
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }
    
    if (self.hideNav) {
        [[PLHttpManager sharedInstance].manager GET:@"http://decision.tianqi.cn//data/video/videoweather.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                NSArray *datas = (NSArray *)responseObject;
                [self addAnnotationWithServerDatas:datas];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
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

-(void)clickLastPage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeItem" object:nil userInfo:@{@"indexPath": [NSIndexPath indexPathForItem:3 inSection:2]}];
}

@end
