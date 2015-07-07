//
//  MapAnimController.m
//  NextRain
//
//  Created by 卢大维 on 14-10-28.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "MapAnimController.h"
#import "PLHttpManager.h"
#import "CWDataManager.h"
#import "MapImagesManager.h"
#import "TSTileOverlay.h"
#import "TSTileOverlayView.h"

#import "CWUserManager.h"

#import "MyOverlay.h"
#import "MyOverlayImageRenderer.h"
#import "Masonry.h"
#import "CustomAnnoView1.h"
#import "MKMapView+ZoomLevel.h"

//#define USE_CUSTOM_MAP 1

#define MAP_CHINA_CENTER_LAT 33.2f
#define MAP_CHINA_CENTER_LON 105.0f
#define MAP_CHINA_LAT_DELTA 42.0f
#define MAP_CHINA_LON_DELTA 64.0f

#define MK_CHINA_CENTER_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.2, 105.0), MKCoordinateSpanMake(42, 64))
#define MAPBOX_URL @"http://api.tiles.mapbox.com/v4/ludawei.mj8ienmm/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibHVkYXdlaSIsImEiOiJldzV1SVIwIn0.-gaUYss5MkQMyem_IOskdA";

@interface MapAnimController ()<MKMapViewDelegate>
{
    BOOL bottomHidden;
}
@property (nonatomic,strong) UIView *backView,*bottomView;

@property (nonatomic,strong) NSDictionary *allImages;
@property (nonatomic,strong) NSArray *allUrls;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) NSInteger currentPlayIndex;

@property (nonatomic,strong) MyOverlayImageRenderer *groundOverlayView;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UISlider *progressView;
@property (nonatomic,strong) UILabel *timeLabel,*dateLbl;;
@property (nonatomic,strong) MapImagesManager *mapImagesManager;

@property (nonatomic,strong) TSTileOverlay *mapTileOverlay;

@end

@implementation MapAnimController

-(void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationController.navigationBar.height+[UIApplication sharedApplication].statusBarFrame.size.height);
    }];
    
    self.mapImagesManager = [[MapImagesManager alloc] init];
    
    [self initBottomViews];
    [self initTopViews];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换地图" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightnavButton)];
}

-(void)clickRightnavButton
{
    if (self.mapTileOverlay) {
        [self.mapView removeOverlay:self.mapTileOverlay];
        self.mapTileOverlay = nil;
    }
    else
    {
        static NSString * const template = MAPBOX_URL;
        
        TSTileOverlay *overlay = [[TSTileOverlay alloc] initWithURLTemplate:template];
        overlay.canReplaceMapContent = YES;
        //    overlay.boundingMapRect = MKMapRectMake(116.460000-8.213470/2, 39.920000+11.198849/2, 8.213470, 11.198849);
        self.mapTileOverlay = overlay;
        
        [self.mapView insertOverlay:overlay atIndex:0];
    }
}

-(void)initMapView
{
//    [self.mapView removeFromSuperview];
//    
    self.mapView.delegate = self;
    [self.backView addSubview:self.mapView];
    [self.backView sendSubviewToBack:self.mapView];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.backView);
    }];
    
    if ([CWUserManager sharedInstance].lat && [CWUserManager sharedInstance].lon) {
        self.coor = CLLocationCoordinate2DMake([[CWUserManager sharedInstance].lat doubleValue], [[CWUserManager sharedInstance].lon doubleValue]);
    }
    
    self.mapView.centerCoordinate = self.coor;
    
    if (CLLocationCoordinate2DIsValid(self.coor)) {
        MKPointAnnotation *startAnnotation = [[MKPointAnnotation alloc] init];
        startAnnotation.coordinate = self.coor;
//        startAnnotation.title      = [CWDataManager sharedInstance]
        //    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startPoint.latitude, self.startPoint.longitude];
        [self.mapView addAnnotation:startAnnotation];
    }
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
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView);
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.width.mas_equalTo(self.backView).multipliedBy(multi);
        make.height.mas_equalTo(75);
    }];
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

-(void)showHideBottomView
{
    CGFloat offset = self.bottomView.height;
    if (bottomHidden) {
        offset = 0;
    }
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.backView).offset(offset);
    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        bottomHidden = !bottomHidden;
    }];
}

- (void)initTopViews
{
//    UIButton *logo = [UIButton new];
//    [self.backView addSubview:logo];
//    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.mas_equalTo(self.backView);
//    }];
//    [logo setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
//    [logo addTarget:self action:@selector(showHideNav) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *indexImage = [UIImage imageNamed:@"Legend"];
    CGFloat height = indexImage.size.height;
    UIView *topView = [[UIView alloc] init];
    [self.backView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.and.width.mas_equalTo(self.backView);
        make.height.mas_equalTo(height);
    }];
    
    UIView *backView = [[UIView alloc] init];
    [topView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(topView);
    }];
    
    if (self.type == 0) {
        
        UIButton *imgView = [UIButton new];//[[UIImageView alloc] initWithImage:indexImage];
        [self.backView addSubview:imgView];
        
        [imgView setImage:indexImage forState:UIControlStateNormal];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.centerY.mas_equalTo(topView.mas_centerY);
            make.size.mas_equalTo(indexImage.size);
        }];
        
        [imgView addTarget:self action:@selector(showHideNav) forControlEvents:UIControlEventTouchUpInside];
        
//        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
//        [self showRainInfo:topView];
    }
}

-(void)showRainInfo:(UIView *)topView
{
    NSString *c13 = @"116.3883";//[CWUserManager sharedInstance].lon;
    NSString *c14 = @"39.9289";//[CWUserManager sharedInstance].lat;
    [[PLHttpManager sharedInstance].manager GET:[NSString stringWithFormat:@"http://caiyunapp.com/fcgi-bin/v1/api.py?lonlat=%@,%@&format=json&product=minutes_prec&token=Q2hpbmVzZSBXZWF0aGVyTWFuICsgY2FpeXVuIHdlYXRoZXIgYXBp", c13, c14] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error = nil;
        id json;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            json = responseObject;
        }
        else
        {
            json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        }
        
        if (error)
        {
            NSLog(@"Error: %@",error);
        }
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            NSString *msg = [json objectForKey:@"summary"];
            
            msg = [msg stringByReplacingOccurrencesOfString:@"小彩云" withString:@""];
            
            if (msg) {
                UIFont *font = [UIFont fontWithName:@"Helvetica" size:16];
                
                CGSize textSize = [msg sizeWithAttributes:@{NSFontAttributeName:font}];
                UIView *msgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), topView.width, textSize.height)];
                msgBackView.clipsToBounds = YES;
                [self.backView addSubview:msgBackView];
//                [msgBackView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.top.mas_equalTo(topView.mas_bottom);
//                    make.left.mas_equalTo(0);
//                    make.width.mas_equalTo(topView);
//                    make.height.mas_equalTo(textSize.height);
//                }];
                
                UILabel *rainFullMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(msgBackView.bounds.size.width, 0, MAX(textSize.width, msgBackView.bounds.size.width), textSize.height)];
                rainFullMsgLabel.textColor = [UIColor blackColor];
                rainFullMsgLabel.font = font;
                rainFullMsgLabel.text = msg;
                rainFullMsgLabel.textAlignment = NSTextAlignmentCenter;
                [msgBackView addSubview:rainFullMsgLabel];
                
                if (textSize.width > msgBackView.bounds.size.width) {
                    [UIView beginAnimations:@"testAnimation" context:NULL];
                    [UIView setAnimationDuration:textSize.width/45];
                    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                    [UIView setAnimationRepeatAutoreverses:NO];
                    [UIView setAnimationRepeatCount:INT_MAX];
                    CGRect frame = rainFullMsgLabel.frame;
                    frame.origin.x = -(rainFullMsgLabel.bounds.size.width);
                    rainFullMsgLabel.frame = frame;
//                    [msgBackView mas_updateConstraints:^(MASConstraintMaker *make) {
//                        make.left.mas_equalTo(0);
//                    }];
                    [UIView commitAnimations];
                }
                else
                {
                    rainFullMsgLabel.frame = CGRectMake(0, 0, MAX(textSize.width, msgBackView.bounds.size.width), textSize.height);
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&error];
        NSLog(@"%@", error);
    }];
}

- (void)clearMapView
{
    self.groundOverlayView = nil;
    
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

-(void)removeMapOverlayWithoutTileOverlay
{
    for (id overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[MKTileOverlay class]]) {
            continue;
        }
        
        [self.mapView removeOverlay:overlay];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initMapView];
    
    [self.mapView setRegion:MK_CHINA_CENTER_REGION];
    
    if (self.type == 0) {
        self.mapView.mapType = MKMapTypeHybrid;
        
#ifdef USE_CUSTOM_MAP
        static NSString * const template = MAPBOX_URL;
        
        TSTileOverlay *overlay = [[TSTileOverlay alloc] initWithURLTemplate:template];
        overlay.canReplaceMapContent = YES;
        //    overlay.boundingMapRect = MKMapRectMake(116.460000-8.213470/2, 39.920000+11.198849/2, 8.213470, 11.198849);
        self.mapTileOverlay = overlay;
        
        [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
#endif
        
        [self requestImage:MapImageTypeRain];
    }
    else
    {
        self.mapView.mapType = MKMapTypeHybrid;
        
        [self requestImage:MapImageTypeCloud];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)addAnnotations
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"china_cities" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];

    NSArray *datas = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSMutableArray *annos = [NSMutableArray arrayWithCapacity:datas.count];
    
    NSInteger level = 1;
    if (self.mapView.zoomLevel >= 3.5) {
        level = 2;
    }
    
    if (self.mapView.zoomLevel >= 4.1) {
        level = 3;
    }
    
    if (self.mapView.zoomLevel >= 5.0)
    {
        level = 4;
    }
    
    if (self.mapView.zoomLevel >= 6.0)
    {
        level = 5;
    }
    
    for (NSInteger i=0; i<datas.count; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        
        MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
        anno.coordinate = CLLocationCoordinate2DMake([[dict[@"cp"] lastObject] floatValue], [[dict[@"cp"] firstObject] floatValue]);
        anno.title      = dict[@"name"];
        if ([dict[@"level"] integerValue] <= level) {
            [annos addObject:anno];
        }
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annos];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self clearMapView];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MAMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MyOverlay class]])
    {
        self.groundOverlayView = [[MyOverlayImageRenderer alloc] initWithOverlay:overlay];
        if (self.mapView.mapType == MKMapTypeHybrid) {
            [self.groundOverlayView setAlpha:1.0];
        }
        else
        {
            [self.groundOverlayView setAlpha:1.0];
        }
        
        return self.groundOverlayView;
    }
    
    if ([overlay isKindOfClass:[TSTileOverlay class]]) {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        renderer.alpha = 1.0;
        return renderer;
    }
    
    return nil;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"pointIdentifier";
        
        CustomAnnoView1 *poiAnnotationView = (CustomAnnoView1*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (!poiAnnotationView)
        {
            poiAnnotationView = [[CustomAnnoView1 alloc] initWithAnnotation:annotation
                                                                 reuseIdentifier:navigationCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = NO;
#if 1
        if ([poiAnnotationView isKindOfClass:[CustomAnnoView1 class]]) {
            
            [poiAnnotationView setLabelText:[annotation title] withTextSize:16];
        }
#else
        poiAnnotationView.image = [UIImage imageNamed:@"tongji"];
#endif
        
        return poiAnnotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"%f", mapView.zoomLevel);
#ifdef USE_CUSTOM_MAP
    if (self.type == 0) {
        [self addAnnotations];
    }
#endif
}

#pragma mark -- self methods
-(void)clickBack
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.mapImagesManager = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestImage:(enum MapImageType)type
{
    [self.mapImagesManager requestImageList:type completed:^(enum MapImageDownloadType downloadType) {
        
        NSArray *imageUrls = nil;
        
        if (type == MapImageTypeRain) {
            imageUrls = [[CWDataManager sharedInstance].mapRainData objectForKey:@"list"];
        }
        else if (type == MapImageTypeCloud)
        {
            imageUrls = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"list"];
        }
        self.allUrls = imageUrls;
        NSString *url = [self.allUrls.firstObject objectForKey:@"l2"];
        
        __weak typeof(self) weakSlef = self;
        [self.mapImagesManager downloadImageWithUrl:url type:type region:MK_CHINA_CENTER_REGION completed:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (image) {
//                    [weakSlef.mapView removeOverlays:self.mapView.overlays];
                    [weakSlef removeMapOverlayWithoutTileOverlay];
                    
                    MyOverlay *groundOverlay = [[MyOverlay alloc] initWithRegion:MK_CHINA_CENTER_REGION];
                    
                    if (type == MapImageTypeRain) {
                        NSArray *locPoints = [weakSlef.allUrls.firstObject objectForKey:@"l3"];
                        NSString *p1 = [NSString stringWithFormat:@"%@", locPoints.firstObject];
                        NSString *p2 = [NSString stringWithFormat:@"%@", locPoints[1]];
                        NSString *p3 = [NSString stringWithFormat:@"%@", locPoints[2]];
                        NSString *p4 = [NSString stringWithFormat:@"%@", locPoints.lastObject];
                        
                        groundOverlay = [[MyOverlay alloc] initWithNorthEast:CLLocationCoordinate2DMake([p3 doubleValue], [p2 doubleValue]) southWest:CLLocationCoordinate2DMake([p1 doubleValue], [p4 doubleValue])];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSlef.mapView addOverlay:groundOverlay];
                        
                        [weakSlef changeImageAnim:image];
                    });
                }
            });
        }];
    }];
}

-(void)requestImageList:(enum MapImageType)type
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.mapImagesManager.hudView = self.mapView;
    [self.mapImagesManager requestImageList:type completed:^(enum MapImageDownloadType downloadType) {
        if (downloadType == MapImageDownloadTypeFail) {
            LOG(@"加载失败");
        }
        else
        {
            __weak typeof(self) weakSlef = self;
            [self.mapImagesManager downloadAllImageWithType:type region:MK_CHINA_CENTER_REGION completed:^(NSDictionary *images) {
                
                if (images) {
                    // 开始动画
                    weakSlef.allImages = images;
                    NSArray *imageUrls = nil;
                    if (type == MapImageTypeRain) {
                        imageUrls = [[CWDataManager sharedInstance].mapRainData objectForKey:@"list"];
                    }
                    else if (type == MapImageTypeCloud)
                    {
                        imageUrls = [[CWDataManager sharedInstance].mapCloudData objectForKey:@"list"];
                    }
                    weakSlef.allUrls = imageUrls;
                    [weakSlef startAnimationWithIndex:weakSlef.currentPlayIndex];
                }
                
            } loadType:downloadType];
        }
    }];
}

-(void)startAnimationWithIndex:(NSInteger)index
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(timeDidFired) userInfo:nil repeats:YES];
        self.currentPlayIndex = index;
        if (index >= self.allImages.count-1) {
            self.currentPlayIndex = 0;
        }
        self.playButton.selected = YES;
        
        [self timeDidFired];
    });
}

-(void)timeDidFired
{
    @autoreleasepool {
        NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
        UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
        if (curImage) {
            [self changeImageAnim:curImage];
        } 
        else
        {
            LOG(@"Image file 不存在~~%@", imageUrl);
        }
        
        self.currentPlayIndex++;
        
        if (self.currentPlayIndex > self.allImages.count-1) {
            [self.timer invalidate];
            [self repeatAnimation];
        }
    }
}

-(void)repeatAnimation
{
//    @autoreleasepool {
//        NSString *imageUrl = [self.allImages objectForKey:@(self.currentPlayIndex)];
//         UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
//        [self changeImageAnim:curImage];
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self startAnimationWithIndex:0];
        }
    });
}

-(void)changeImageAnim:(UIImage *)image
{
    @autoreleasepool{
        
        self.groundOverlayView.image = image;
        [self.groundOverlayView setNeedsDisplay];
        
        NSString *timeTxt = [[self.allUrls objectAtIndex:self.allUrls.count-self.currentPlayIndex-1] objectForKey:@"l1"];
        [self setTimeLabelText:timeTxt];
        [self setDateLabelText:timeTxt];
        
        //    LOG(@"%d, %ld", self.currentPlayIndex, self.allImages.count);
//        self.progressView.progress = 1.0*(self.currentPlayIndex+1)/self.allImages.count;
        CGFloat radio = 100.0*(self.currentPlayIndex)/self.allImages.count;
        self.progressView.value = radio;
    }
}

-(void)setTimeLabelText:(NSString *)text
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (self.type == 0)
    {
        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:[text integerValue]];
        [dateFormatter setDateFormat:@"HH:mm"];
        self.timeLabel.text = [dateFormatter stringFromDate:expirationDate];
    }
    else
    {
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate* expirationDate = [dateFormatter dateFromString: text];
        [dateFormatter setDateFormat:@"HH:mm"];
        self.timeLabel.text = [dateFormatter stringFromDate:expirationDate];
    }
    dateFormatter = nil;
}

-(void)setDateLabelText:(NSString *)text
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (self.type == 0)
    {
        NSDate* expirationDate = [NSDate dateWithTimeIntervalSince1970:[text integerValue]];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        self.dateLbl.text = [dateFormatter stringFromDate:expirationDate];
    }
    else
    {
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate* expirationDate = [dateFormatter dateFromString: text];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        self.dateLbl.text = [dateFormatter stringFromDate:expirationDate];
    }
    dateFormatter = nil;
}

-(void)tap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeItem" object:nil userInfo:@{@"indexPath": [NSIndexPath indexPathForItem:3 inSection:2]}];
}

-(void)initBottomViews
{
    CGFloat height = 75;
    UIView *bottomView = [[UIView alloc] init];
    [self.backView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView);
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.width.mas_equalTo(self.backView).multipliedBy(0.7);
        make.height.mas_equalTo(height);
    }];
    
    self.bottomView = bottomView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [bottomView addGestureRecognizer:tap];
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.3];
    [bottomView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(bottomView);
    }];
    
    UILabel *titleLbl = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:30]];
    titleLbl.textColor = UIColorFromRGB(0x929292);
    titleLbl.text = @"全国雷达拼图";
    [bottomView addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomView);
        make.centerX.mas_equalTo(bottomView.mas_centerX);
    }];
    
    UILabel *dateLbl = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica" size:18]];
    dateLbl.textColor = UIColorFromRGB(0xa2a2a0);
    dateLbl.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:dateLbl];
    [dateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomView).offset(10);
        make.left.mas_equalTo(titleLbl.mas_right).offset(5);
        make.right.mas_equalTo(-5);
    }];
    
    self.dateLbl = dateLbl;
    
    self.timeLabel = [self createLabelWithFont:[UIFont fontWithName:@"Helvetica" size:18]];
    self.timeLabel.textColor = UIColorFromRGB(0xa2a2a0);
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(dateLbl.mas_bottom);
        make.left.mas_equalTo(titleLbl.mas_right).offset(5);
        make.right.mas_equalTo(-5);
    }];

    
    UIView *bView = [UIView new];
    bView.backgroundColor = [UIColor colorWithRed:45/255.0 green:40/255.0 blue:16/255.0 alpha:0.1];
    [bottomView addSubview:bView];
    [bView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLbl.mas_bottom);
        make.bottom.mas_equalTo(bottomView.mas_bottom);
        make.left.and.right.mas_equalTo(bottomView);
    }];
    
    CGFloat buttonWidth = 40;
    UIButton *nextButton = [[UIButton alloc] init];
    [nextButton setImage:[UIImage imageNamed:@"Future"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(clickNext) forControlEvents:UIControlEventTouchUpInside];
    [bView addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.and.bottom.mas_equalTo(bView);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    self.playButton = [[UIButton alloc] init];
    [self.playButton setImage:[UIImage imageNamed:@"Broadcast"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside];
    [bView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(nextButton.mas_left);
        make.top.and.bottom.mas_equalTo(bView);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    UIButton *lastButton = [[UIButton alloc] init];
    [lastButton setImage:[UIImage imageNamed:@"Past"] forState:UIControlStateNormal];
    [lastButton addTarget:self action:@selector(clickLast) forControlEvents:UIControlEventTouchUpInside];
    [bView addSubview:lastButton];
    [lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.playButton.mas_left);
        make.top.and.bottom.mas_equalTo(bView);
        make.width.mas_equalTo(buttonWidth);
    }];
    
    self.progressView = [[UISlider alloc] init];
    self.progressView.userInteractionEnabled = YES;
//    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+10, 5, bottomView.width-(CGRectGetMaxX(self.playButton.frame)+10) - 60, height-10);
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.minimumValue = 0;
    self.progressView.maximumValue = 95;
    self.progressView.minimumTrackTintColor = UIColorFromRGB(0x2593c8); // 设置已过进度部分的颜色
    self.progressView.maximumTrackTintColor = UIColorFromRGB(0xa8a8a8); // 设置未过进度部分的颜色
    // [oneProgressView setProgress:0.8 animated:YES]; // 设置初始值，可以看到动画效果
//    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault]; // 设置显示的样式
    [self.progressView setThumbImage:[UIImage imageNamed:@"Slider"] forState:UIControlStateNormal];
    [self.progressView addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    [bView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(lastButton.mas_left);
        make.bottom.mas_equalTo(-5);
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

-(void)changeProgress:(id)sender
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.currentPlayIndex = self.progressView.value*(self.allImages.count)/self.progressView.maximumValue;
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    if (curImage) {
        [self changeImageAnim:curImage];
    }
    else
    {
        LOG(@"Image file 不存在~~%@", imageUrl);
    }
}

-(void)clickPlay
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    else
    {
        if (self.type == 0) {
            [self requestImageList:MapImageTypeRain];
        }
        else
        {
            [self requestImageList:MapImageTypeCloud];
        }
    }
}

-(void)clickLast
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.currentPlayIndex = MAX(0, self.currentPlayIndex - 1);
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    if (curImage) {
        [self changeImageAnim:curImage];
    }
    else
    {
        LOG(@"Image file 不存在~~%@", imageUrl);
    }
}

-(void)clickNext
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        self.playButton.selected = NO;
    }
    
    self.currentPlayIndex = MIN(self.allImages.count-1, self.currentPlayIndex + 1);
    NSString *imageUrl = [self.allImages objectForKey:@(self.allImages.count-self.currentPlayIndex-1)];
    UIImage *curImage = [self.mapImagesManager imageFromDiskForUrl:imageUrl];
    if (curImage) {
        [self changeImageAnim:curImage];
    }
    else
    {
        LOG(@"Image file 不存在~~%@", imageUrl);
    }
}

@end
