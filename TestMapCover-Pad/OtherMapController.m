//
//  OtherMapController.m
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/19.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "OtherMapController.h"
#import "PLHttpManager.h"
#import "MBProgressHUD.h"
#import "Util.h"

#import "CustomAnnotationView.h"
#import "MapStatisticsBottomView.h"
#import "MapStatistTempView.h"
#import "MKMapView+ZoomLevel.h"
#import "Masonry.h"

@interface OtherMapController ()<MKMapViewDelegate>

@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSDictionary *datas;
@property (nonatomic)       NSInteger level;
@property (nonatomic,strong) MapStatisticsBottomView *statisticsView;
@property (nonatomic,strong) MapStatistTempView *statisticsTempView;

@end

@implementation OtherMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self initMapView];
    
    //    [self initWebView];
    NSString *url = [Util requestEncodeWithString:@"http://scapi.weather.com.cn/weather/stationinfo?" appId:@"f63d329270a44900" privateKey:@"sanx_data_99"];
    [[PLHttpManager sharedInstance].manager GET:url parameters:nil progress:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            self.datas = (NSDictionary *)responseObject;
            if (self.mapView.annotations.count == 0) {
                [self addAnnotations];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    if (self.isShowTemp) {
        self.statisticsTempView.hidden = YES;
    }
    else
    {
        self.statisticsView.hidden = YES;
    }
}

-(void)initMapView
{
//    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    [self.backView addSubview:self.mapView];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(20);
    }];
    
    [self.backView sendSubviewToBack:self.mapView];
}

-(NSArray *)annotationsWithServerDatas:(NSString *)level
{
    NSArray *datas = [self.datas objectForKey:level];
    
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
        anno.coordinate = CLLocationCoordinate2DMake([dict[@"lat"] floatValue], [dict[@"lon"] floatValue]);
        anno.title      = dict[@"name"];
        anno.subtitle   = [dict[@"stationid"] stringByAppendingFormat:@"-%@", dict[@"areaid"]];
        [annos addObject:anno];
    }
    
    return annos;
}

-(void)addAnnotations
{
    CGFloat zoomLevel = self.mapView.zoomLevel;
    NSMutableArray *annos = [NSMutableArray array];
    
    NSInteger level = 1;
    [annos addObjectsFromArray:[self annotationsWithServerDatas:@"level1"]];
    
    if (zoomLevel >= 5.5)
    {
        level = 2;
        [annos addObjectsFromArray:[self annotationsWithServerDatas:@"level2"]];
    }
    
    if (zoomLevel >= 8.5) {
        level = 3;
        [annos addObjectsFromArray:[self annotationsWithServerDatas:@"level3"]];
    }
    
    if (level == self.level) {
        return;
    }
    
    self.level = level;
    [self.mapView removeAnnotations:self.mapView.annotations];
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

-(MapStatisticsBottomView *)statisticsView
{
    if (!_statisticsView) {
//        _statisticsView = [[MapStatisticsBottomView alloc] initWithFrame:CGRectMake(0, self.backView.height, self.backView.width, self.backView.height)];
        _statisticsView = [MapStatisticsBottomView new];
        [self.backView addSubview:_statisticsView];
        [_statisticsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.and.height.mas_equalTo(self.backView);
            make.top.mas_equalTo(self.backView.mas_bottom);
        }];
    }
    
    return _statisticsView;
}

-(MapStatistTempView *)statisticsTempView
{
    if (!_statisticsTempView) {
        _statisticsTempView = [MapStatistTempView new];
        [self.backView addSubview:_statisticsTempView];
        [_statisticsTempView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.and.height.mas_equalTo(self.backView);
            make.top.mas_equalTo(self.backView.mas_bottom);
        }];
    }
    
    return _statisticsTempView;
}

#pragma mark -- MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"pointIdentifier-other";
        
        CustomAnnotationView *poiAnnotationView = (CustomAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (!poiAnnotationView)
        {
            poiAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = NO;
#if 1
        if ([poiAnnotationView isKindOfClass:[CustomAnnotationView class]]) {
            poiAnnotationView.image = [UIImage imageNamed:@"circle39"];
            [poiAnnotationView setLabelText:[annotation title]];
        }
#else
        poiAnnotationView.image = [UIImage imageNamed:@"tongji"];
#endif
        //        poiAnnotationView.centerOffset = CGPointMake(0, -20);
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = (arc4random_uniform(10)/10.0f);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0f];
        
        [poiAnnotationView.layer addAnimation:animation forKey:@"animate"];
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSString *areaid = [view.annotation subtitle];
    if (areaid && self.statisticsView.hidden) {
        
        if (self.isShowTemp) {
            self.statisticsTempView.addr = [view.annotation title];
            [self.statisticsTempView showWithStationId:areaid];
        }
        else
        {
            self.statisticsView.addr = [view.annotation title];
            [self.statisticsView showWithStationId:areaid];
        }
    }
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.datas && self.datas.count > 0) {
        [self addAnnotations];
    }
}

@end
