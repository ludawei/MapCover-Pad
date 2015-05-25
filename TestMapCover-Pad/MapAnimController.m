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

#import "CWUserManager.h"

#import "MyOverlay.h"
#import "MyOverlayImageRenderer.h"
#import "Masonry.h"

#define MAP_CHINA_CENTER_LAT 33.2f
#define MAP_CHINA_CENTER_LON 105.0f
#define MAP_CHINA_LAT_DELTA 42.0f
#define MAP_CHINA_LON_DELTA 64.0f

#define MK_CHINA_CENTER_REGION MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.2, 105.0), MKCoordinateSpanMake(42, 64))

@interface MapAnimController ()<MKMapViewDelegate>

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) NSDictionary *allImages;
@property (nonatomic,strong) NSArray *allUrls;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) int currentPlayIndex;

@property (nonatomic,strong) MyOverlayImageRenderer *groundOverlayView;

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UISlider *progressView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) MapImagesManager *mapImagesManager;

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
        make.top.mas_equalTo(self.topLayoutGuide);
    }];
    
    self.mapImagesManager = [[MapImagesManager alloc] init];
    
    [self initTopViews];
    [self initBottomViews];
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

- (void)initTopViews
{
    CGFloat height = 50;
    UIView *topView = [[UIView alloc] init];
    [self.backView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.width.mas_equalTo(self.backView);
        make.top.mas_equalTo(64);
        make.height.mas_equalTo(height);
    }];
    
    UIView *backView = [[UIView alloc] init];
    [topView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(topView);
    }];
    
    if (self.type == 0) {
        UIImage *indexImage = [UIImage imageNamed:@"tl_2"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:indexImage];
//        imgView.frame = CGRectMake(topView.width-indexImage.size.width-10, (height-indexImage.size.height)/2.0, indexImage.size.width, indexImage.size.height);
        [topView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(topView.mas_centerY);
            make.size.mas_equalTo(indexImage.size);
        }];
        
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        
        [self showRainInfo:topView];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initMapView];
    
    [self.mapView setRegion:MK_CHINA_CENTER_REGION];
    
    if (self.type == 0) {
        self.mapView.mapType = MKMapTypeStandard;
        
        [self requestImage:MapImageTypeRain];
    }
    else
    {
        self.mapView.mapType = MKMapTypeHybrid;
        
        [self requestImage:MapImageTypeCloud];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self clearMapView];
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
            [self.groundOverlayView setAlpha:0.6];
        }
        
        return self.groundOverlayView;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"pointIdentifier";
        
        MKAnnotationView *poiAnnotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
        }
        
//        poiAnnotationView.canShowCallout = NO;
        poiAnnotationView.image = [UIImage imageNamed:@"map_anni"];
        poiAnnotationView.centerOffset = CGPointMake(0, -20);
        
        return poiAnnotationView;
    }
    
    return nil;
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
                    [weakSlef.mapView removeOverlays:self.mapView.overlays];
                    
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

-(void)startAnimationWithIndex:(int)index
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
        
        if (self.currentPlayIndex == self.allImages.count-1) {
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

-(void)initBottomViews
{
    CGFloat height = 60;
    UIView *bottomView = [[UIView alloc] init];
    [self.backView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.width.mas_equalTo(self.backView);
        make.height.mas_equalTo(height);
    }];
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [bottomView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(bottomView);
    }];
    
    self.playButton = [[UIButton alloc] init];
    self.playButton.backgroundColor = [UIColor colorWithRed:0.153 green:0.525 blue:0.808 alpha:1];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(clickPlay) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(bottomView);
        make.width.mas_equalTo(height);
    }];
    
    self.progressView = [[UISlider alloc] init];
    self.progressView.userInteractionEnabled = NO;
//    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame)+10, 5, bottomView.width-(CGRectGetMaxX(self.playButton.frame)+10) - 60, height-10);
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.minimumValue = 0;
    self.progressView.maximumValue = 90;
    self.progressView.minimumTrackTintColor = [UIColor colorWithRed:0.118 green:0.663 blue:0.988 alpha:1]; // 设置已过进度部分的颜色
    self.progressView.maximumTrackTintColor = [UIColor colorWithRed:0.776 green:0.776 blue:0.800 alpha:1]; // 设置未过进度部分的颜色
    // [oneProgressView setProgress:0.8 animated:YES]; // 设置初始值，可以看到动画效果
//    [self.progressView setProgressViewStyle:UIProgressViewStyleDefault]; // 设置显示的样式
    [self.progressView setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    [bottomView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70);
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(-60);
        make.bottom.mas_equalTo(-5);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:0.118 green:0.663 blue:0.988 alpha:1];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
//    self.timeLabel.text = @"tttttt";
    self.timeLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    [bottomView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-5);
        make.width.mas_equalTo(60);
    }];
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

@end
