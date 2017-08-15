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
#import "SDWebImageDownloader.h"

#import "CWUserManager.h"
#import "MKMapView+ZoomLevel.h"
#import "MyOverlay.h"
#import "MyOverlayImageRenderer.h"

#import "TSTileOverlay.h"
#import "Masonry.h"

@interface CWWindMapController ()<MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL hadShow;
    CLGeocoder *geocoder;
}

@property (nonatomic,strong) NewMapCoverView *mainView;
@property (nonatomic,strong) UISegmentedControl *buttons,*buttons1;
@property (nonatomic,strong) CWWindMapBottomView *bottomView;
@property (nonatomic,strong) UIView *indexView;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic,strong) UIImage *mapImage;
@property (nonatomic,strong) UIButton *lastButton,*nextButton;

@end

@implementation CWWindMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    
    [self initMapView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDInView:self.mapView andText:nil];
//    hud.detailsLabelText = @"稍后您将看到重新绘制的动态风场图！";
//    hud.detailsLabelFont = [UIFont systemFontOfSize:16];
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
    CWHttpCmdMicapsdata *cmd = [CWHttpCmdMicapsdata cmd];
    cmd.vti = @"030";
    cmd.type = @"1000";
    [cmd setSuccess:^(id object) {
        LOG(@"success");
        
        [hud hide:YES];
        
        if (object && [object isKindOfClass:[NSDictionary class]]) {
            [self showMainViewWithData:object partNum:1000];
        }
        
    }];
    [cmd setFail:^(AFHTTPRequestOperation *response) {
        LOG(@"CWHttpCmdWeather is failed");
        
        [hud hide:YES];
        [MBProgressHUD showHUDNoteWithText:@"加载失败,请稍后再试"];
    }];
    
    [cmd startRequest];
    
//    [self initIndexViews];
    
    // 注册
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (self.hideNav) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    UIButton *button = [UIButton new];
    [button setImage:[UIImage imageNamed:@"next_page"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickNextPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    CGFloat navHeight = 0;
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (!self.navigationController.navigationBarHidden) {
        navHeight = self.navigationController.navigationBar.height;
    }
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navHeight+statusHeight).offset(10);
        make.right.mas_equalTo(self.view).offset(-10);
    }];
    [button sizeToFit];
    self.nextButton = button;
    
    UIButton *leftButton = [UIButton new];
    [leftButton setImage:[UIImage imageNamed:@"last_page"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clickLastPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
    if (!self.navigationController.navigationBarHidden) {
        navHeight = self.navigationController.navigationBar.height;
    }
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navHeight+statusHeight).offset(10);
        make.left.mas_equalTo(self.view).offset(10);
    }];
    [leftButton sizeToFit];
    self.lastButton = leftButton;
}

-(void)initIndexViews
{
//    CGFloat lblWidth = 20.0;
//    UIImage *indexImage = [UIImage imageNamed:@"windMapIndex"];
//    CGFloat radio = indexImage.size.width/(self.view.frame.size.width-lblWidth*2);
//    
//    UIView *indexView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-indexImage.size.height/radio, self.view.frame.size.width, indexImage.size.height/radio)];
//    indexView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
//    indexView.backgroundColor = [UIColor colorWithRed:0.035 green:0.059 blue:0.169 alpha:1];
//    [self.view addSubview:indexView];
//    self.indexView = indexView;
//    
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(lblWidth, 0, self.view.frame.size.width-lblWidth*2, indexImage.size.height/radio)];
//    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    iv.image = indexImage;
//    [indexView addSubview:iv];
//
//    UILabel *leftTxt = [self createLabelWithFrame:CGRectMake(0, 0, lblWidth, CGRectGetHeight(indexView.frame))];
//    leftTxt.font = [UIFont boldSystemFontOfSize:16];
//    leftTxt.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
//    leftTxt.text = @"弱";
//    [indexView addSubview:leftTxt];
//    
//    UILabel *rightTxt = [self createLabelWithFrame:CGRectMake(CGRectGetWidth(indexView.frame)-lblWidth, 0, lblWidth, CGRectGetHeight(indexView.frame))];
//    rightTxt.font = [UIFont boldSystemFontOfSize:16];
//    rightTxt.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
//    rightTxt.text = @"强";
//    [indexView addSubview:rightTxt];
    
    UIImage *indexImage = [UIImage imageNamed:@"wind_Legend"];
    UIButton *iv = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width-indexImage.size.width, self.view.height-indexImage.size.height, indexImage.size.width, indexImage.size.height)];
    [iv setImage:indexImage forState:UIControlStateNormal];
    [iv addTarget:self action:@selector(showHideNav) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:iv];
    self.indexView = iv;
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

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat navHeight = 0;
    
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (!self.navigationController.navigationBarHidden) {
        navHeight = self.navigationController.navigationBar.height;
    }
    
    [self.nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(navHeight+statusHeight).offset(10);
    }];
    
    if (self.indexView) {
        [self.indexView removeFromSuperview];
        self.indexView = nil;
    }
    
    [self initIndexViews];
    
    CGFloat min = MIN(MIN(SCREEN_SIZE.width, SCREEN_SIZE.height), self.view.width);
    
    self.bottomView.hidden = YES;
    if (self.bottomView.hidden) {
        self.bottomView.frame = CGRectMake((self.view.width-min)/2, self.view.height, min, 250);
        self.bottomView.initY = self.bottomView.y;
    }
    else
    {
        self.bottomView.frame = CGRectMake((self.view.width-min)/2, self.view.height-250, min, 250);
        self.bottomView.initY = self.bottomView.y;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hadShow = YES;
    });
    
//    static NSString * const template =@"http://api.tiles.mapbox.com/v4/ludawei.mn69agep/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibHVkYXdlaSIsImEiOiJldzV1SVIwIn0.-gaUYss5MkQMyem_IOskdA";
//    
//    TSTileOverlay *overlay = [[TSTileOverlay alloc] initWithURLTemplate:template];
//    overlay.canReplaceMapContent = YES;
//    //    overlay.boundingMapRect = MKMapRectMake(116.460000-8.213470/2, 39.920000+11.198849/2, 8.213470, 11.198849);
//    
//    [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    
//    MyOverlay *over = [[MyOverlay alloc] initWithNorthEast:CLLocationCoordinate2DMake(90, -180) southWest:CLLocationCoordinate2DMake(-90, 180)];
//    [self.mapView addOverlay:over];
}

- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hiden
}

-(void)showMainViewWithData:(NSDictionary *)data partNum:(NSInteger)num
{
    self.mainView = [[NewMapCoverView alloc] initWithFrame:self.view.bounds];
    self.mainView.mapView = self.mapView;
//    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.mainView.particleType = 2;
    self.mainView.partNum = num;
    [self.mainView setupWithData:data];
    self.mainView.userInteractionEnabled = NO;
    
    CWMyMotionStreakView *motionView = [[CWMyMotionStreakView alloc] initWithFrame:self.view.bounds];
    motionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:motionView];
    self.mainView.motionView = motionView;
    [motionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view addSubview:self.mainView];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.view bringSubviewToFront:self.bottomView];
    
    [self setupMapViewAnnitions];
    
//    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[data objectForKey:@"url"]] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//        
//        if (!image) {
//            return ;
//        }
//        
//        self.mapImage = image;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            MyOverlay *over = [[MyOverlay alloc] initWithNorthEast:CLLocationCoordinate2DMake(85.0511, -180) southWest:CLLocationCoordinate2DMake(-85.0511, 180)];
//            [self.mapView addOverlay:over];
//        });
//    }];
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
//    if (!self.mapView) {
//        self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
//    }
//    self.mapView.frame = self.view.bounds;
//    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeHybrid;
//    self.mapView.zoomLevel = 4.0;
    self.mapView.alpha = 0.6;
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
//    CLLocationCoordinate2D coord1 = {
//        39.92,116.46
//    };
//    [self.mapView setCenterCoordinate:coord1 animated:YES];
    //    self.mapView.alpha = 0.5;
    
    
    
//    UISegmentedControl *buttons = [[UISegmentedControl alloc] initWithItems:@[@"箭头", @"流线"]];
//    buttons.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
//    buttons.frame = CGRectMake(CGRectGetWidth(self.view.frame)-112, 74, 100, 32);
//    buttons.tintColor = [UIColor colorWithWhite:1 alpha:1.0];
//    [self.view addSubview:buttons];
//    
//    buttons.selectedSegmentIndex = 1;
//    [buttons addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventValueChanged];
//    self.buttons = buttons;
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithTitle:@"箭头" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton1)];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithTitle:@"流线" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton2)];
    self.navigationItem.rightBarButtonItems = @[btn2, btn1];
}

-(CWWindMapBottomView *)bottomView
{
    if (!_bottomView) {
        CGFloat min = MIN(MIN(SCREEN_SIZE.width, SCREEN_SIZE.height), self.view.width);
        
        _bottomView = [[CWWindMapBottomView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, min, 250)];
//        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
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
    
    NSString *c13 = @"116.3883";//[CWUserManager sharedInstance].lon;
    NSString *c14 = @"39.9289";
    
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([c14 floatValue], [c13 floatValue]);
    
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
    if (!data || data.count == 0) {
        return nil;
    }
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
            
            NSString *dateStr = [NSString stringWithFormat:@"%td月%td\n%td时", date.month, date.day, date.hour];
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

-(void)clickRightButton1
{
    if (self.mainView.particleType != 1) {
        self.mainView.particleType = 1;
    }
}

-(void)clickRightButton2
{
    if (self.mainView.particleType != 2) {
        self.mainView.particleType = 2;
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer = nil;
    if ([overlay isKindOfClass:[MyOverlay class]]) {
        MyOverlayImageRenderer *routineView = [[MyOverlayImageRenderer alloc] initWithOverlay:overlay];
        routineView.image = self.mapImage;//[UIImage imageNamed:@"15061108.006"];
        routineView.alpha = 0.7;
        
        renderer = routineView;
    }
    
    if ([overlay isKindOfClass:[TSTileOverlay class]]) {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        renderer.alpha = 1.0;
        return renderer;
    }
    
    return renderer;
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mainView restart];
    });
    
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

-(void)clickLastPage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeItem" object:nil userInfo:@{@"indexPath": [NSIndexPath indexPathForItem:1 inSection:2]}];
}

-(void)clickNextPage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeItem" object:nil userInfo:@{@"indexPath": [NSIndexPath indexPathForItem:4 inSection:2]}];
}
@end
