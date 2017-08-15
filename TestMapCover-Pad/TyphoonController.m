//
//  NewTyphoonController.m
//  chinaweathernews
//
//  Created by 卢大维 on 16/4/15.
//  Copyright © 2016年 weather. All rights reserved.
//

#import "TyphoonController.h"
#import <MapKit/MapKit.h>
#import "PLHttpManager.h"
#import "NSDate+Utilities.h"
#import "MBProgressHUD+Extra.h"
#import "MyAnnotation.h"
#import "Util.h"
#import "CWDataManager.h"

#define MAP_PADDING 1.1
#define MINIMUM_VISIBLE_LATITUDE 0.01

#define stringValue(v) [self stringValueFromJson:v]

@interface TyphoonController ()<MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) MKMapView *mapView;
@property (nonatomic,strong) UILabel *titleLbl;
@property (nonatomic,strong) UIView *selectView;
@property (nonatomic,strong) UITableView *tableView1,*tableView2;
@property (nonatomic,strong) UIView *indexView;
@property (nonatomic,strong) UIButton *indexButton, *playBackButton;

@property (nonatomic,strong) dispatch_queue_t requestQueue;
@property (nonatomic,strong) AFHTTPSessionManager *httpManager;

@property (nonatomic,strong) NSMutableArray *yearList;
@property (nonatomic,strong) NSMutableDictionary *listDicts;
@property (nonatomic,strong) NSMutableArray *currTyphoons;
@property (nonatomic,strong) NSMutableDictionary *currTyphoonInfos;

@property (nonatomic,strong)NSMutableArray *overlayArrs;

@property (nonatomic,copy) NSArray *preStartPoint;
@property (nonatomic,copy) NSArray *prePoints;

@property (nonatomic,assign) NSInteger selectYear;
@property (nonatomic,strong) UIActivityIndicatorView *actView;

@property(nonatomic,strong)NSTimer *playTimer;
@property (nonatomic,assign) NSInteger playIndex;
@property (nonatomic,assign) BOOL isPlayBack;
@property(nonatomic,strong)UIImageView *ivHeader;

@end

@implementation TyphoonController

-(void)dealloc{
    [self stopHeaderAnnotation];
    [self.playTimer invalidate];
    self.playTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"台风路径";
    
    self.requestQueue = dispatch_queue_create("com.weather.hainan.typhoon", DISPATCH_QUEUE_SERIAL);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.httpManager = [[AFHTTPSessionManager alloc] init];
    self.httpManager.responseSerializer = [AFXMLParserResponseSerializer new];
    
    self.yearList = [NSMutableArray arrayWithCapacity:3];
    self.listDicts = [NSMutableDictionary dictionaryWithCapacity:3];
    self.overlayArrs = [NSMutableArray arrayWithCapacity:4];
    
    self.currTyphoons = [NSMutableArray array];
    self.currTyphoonInfos = [NSMutableDictionary dictionary];
    
    for (NSInteger i=[NSDate date].year; i>=2010; i--) {
        [self.yearList addObject:[NSString stringWithFormat:@"%td", i]];
    }
    
    [self initMapView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.height, self.view.width, 30)];
    titleLbl.backgroundColor = [UIColorFromRGB(0xdddddd) colorWithAlphaComponent:0.7];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor blackColor];
    [self.view addSubview:titleLbl];
    self.titleLbl = titleLbl;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.height - 60, 40, 40)];
    [button setTintColor:[UIColor purpleColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"legend"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickIndexButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.indexButton = button;
    
//    UIButton *playBackButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 60, self.view.height - 60, 40, 40)];
//    playBackButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
//    [playBackButton setTintColor:[UIColor purpleColor]];
//    [playBackButton setTitle:@"回放" forState:UIControlStateNormal];
//    [playBackButton addTarget:self action:@selector(playBack) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:playBackButton];
//    self.playBackButton = button;
    
    [self initIndexView];
    [self initSelectView];
    
    [MBProgressHUD showHUDInView:self.view andText:@"正在请求数据..."];
    [self requestTyphoonListWithYear:[self.yearList.firstObject integerValue]];
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"liebiao"] style:UIBarButtonItemStyleDone target:self action:@selector(clickRightNav)];
    self.navigationItem.rightBarButtonItem = barItem;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)initSelectView
{
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height*0.7, self.view.width, self.view.height*0.3)];
    selectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:selectView];
    self.selectView = selectView;
    self.selectView.alpha = 0;
    
    self.tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 80, selectView.height)];
    self.tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView1.dataSource = self;
    self.tableView1.delegate = self;
    self.tableView1.rowHeight = 30;
    [self.tableView1 selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [selectView addSubview:self.tableView1];
    
    self.tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.tableView1.frame), 0, selectView.width-CGRectGetMaxX(self.tableView1.frame), selectView.height)];
    self.tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView2.dataSource = self;
    self.tableView2.delegate = self;
    self.tableView2.rowHeight = 30;
    [selectView addSubview:self.tableView2];
    
    self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.actView.center = CGPointMake(self.tableView2.width/2, self.tableView2.height/2);
    [self.tableView2 addSubview:self.actView];
    self.actView.hidden = YES;
}

-(void)clickLeftNav
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)willEnterForeground
{
    [self startHeaderAnnotation];
}

-(void)didEnterBackground
{
    //    [self stopTimer];
}

-(void)requestTyphoonListWithYear:(NSInteger)year
{
    NSString *listUrl = [NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/typhoon?year=list_%td&test=ncg",year];
    dispatch_async(self.requestQueue, ^{
        NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:listUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDInView:self.view];
            if (!self.actView.hidden) {
                [self.actView stopAnimating];
                self.actView.hidden = YES;
            }
            
            if (dt.length > 0) {
                
                NSString *str = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
                NSString *result = [self jsonStringFromJsonpString:str];
                if (result) {
                    // 截获特定的字符串
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    
                    LOG(@"%@", json);
                    NSMutableDictionary *dictObj = [NSMutableDictionary dictionaryWithDictionary:json];
                    id typhoonList = [dictObj objectForKey:@"typhoonList"];
                    if ([typhoonList isKindOfClass:[NSDictionary class]]) {
                        [dictObj setObject:@[typhoonList] forKey:@"typhoonList"];
                    }
                    
                    for (NSInteger i=[typhoonList count]-1; i>=0; i--) {
                        NSArray *typhoon = [typhoonList objectAtIndex:i];
                        
                        if (![[typhoon lastObject] isEqualToString:@"stop"])
                        {
                            [self.currTyphoons addObject:typhoon];
                            [self requestTyphoonDetailWithItem:typhoon];
                        }
                        
                    }
                    
                    [self.listDicts setObject:[dictObj objectForKey:@"typhoonList"] forKey:[NSString stringWithFormat:@"%td", year]];
                    
                    if (self.currTyphoons.count > 1) {
                        self.titleLbl.text = [NSString stringWithFormat:@"%td个台风", self.currTyphoons.count];
                    }
                    else
                    {
                        self.titleLbl.text = [self titleFromItem:[self.currTyphoons lastObject]];
                    }
                    
                    [self.tableView2 reloadData];
                }
                else
                {
                    // 如果有错误，则把错误打印出来
                    
                }
            }
            else
            {
                self.titleLbl.text = [self titleFromItem:nil];
            }
        });
    });
}

-(void)requestTyphoonDetailWithItem:(NSArray *)item
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    NSString *typhNo = [item firstObject];
    
    [MBProgressHUD showLoadingHUDAddedTo:self.view];
    
    NSString *detailUrl = [NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/typhoon?view=view_%@&test=ncg", typhNo];
    dispatch_async(self.requestQueue, ^{
        NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:detailUrl]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDInView:self.view];
            if (dt.length > 0) {
                NSString *str = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
                NSString *result = [self jsonStringFromJsonpString:str];
                if (result) {
                    // 截获特定的字符串
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    NSArray *typhoon = [json objectForKey:@"typhoon"];
                    
                    [self.tableView2 reloadData];
                    
                    // load ui
                    [self parseTyphoonDetail:typhoon];
                    [self showTyphoonDetail:typhoon];
                }
            }
        });
    });
}

-(void)initMapView
{
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

-(void )initIndexView
{
    CGSize cellSize = CGSizeMake((self.view.width - 20)/3.0, 35);
    
    NSArray *arr = @[@{@"name":@"热带低压", @"imgName":@"typhoon_level_1"},
                     @{@"name":@"热带风暴", @"imgName":@"typhoon_level_2"},
                     @{@"name":@"强热带风暴", @"imgName":@"typhoon_level_3"},
                     @{@"name":@"台风", @"imgName":@"typhoon_level_4"},
                     @{@"name":@"强台风", @"imgName":@"typhoon_level_5"},
                     @{@"name":@"超强台风", @"imgName":@"typhoon_level_6"},
                     @{@"name":@"7级风圈", @"circColor":[UIColor redColor]},
                     @{@"name":@"10级风圈", @"circColor":[UIColor yellowColor]},
                     @{@"name":@"受影响区域", @"imgName":@"green_rect"},];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, view.height-125, view.width, 125)];
    centerView.backgroundColor = [UIColor whiteColor];
    [view addSubview:centerView];
    
    for (NSInteger i=0; i<arr.count; i++) {
        NSInteger col = i%3;
        NSInteger row = i/3;
        
        NSDictionary *dict = [arr objectAtIndex:i];
        
        NSString *imageName = [dict objectForKey:@"imgName"];
        UIColor *color = [dict objectForKey:@"circColor"];
        
        UIView *conView = [[UIView alloc] initWithFrame:CGRectMake(10 + col*cellSize.width, 10 + cellSize.height*row, cellSize.width, cellSize.height)];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 15, 15)];
        iv.layer.cornerRadius = 7.5;
        iv.layer.masksToBounds = YES;
        if (imageName) {
            iv.image = [UIImage imageNamed:imageName];
        }else{
            iv.layer.borderColor = color.CGColor;
            iv.layer.borderWidth = 3;
        }
        [conView addSubview:iv];
        
        UILabel *lbt = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iv.frame)+10, 0, cellSize.width-(CGRectGetMaxX(iv.frame)+10), cellSize.height)];
        lbt.text = [dict objectForKey:@"name"];
        lbt.font = [UIFont systemFontOfSize:14];
        lbt.adjustsFontSizeToFitWidth = YES;
        lbt.minimumScaleFactor = 0.5;
        [conView addSubview:lbt];
        
        [centerView addSubview:conView];
    }
    
    view.y = self.view.height;
    view.hidden = YES;
    [self.view addSubview:view];
    self.indexView = view;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickIndexButton)];
    [view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)titleFromItem:(NSArray *)item
{
    if (item) {
        NSString *title = [self stringValueFromJson:[item objectAtIndex:1]];
        NSString *nameCN = [self stringValueFromJson:[item objectAtIndex:2]];
        if (nameCN.length > 0) {
            title = nameCN;
        }
        NSString *typhNo = [self stringValueFromJson:[item objectAtIndex:3]];
        if (typhNo.length > 0) {
            
            title = [NSString stringWithFormat:@"%@ %@", typhNo, title];
        }
        
        return title;
    }
    
    return @"当前无台风";
}

-(void)addWindCircle:(MyAnnotation *)poit{
    if (poit.warnId.length > 0 && ![poit.warnId isEqualToString:@"999999"]) {
        int radi10 = poit.warnId.intValue * 1000;
        CLLocationCoordinate2D coenter = poit.coordinate;
        MKCircle *cirl = [MKCircle circleWithCenterCoordinate:coenter radius:radi10];
        cirl.title = @"EN10Radii";
        [self.overlayArrs addObject:cirl];
        [self.mapView addOverlay:cirl];
    }
    if (poit.warnUrl.length > 0 && ![poit.warnUrl isEqualToString:@"999999"]) {
        int radi7 = poit.warnUrl.intValue * 1000;
        CLLocationCoordinate2D coenter = poit.coordinate;
        MKCircle *cirl = [MKCircle circleWithCenterCoordinate:coenter radius:radi7];
        cirl.title = @"EN7Radii";
        [self.overlayArrs addObject:cirl];
        [self.mapView addOverlay:cirl];
    }
}

-(void)parseTyphoonDetail:(NSArray *)info
{
    self.preStartPoint = nil;
    self.prePoints = nil;
    
    NSArray *trPath = [info objectAtIndex:8];
    if (trPath.count == 0) {
        return;
    }
    
    NSArray *p1 = [trPath firstObject];
    float minLon,minLat,maxLon,maxLat;
    minLon = [[p1 objectAtIndex:4] floatValue];
    minLat = [[p1 objectAtIndex:5] floatValue];
    maxLon = [[p1 objectAtIndex:4] floatValue];
    maxLat = [[p1 objectAtIndex:5] floatValue];
    
    NSMutableArray *annos = [NSMutableArray array];
    NSMutableArray *polylines = [NSMutableArray array];
    for (NSInteger i=0; i<trPath.count; i++) {
        NSArray *pdetail = [trPath objectAtIndex:i];
        
        MyAnnotation *anno = [[MyAnnotation alloc] init];
        anno.pointType = @"true";
        anno.coordinate = CLLocationCoordinate2DMake([[pdetail objectAtIndex:5] floatValue], [[pdetail objectAtIndex:4] floatValue]);
        anno.imageTag   = [NSString stringWithFormat:@"typhoon_level_%@", [self tyhpLevelInfo:pdetail[3]]];
        anno.title      = [self titleFromItem:info];
        anno.isHeader   = NO;
        anno.typhoonInfo = pdetail;
        NSArray *wRadiiPoints = pdetail[10];
        if (wRadiiPoints && ![wRadiiPoints isKindOfClass:[NSNull class]])
        {
            for (NSInteger i=0; i<wRadiiPoints.count; i++) {
                NSArray *prep = [wRadiiPoints objectAtIndex:i];
                if (i == 0) {
                    anno.warnId = stringValue(prep[1]);
                }
                
                if (i == 1) {
                    anno.warnUrl = stringValue(prep[1]);
                }
            }
        }
        
        if (CLLocationCoordinate2DIsValid(anno.coordinate)) {
            
            if (anno.coordinate.longitude == 180) {
                anno.coordinate = CLLocationCoordinate2DMake(anno.coordinate.latitude, -180);
            }
            [annos addObject:anno];
        }
        
        if (i > 0) {
            NSArray *prep = trPath[i-1];
            
            MKPolyline* polyline = [self polylineWithLat1:pdetail[5] lon1:pdetail[4] lat2:prep[5] lon2:prep[4]];
            [polylines addObject:polyline];
        }
        
        minLon = MIN([[pdetail objectAtIndex:4] floatValue], minLon);
        minLat = MIN([[pdetail objectAtIndex:5] floatValue], minLat);
        maxLon = MAX([[pdetail objectAtIndex:4] floatValue], maxLon);
        maxLat = MAX([[pdetail objectAtIndex:5] floatValue], maxLat);
        
        NSDictionary *pdetail11 = pdetail[11];
        if (pdetail11 && ![pdetail11 isKindOfClass:[NSNull class]]) {
            self.preStartPoint = pdetail;
            self.prePoints = [pdetail11 objectForKey:@"BABJ"];
        }
    }
    
    MyAnnotation *lastAnno = [annos lastObject];
    lastAnno.isHeader = YES;
    
    NSMutableArray *preAnnos = [NSMutableArray array];
    NSMutableArray *prePolylines = [NSMutableArray array];
    
    NSArray *prePathPoint = self.prePoints;
    for (NSInteger i=0; i<prePathPoint.count; i++)
    {
        NSArray *pre = [prePathPoint objectAtIndex:i];
        
        MyAnnotation *anno = [[MyAnnotation alloc] init];
        anno.pointType = @"pre";
        anno.coordinate = CLLocationCoordinate2DMake([stringValue(pre[3]) floatValue], [stringValue(pre[2]) floatValue]);
        anno.imageTag   = @"typhoon_level_yb";
        anno.title      = [self titleFromItem:info];
        anno.isHeader   = NO;
        anno.typhoonInfo = pre;
        if (CLLocationCoordinate2DIsValid(anno.coordinate)) {
            if (anno.coordinate.longitude == 180) {
                anno.coordinate = CLLocationCoordinate2DMake(anno.coordinate.latitude, -180);
            }
            
            [preAnnos addObject:anno];
        }
        
        if (i == 0) {
            NSArray *lastTrPath = self.preStartPoint;
            
            MKPolyline* polyline = [self polylineWithLat1:lastTrPath[5] lon1:lastTrPath[4] lat2:pre[3] lon2:pre[2]];
            polyline.title = @"xu";
            [prePolylines addObject:polyline];
        }
        else
        {
            NSArray *prep = prePathPoint[i-1];
            
            MKPolyline* polyline = [self polylineWithLat1:pre[3] lon1:pre[2] lat2:prep[3] lon2:prep[2]];
            [prePolylines addObject:polyline];
        }
        
        minLon = MIN([[pre objectAtIndex:2] floatValue], minLon);
        minLat = MIN([[pre objectAtIndex:3] floatValue], minLat);
        maxLon = MAX([[pre objectAtIndex:2] floatValue], maxLon);
        maxLat = MAX([[pre objectAtIndex:3] floatValue], maxLat);
    }
    //    CGFloat margen = 0.3;
    //    CLLocationCoordinate2D centCoor;
    //    centCoor.latitude = (CLLocationDegrees)((miny+maxy) * 0.5f);
    //    centCoor.longitude = (CLLocationDegrees)((minx+maxx) * 0.5f);
    //    [self.mapView setCenterCoordinate:centCoor animated:NO];
    //    MKCoordinateSpan span = (MKCoordinateSpan){(maxy-miny)+margen,(maxx-minx)+margen};
    //    MKCoordinateRegion region = (MKCoordinateRegion){centCoor, span};
    //    MKCoordinateRegion regi2 = [self.mapView regionThatFits:region];
    //    [self.mapView setRegion:regi2 animated:YES];
    
    //    NSArray *loadPoints = [[info objectForKey:@"LoadPoints"] objectForKey:@"LoadPoint"];
    //    if ([loadPoints isKindOfClass:[NSDictionary class]]) {
    //        loadPoints = @[loadPoints];
    //    }
    //
    //    if (loadPoints.count > 0) {
    //
    //        [self.mapView showAnnotations:annos animated:NO];
    //
    //        NSDictionary *loadPoint = loadPoints.lastObject;
    //        //只展示一个台风登录泡泡
    //        MyAnnotation *anno = [[MyAnnotation alloc] init];
    //        anno.pointType      = @"load";
    //        anno.coordinate     = CLLocationCoordinate2DMake([[loadPoint objectForKey:@"_y"] floatValue], [[loadPoint objectForKey:@"_x"] floatValue]);
    //        anno.typhoonInfo    = loadPoint;
    //        anno.title          = [self titleFromItem:self.currTyphoon];
    //        anno.isHeader       = NO;
    //        //        anno.imageTag = @"typhoon_icon";
    //        if (CLLocationCoordinate2DIsValid(anno.coordinate)) {
    //            if (anno.coordinate.longitude == 180) {
    //                anno.coordinate = CLLocationCoordinate2DMake(anno.coordinate.latitude, -180);
    //            }
    //
    //            [annos addObject:anno];
    //        }
    //
    //        [self.mapView addAnnotations:annos];
    //        [self.mapView addOverlays:polylines];
    //
    //        [self.mapView selectAnnotation:anno animated:YES];
    //    }
    MKCoordinateRegion region;
    region.center.latitude = (minLat + maxLat) / 2;
    region.center.longitude = (minLon + maxLon) / 2;
    
    region.span.latitudeDelta = (maxLat - minLat) * MAP_PADDING;
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE) ? MINIMUM_VISIBLE_LATITUDE: region.span.latitudeDelta;
    region.span.longitudeDelta = (maxLon - minLon) * MAP_PADDING;
    MKCoordinateRegion scaledRegion = [self.mapView regionThatFits:region];
    
    //    [NSValue valueWithMKCoordinate:scaledRegion.center]
    //    [NSValue valueWithMKCoordinateSpan:scaledRegion.span]
    [self.currTyphoonInfos setObject:@{@"points":[annos copy],
                                       @"lines":[polylines copy],
                                       @"prePoints":[preAnnos copy],
                                       @"preLines":[prePolylines copy],
                                       @"region_center":[NSValue valueWithMKCoordinate:scaledRegion.center],
                                       @"region_span":[NSValue valueWithMKCoordinateSpan:scaledRegion.span],} forKey:[info firstObject]];
}

-(void)showTyphoonDetail:(NSArray *)info
{
    self.playBackButton.hidden = (self.currTyphoons.count != 1);
    
    NSDictionary *showInfo = [self.currTyphoonInfos objectForKey:[info firstObject]];
    //    [self playBack];
    NSMutableArray *annos = [NSMutableArray arrayWithArray:[showInfo objectForKey:@"points"]];
    MyAnnotation *lastAnno = [annos lastObject];
    
    NSMutableArray *polylines = [NSMutableArray arrayWithArray:[showInfo objectForKey:@"lines"]];
    NSArray *preAnnos = [showInfo objectForKey:@"prePoints"];
    NSArray *prePolylines = [showInfo objectForKey:@"preLines"];
    // 倒序
    //    NSArray* reversedArray = [[annos reverseObjectEnumerator] allObjects];
    [annos addObjectsFromArray:preAnnos];
    [polylines addObjectsFromArray:prePolylines];
    
    [self.mapView addAnnotations:annos];
    [self.mapView addOverlays:polylines];
    
    if ([[info firstObject] longLongValue] == [[[self.currTyphoons lastObject] firstObject] longLongValue]) {
        
        MKCoordinateRegion region = MKCoordinateRegionMake([[showInfo objectForKey:@"region_center"] MKCoordinateValue], [[showInfo objectForKey:@"region_span"] MKCoordinateSpanValue]);
        [self.mapView setRegion:region animated:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mapView selectAnnotation:lastAnno animated:YES];
        });
    }
}

-(MKPolyline *)polylineWithLat1:(NSString *)lat1 lon1:(NSString *)lon1 lat2:(NSString *)lat2 lon2:(NSString *)lon2
{
    CLLocationCoordinate2D coors[2] = {0};
    coors[0].latitude = [lat1 floatValue];
    coors[0].longitude = [lon1 floatValue];
    if (coors[0].longitude == 180) {
        coors[0].longitude = -180;
    }
    
    coors[1].latitude = [lat2 floatValue];
    coors[1].longitude = [lon2 floatValue];
    if (coors[1].longitude == 180) {
        coors[1].longitude = -180;
    }
    
    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coors count:2];
    
    return polyline;
}

#pragma mark -- MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MyAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"pointIdentifier";
        
        MKAnnotationView *poiAnnotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (!poiAnnotationView)
        {
            poiAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
        }
        
        NSString *imageTag = [(MyAnnotation *)annotation imageTag];
        NSArray *typhoonInfo = [(MyAnnotation *)annotation typhoonInfo];
        NSString *pointType = [(MyAnnotation *)annotation pointType];
        BOOL isHeader = [(MyAnnotation *)annotation isHeader];
        
        poiAnnotationView.canShowCallout = YES;
        if (imageTag.length > 0) {
            poiAnnotationView.image = [UIImage imageNamed:imageTag];
        }
        
        poiAnnotationView.detailCalloutAccessoryView = [self detailAnnoViewWithAnno:pointType typhoonInfo:typhoonInfo];
        
        for (UIView *sub in poiAnnotationView.subviews) {
            [sub removeFromSuperview];
        }
        
        if (isHeader) {
            UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"typhoon_icon"]];
            iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            iv.center = CGPointMake(poiAnnotationView.width/2, poiAnnotationView.height/2);
            [poiAnnotationView addSubview:iv];
            
            self.ivHeader = iv;
            
            [self startHeaderAnnotation];
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(nonnull id<MKOverlay>)overlay
{
    
    if ([overlay isMemberOfClass:[MKPolyline class]]){
        MKPolylineRenderer* polylineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 2.0;
        if ([[overlay title] isEqualToString:@"xu"]) {
            //            polylineView.lineDashPhase = 1;
            polylineView.lineDashPattern = @[@1, @1];
        }
        
        return polylineView;
    }
    //    else if ([overlay isKindOfClass:[MKArcline class]])
    //    {
    //        BMKArclineView* arclineView = [[BMKArclineView alloc] initWithOverlay:overlay];
    //        arclineView.fillColor = [UIColor colorWithHexString:@"afd080"];
    //        arclineView.strokeColor = [UIColor colorWithHexString:@"afd080"];
    //        return arclineView;
    //    }
    else if ([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonRenderer* polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonView.fillColor = UIColorFromRGB(0xafd080);
        polygonView.strokeColor = UIColorFromRGB(0xafd080);
        return polygonView;
    }else if ([overlay isKindOfClass:[MKCircle class]]){
        MKCircle *circ = (MKCircle *)overlay;
        MKCircleRenderer* circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        circleView.lineWidth = 1;
        circleView.fillColor = [UIColorFromRGB(0x96ddfa) colorWithAlphaComponent:0.35];
        if ([[circ title] isEqualToString:@"EN10Radii"]) {
            circleView.strokeColor = [UIColor yellowColor];
        }else if([[circ title] isEqualToString:@"EN7Radii"]){
            circleView.strokeColor = [UIColor redColor];
        }
        return circleView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    if (self.overlayArrs.count > 0) {
        [self.mapView removeOverlays:self.overlayArrs];
        [self.overlayArrs removeAllObjects];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MyAnnotation class]]) {
        MyAnnotation *point = (MyAnnotation *)view.annotation;
        if ([point.pointType isEqualToString:@"true"]) {
            [self addWindCircle:point];
        }
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (self.selectView.alpha) {
        [self clickRightNav];
    }
}

-(UIView *)detailAnnoViewWithAnno:(NSString *)pointType typhoonInfo:(NSArray *)pdetail
{
    //    [typhoonInfo objectForKey:@"_Cir7Radii"]
    UILabel *lbl = [[UILabel alloc] init];
    
    NSString *text;
    if ([pointType isEqualToString:@"true"]) {
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[stringValue(pdetail[2]) longLongValue]/1000.0];
        NSString *year = [NSString stringWithFormat:@"%td", [dateTime year]];
        NSString *month = [NSString stringWithFormat:@"%td", [dateTime month]];
        NSString *day = [NSString stringWithFormat:@"%td", [dateTime day]];
        NSString *time = [NSString stringWithFormat:@"%td", [dateTime hour]];
        
        NSString *dtime = [NSString stringWithFormat:@"时间：%@年%@月%@日 %@时", year, month, day, time];
        NSString *lbLargeWindText = [NSString stringWithFormat:@"最大风速：%@(米/秒)", stringValue(pdetail[7])];
        NSString *lbCyText = [NSString stringWithFormat:@"中心气压：%@(百帕)", stringValue(pdetail[6])];
        NSString *lbMdirText = [NSString stringWithFormat:@"移动方向：%@", [self newWindDir:stringValue(pdetail[8])]];
        NSString *lbMSpedText = [NSString stringWithFormat:@"移动速度：%@(公里/小时)", stringValue(pdetail[9])];
        
        text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@", dtime, lbLargeWindText, lbCyText, lbMdirText, lbMSpedText];
        
        NSArray *wRadiiPoints = pdetail[10];
        if (wRadiiPoints && ![wRadiiPoints isKindOfClass:[NSNull class]])
        {
            for (NSInteger i=0; i<wRadiiPoints.count; i++) {
                NSArray *prep = [wRadiiPoints objectAtIndex:i];
                if (i == 0) {
                    NSString *Cir7Radii = stringValue(prep[1]);
                    
                    if (![Cir7Radii isEqualToString:@"999999"] && Cir7Radii.length > 0) {
                        NSString *wind7Text = [NSString stringWithFormat:@"7级风圈半径：%@(公里)", Cir7Radii];
                        text = [NSString stringWithFormat:@"%@\n%@", text, wind7Text];
                    }
                }
                
                if (i == 1) {
                    NSString *Cir10Radii = stringValue(prep[1]);
                    
                    if (![Cir10Radii isEqualToString:@"999999"] && Cir10Radii.length > 0) {
                        NSString *wind10Text = [NSString stringWithFormat:@"10级风圈半径：%@(公里)",Cir10Radii];
                        text = [NSString stringWithFormat:@"%@\n%@", text, wind10Text];
                    }
                }
            }
        }
    }
    else if ([pointType isEqualToString:@"load"])
    {
        text = @"load";//[typhoonInfo objectForKey:@"_inf"];
        
        lbl.textAlignment = NSTextAlignmentCenter;
    }
    else if ([pointType isEqualToString:@"pre"])
    {
        //        prePoint.from=stringValue(prep[1]);
        //        prePoint.x=stringValue(prep[2]);
        //        prePoint.y=stringValue(prep[3]);
        //        prePoint.limitation=stringValue(prep[0]);
        //        prePoint.CenterPressure=stringValue(prep[4]);
        //        prePoint.CenterWindSpeed=stringValue(prep[5]);
        //        prePoint.preType=[self tyhpLevelInfo:stringValue(prep[7])];
        
        NSString *ned = @"";
        NSDateFormatter *formatter = [NSDateFormatter new];//[CWDataManager sharedInstance].formatter;
        [formatter setDateFormat:@"yyyyMMddHHmm"];
        NSDate *d1 = [formatter dateFromString:stringValue(pdetail[1])];
        if (d1) {
            NSDate *n1 = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[d1 timeIntervalSinceReferenceDate]+([stringValue(pdetail[0]) intValue] + 8)*3600];
            [formatter setDateFormat:@"yyyy/MM/dd HH时"];
            ned = [formatter stringFromDate:n1];
        }
        
        
        NSString *dtime = [NSString stringWithFormat:@"%@ 中国预报", ned];
        
        NSString *lbLargeWindText = [NSString stringWithFormat:@"最大风速：%@(米/秒)", stringValue(pdetail[5])];
        NSString *lbCyText = [NSString stringWithFormat:@"中心气压：%@(百帕)", stringValue(pdetail[4])];
        
        text = [NSString stringWithFormat:@"%@\n%@\n%@", dtime, lbLargeWindText, lbCyText];
    }
    
    lbl.numberOfLines = 0;
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.text = text;
    [lbl sizeToFit];
    
    return lbl;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView1) {
        return self.yearList.count;
    }
    
    NSArray *arr = [self.listDicts objectForKey:[self.yearList objectAtIndex:self.selectYear]];
    return arr.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (tableView == self.tableView)
    {
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView1) {
        static NSString *identify = @"typhoon_year_cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@年", [self.yearList objectAtIndex:indexPath.row]];
        return cell;
    }
    else
    {
        static NSString *identify = @"typhoon_cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        
        NSArray *arr = [self.listDicts objectForKey:[self.yearList objectAtIndex:self.selectYear]];
        NSArray *item = [arr objectAtIndex:indexPath.row];
        
        NSString *title = [self stringValueFromJson:[item objectAtIndex:1]];
        
        NSString *nameCN = [self stringValueFromJson:[item objectAtIndex:2]];
        if (nameCN.length > 0) {
            title = [NSString stringWithFormat:@"%@ %@", nameCN, title];
        }
        
        NSString *typhNo = [self stringValueFromJson:[item objectAtIndex:3]];
        if (typhNo.length >0) {
            title = [NSString stringWithFormat:@"%@ %@", typhNo, title];
        }
        
        cell.textLabel.text = title;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView1) {
        self.selectYear = indexPath.row;
        
        NSArray *arr = [self.listDicts objectForKey:[self.yearList objectAtIndex:self.selectYear]];
        [self.tableView2 reloadData];
        if (!arr)
        {
            [self.tableView2 reloadData];
            [self.actView startAnimating];
            self.actView.hidden = NO;
            
            [self requestTyphoonListWithYear:[[self.yearList objectAtIndex:indexPath.row] integerValue]];
        }
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSArray *arr = [self.listDicts objectForKey:[self.yearList objectAtIndex:self.selectYear]];
        NSArray *item = [arr objectAtIndex:indexPath.row];
        
        [self clickRightNav];
        if (self.currTyphoons.count==1 && [[item firstObject] longLongValue] == [[[self.currTyphoons lastObject] firstObject] longLongValue]) {
            return;
        }
        else
        {
            [self.currTyphoonInfos removeAllObjects];
            [self.currTyphoons removeAllObjects];
            
            [self.currTyphoons addObject:item];
            self.titleLbl.text = [self titleFromItem:item];
            [self requestTyphoonDetailWithItem:item];
        }
    }
    
}

-(void)clickRightNav
{
    [UIView animateWithDuration:0.3 animations:^{
        self.selectView.alpha = 1.0 - self.selectView.alpha;
    }];
}

-(void)clickIndexButton
{
    self.indexButton.userInteractionEnabled = NO;
    if (self.indexView.hidden) {
        self.indexView.hidden = NO;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.indexView.y = 0;
        } completion:^(BOOL finished) {
            self.indexButton.userInteractionEnabled = YES;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.indexView.y = self.view.height;
        } completion:^(BOOL finished) {
            self.indexView.hidden = YES;
            self.indexButton.userInteractionEnabled = YES;
        }];
    }
}

-(void)stopPlayBack{
    self.isPlayBack = NO;
    if (self.playTimer) {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
    self.playIndex = 0;
}

-(void)playBack
{
    [self stopPlayBack];
    self.isPlayBack = YES;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playProcess:) userInfo:nil repeats:YES];
    [self.playTimer fire];
}

-(void)playProcess:(NSTimer *)tm{
    if (self.overlayArrs.count > 0) {
        [self.mapView removeOverlays:self.overlayArrs];
        [self.overlayArrs removeAllObjects];
    }
    
    NSDictionary *showInfo = [self.currTyphoonInfos objectForKey:[[self.currTyphoons firstObject] firstObject]];
    NSArray *annos = [showInfo objectForKey:@"points"];
    NSArray *polylines = [showInfo objectForKey:@"lines"];
    NSArray *preAnnos = [showInfo objectForKey:@"prePoints"];
    NSArray *prePolylines = [showInfo objectForKey:@"preLines"];
    
    if (self.playIndex == 0) {
        [self.mapView addAnnotation:[annos objectAtIndex:self.playIndex]];
    }
    else if (self.playIndex < annos.count)
    {
        MyAnnotation *anno = [annos objectAtIndex:self.playIndex];
        [self.mapView addAnnotation:anno];
        [self.mapView addOverlay:[polylines objectAtIndex:self.playIndex-1]];
        //        [self.mapView setCenterCoordinate:anno.coordinate];
        [self.mapView selectAnnotation:anno animated:NO];
    }
    else if (self.playIndex < (annos.count + preAnnos.count))
    {
        NSInteger preIndex = self.playIndex-annos.count;
        MyAnnotation *anno = [preAnnos objectAtIndex:preIndex];
        [self.mapView addAnnotation:anno];
        [self.mapView addOverlay:[prePolylines objectAtIndex:preIndex]];
        //        [self.mapView setCenterCoordinate:anno.coordinate];
        [self.mapView selectAnnotation:anno animated:NO];
    }
    else
    {
        [self stopPlayBack];
        
        MKCoordinateRegion region = MKCoordinateRegionMake([[showInfo objectForKey:@"region_center"] MKCoordinateValue], [[showInfo objectForKey:@"region_span"] MKCoordinateSpanValue]);
        [self.mapView setRegion:region animated:YES];
        
        MyAnnotation *lastAnno = [annos lastObject];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mapView selectAnnotation:lastAnno animated:YES];
        });
    }
    self.playIndex++;
}

#pragma mark - tools
-(NSString *)jsonStringFromJsonpString:(NSString *)str
{
    NSError *error;
    // 创建NSRegularExpression对象并指定正则表达式
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"(\\w+[\(])\\{"
                                  options:0
                                  error:&error];
    if (!error) { // 如果没有错误
        // 获取特特定字符串的范围
        NSString *match = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"{"];
        if (match) {
            NSString *result = [match substringToIndex:match.length-1];
            
            return result;
        }
    }
    
    return nil;
}

-(NSString *)stringValueFromJson:(id)value
{
    if (value == nil || value == [NSNull null])
    {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]])
    {
        return value;
    }
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [value stringValue];
    }
    return @"";
}

-(NSString *)tyhpLevelInfo:(NSString *)code
{
    NSDictionary *levels = @{@"TD":@"1",
                             @"TS":@"2",
                             @"STS":@"3",
                             @"TY":@"4",
                             @"STY":@"5",
                             @"SuperTY":@"6",
                             };
    
    return [levels objectForKey:code];
}

-(NSString *)newWindDir:(NSString *)dir{
    NSString *wind_dir = @"";
    for (int i = 0; i<[dir length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [dir substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:@"E"]) {
            wind_dir = [wind_dir stringByAppendingString:@"东"];
        }
        else if ([s isEqualToString:@"W"]) {
            wind_dir = [wind_dir stringByAppendingString:@"西"];
        }
        else if ([s isEqualToString:@"S"]) {
            wind_dir = [wind_dir stringByAppendingString:@"南"];
        }
        else if ([s isEqualToString:@"N"]) {
            wind_dir = [wind_dir stringByAppendingString:@"北"];
        }
    }
    
    return wind_dir;
}

-(void)startHeaderAnnotation{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 ];
    rotationAnimation.duration = 0.8;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.ivHeader.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopHeaderAnnotation{
    [self.ivHeader.layer removeAnimationForKey:@"rotationAnimation"];
}
@end
