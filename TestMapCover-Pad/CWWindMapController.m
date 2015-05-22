//
//  CWWindMapController.m
//  ChinaWeather
//
//  Created by 卢大维 on 15/1/14.
//  Copyright (c) 2015年 Platomix. All rights reserved.
//

#import "CWWindMapController.h"
#import "NewMapCoverView.h"
#import "CWHttpCmdMicapsdata.h"
#import "CWDataManager.h"
#import "CWHttpCmdMicapspeed.h"
#import "CWWindMapBottomView.h"
#import "NSDate+Utilities.h"
#import "MBProgressHUD+Extra.h"

#import "CWUserManager.h"
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"

@interface CWWindMapController ()<MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL hadShow;
    CLGeocoder *geocoder;
}

@property (nonatomic,strong) NewMapCoverView *mainView;
@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,strong) UISegmentedControl *buttons,*buttons1;
@property (nonatomic,strong) CWWindMapBottomView *bottomView;
@property (nonatomic,strong) UIView *indexView;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@end

@implementation CWWindMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    self.navigationController.navigationBarHidden = YES;
    
    [self initMapView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDInView:self.mapView andText:nil];
//    hud.detailsLabelText = @"稍后您将看到重新绘制的动态风场图！";
//    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
    CWHttpCmdMicapsdata *cmd = [CWHttpCmdMicapsdata cmd];
    //    cmd.cityIds = @[cityId];
    cmd.vti = @"030";
    cmd.type = @"1000";
    [cmd setSuccess:^(id object) {
        LOG(@"success");
        
        [hud hide:YES];
        
        if (object && [object isKindOfClass:[NSDictionary class]]) {
            [self showMainViewWithData:object partNum:400];
        }
        
    }];
    [cmd setFail:^(AFHTTPRequestOperation *response) {
        LOG(@"CWHttpCmdWeather is failed");
        
        [hud hide:YES];
        [MBProgressHUD showHUDNoteWithText:@"加载失败,请稍后再试"];
    }];
    
    [cmd startRequest];
    
    // 注册
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // 关闭按钮
    UIButton *delButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    [delButton setImage:[UIImage imageNamed:@"btn_nav_back"] forState:UIControlStateNormal];
    [delButton addTarget:self action:@selector(clickDelete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delButton];
    
    UILabel *titleLabel = [self createLabelWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    titleLabel.text = @"风场示意图";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:titleLabel];
    
    CGFloat lblWidth = 20.0;
    UIImage *indexImage = [UIImage imageNamed:@"windMapIndex"];
    CGFloat radio = indexImage.size.width/(self.view.frame.size.width-lblWidth*2);
    
    UIView *indexView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-indexImage.size.height/radio, self.view.frame.size.width, indexImage.size.height/radio)];
    indexView.backgroundColor = [UIColor colorWithRed:0.035 green:0.059 blue:0.169 alpha:1];
    [self.view addSubview:indexView];
    self.indexView = indexView;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(lblWidth, 0, self.view.frame.size.width-lblWidth*2, indexImage.size.height/radio)];
    iv.image = indexImage;
    [indexView addSubview:iv];
    
    UILabel *leftTxt = [self createLabelWithFrame:CGRectMake(0, 0, lblWidth, CGRectGetHeight(indexView.frame))];
    leftTxt.font = [UIFont boldSystemFontOfSize:16];
    leftTxt.text = @"弱";
    [indexView addSubview:leftTxt];
    
    UILabel *rightTxt = [self createLabelWithFrame:CGRectMake(CGRectGetWidth(indexView.frame)-lblWidth, 0, lblWidth, CGRectGetHeight(indexView.frame))];
    rightTxt.font = [UIFont boldSystemFontOfSize:16];
    rightTxt.text = @"强";
    [indexView addSubview:rightTxt];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hadShow = YES;
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hiden
}

-(void)showMainViewWithData:(NSDictionary *)data partNum:(NSInteger)num
{
    self.mainView = [[NewMapCoverView alloc] initWithFrame:self.view.bounds];
    self.mainView.mapView = self.mapView;
    self.mainView.particleType = 2;
    self.mainView.partNum = num;
    [self.mainView setupWithData:data];
    self.mainView.userInteractionEnabled = NO;
    
    CWMyMotionStreakView *motionView = [[CWMyMotionStreakView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:motionView];
    self.mainView.motionView = motionView;
    
    [self.view addSubview:self.mainView];
    
    [self setupMapViewAnnitions];
}

-(UILabel *)createLabelWithFrame:(CGRect)frame
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    return titleLabel;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initMapView
{
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.zoomLevel = 4.0;
    self.mapView.alpha = 0.6;
    CLLocationCoordinate2D coord1 = {
        39.92,116.46
    };
    [self.mapView setCenterCoordinate:coord1 animated:YES];
    //    self.mapView.alpha = 0.5;
    [self.view addSubview:self.mapView];
    
    
    UISegmentedControl *buttons = [[UISegmentedControl alloc] initWithItems:@[@"箭头", @"流线"]];
    buttons.frame = CGRectMake(CGRectGetWidth(self.view.frame)-112, 10, 100, 32);
    buttons.tintColor = [UIColor colorWithWhite:1 alpha:1.0];
    [self.view addSubview:buttons];
    
    buttons.selectedSegmentIndex = 1;
    [buttons addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventValueChanged];
    self.buttons = buttons;
}

-(CWWindMapBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[CWWindMapBottomView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 250)];
        [self.view addSubview:_bottomView];
        
        __weak typeof(self) weakSelf = self;
        [_bottomView setHideBlock:^{
            weakSelf.indexView.hidden = NO;
            [weakSelf.mapView deselectAnnotation:weakSelf.mapView.annotations.lastObject animated:YES];
        }];
        _bottomView.hidden = YES;
    }
    return _bottomView;
}

- (void)setupGestures
{
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.delegate = self;
    [self.view addGestureRecognizer:self.singleTap];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.singleTap && ([touch.view isKindOfClass:[UIControl class]] || [touch.view isKindOfClass:[MKAnnotationView class]]))
    {
        return NO;
    }
    
    if ([touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}

-(void)setupMapViewAnnitions
{
    //定义一个标注
//    NSDictionary *cityInfo = 
//    NSString *cityName = [cityInfo objectForKey:@"c5"];
//    if (!cityName) {
//        cityName = [cityInfo objectForKey:@"c7"];
//    }
    
    NSString *c13 = [CWUserManager sharedInstance].lon;
    NSString *c14 = [CWUserManager sharedInstance].lat;
    
    CLLocationCoordinate2D coor;
    if (c13 && c14) {
        coor = CLLocationCoordinate2DMake([c14 floatValue], [c13 floatValue]);
    }
    
//    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self.mapView setCenterCoordinate:coor animated:YES];
    
    
    [self setupGestures];
    
    [self showBottomViewWithCoor:coor];
}

-(void)addAnnition:(CLLocationCoordinate2D)coor title:(NSString *)title
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.coordinate = coor;
    ann.title  = title;
    [self.mapView addAnnotation:ann];
    
//    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
//    if (title && title.length > 0) {
//        [self.mapView selectAnnotation:ann animated:YES];
//    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap
{
    
    CGPoint point = [theSingleTap locationInView:self.view];
    CLLocationCoordinate2D coor = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    [self showBottomViewWithCoor:coor];
}

-(void)showBottomViewWithCoor:(CLLocationCoordinate2D)coor
{
    [self.bottomView show];
    self.indexView.hidden = YES;
    
    if (geocoder) {
        [geocoder cancelGeocode];
    }
    
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coor.latitude longitude:coor.longitude] completionHandler:^(NSArray* placemarks,NSError *error)
    {
        NSString *mapName;
        if (placemarks.count > 0   )
        {
            CLPlacemark * plmark = [placemarks objectAtIndex:0];
            
            mapName = plmark.name;
            
            LOG(@"1:%@2:%@3:%@4:%@",  plmark.locality, plmark.subLocality,plmark.thoroughfare,plmark.subThoroughfare);
        }
        
        [self.bottomView setAddrText:mapName];
        
        [self addAnnition:CLLocationCoordinate2DMake(coor.latitude, coor.longitude) title:mapName];
        
        geocoder = nil;
    }];

    
    CWHttpCmdMicapspeed *cmd = [CWHttpCmdMicapspeed cmd];
    cmd.lat = [NSString stringWithFormat:@"%f", coor.latitude];
    cmd.lon = [NSString stringWithFormat:@"%f", coor.longitude];
    [cmd setSuccess:^(id object) {
        LOG(@"success");
        
        NSDictionary *formatData = [self formatWindSpeedDatas:object];
        [self.bottomView setupWithData:formatData];
    }];
    [cmd setFail:^(AFHTTPRequestOperation *response) {
        LOG(@"CWHttpCmdWeather is failed");
        
    }];
    
    [cmd startRequest];
}

-(NSDictionary *)formatWindSpeedDatas:(NSDictionary *)data
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHH";
    NSDate *currDate = [formatter dateFromString:[data objectForKey:@"timestamp"]];
    
    NSMutableArray *sortData = [NSMutableArray arrayWithCapacity:data.count-1];
    for (NSString *key in data) {
        if (![key isEqualToString:@"timestamp"]) {
            [sortData addObject:@{key: data[key]}];
        }
    }
    
    NSArray *finalArray = [sortData sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        if ([obj1.allKeys.firstObject integerValue] > [obj2.allKeys.firstObject integerValue]) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSMutableArray *xLabels = [[NSMutableArray alloc] init];
    NSMutableArray *keyPoints = [[NSMutableArray alloc] init];
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    NSMutableArray *yValues = [[NSMutableArray alloc] init];
    
    CGFloat maxWindSpeed = 0;
    for (NSDictionary *d in finalArray) {
        NSString *key = d.allKeys.firstObject;
        if (key) {
            int hours = key.intValue;
            NSDate *date = [currDate dateByAddingHours:hours];
            
            NSString *dateStr = [NSString stringWithFormat:@"%ld月%ld\n%ld时", date.month, date.day, date.hour];
            NSString *windSpeed = [[data objectForKey:key] objectForKey:@"windspeed"];
            
            maxWindSpeed = MAX(maxWindSpeed, windSpeed.floatValue);
            
            [mutableArray addObject:windSpeed];
            [xLabels addObject:xLabels.count%2==0?dateStr:@""];
            
            NSInteger hoursTemp = [NSDate date].hour - date.hour;
            if (hoursTemp < 3 && hoursTemp >= 0) {
                [keyPoints addObject:@(1)];
            }
            else
            {
                [keyPoints addObject:@(0)];
            }
            [xValues addObject:@(xValues.count)];
        }
    }
    
    maxWindSpeed += 10.0;
    maxWindSpeed = MIN(maxWindSpeed, 61.2);
    
    for (int i=0; i<=5; i++) {
        [yValues addObject:[NSString stringWithFormat:@"%.1f", maxWindSpeed/5.0 * i]];
    }
    
    [dict setObject:[NSNumber numberWithFloat:maxWindSpeed] forKey:@"max"];
    [dict setObject:mutableArray forKey:@"data"];
    [dict setObject:xLabels forKey:@"xLabels"];
    [dict setObject:xValues forKey:@"xValues"];
    [dict setObject:@[@"", @"", @""] forKey:@"yLabels"];
    [dict setObject:@[@"0", @"5.5", @"10.8"] forKey:@"yValues"];

    [dict setObject:@[@"0~3级", @"4~5级", @"5级以上"] forKey:@"yOtherLabels"];
    [dict setObject:@[@"2.8", @"8.1", [NSString stringWithFormat:@"%.1f", (maxWindSpeed-10.8)/2.0+10.8]] forKey:@"yOtherValues"];
    
    [dict setObject:keyPoints forKey:@"keyPoints"];
    
    return dict;
}

-(void)clickButtons:(UISegmentedControl *)seg
{
    NSInteger index = seg.selectedSegmentIndex;
    if (self.mainView.particleType != (int)index + 1) {
        self.mainView.particleType = (int)index + 1;
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"windMapIdentifier";
        
        MKAnnotationView *poiAnnotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
        }
        
        if ([(MKPointAnnotation *)annotation title].length == 0) {
            poiAnnotationView.enabled = NO;
            poiAnnotationView.canShowCallout = NO;
        }
        else
        {
            poiAnnotationView.enabled = YES;
            poiAnnotationView.canShowCallout = YES;
        }
        
        poiAnnotationView.selected = YES;
        poiAnnotationView.image = [UIImage imageNamed:@"map_anni"];
        poiAnnotationView.centerOffset = CGPointMake(0, -20);
        //
        //        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        //        [poiAnnotationView addGestureRecognizer:tap];
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.mainView stop];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mainView restart];
    
    if (hadShow) {
        [self.bottomView hide];
    }

}

-(void)willEnterForeground
{
    [self.mainView restart];
}

-(void)didEnterBackground
{
    [self.mainView stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickDelete
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
