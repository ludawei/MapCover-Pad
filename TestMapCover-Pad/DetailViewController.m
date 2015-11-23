//
//  DetailViewController.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/21.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "DetailViewController.h"

#import "Masonry.h"
#import "CWMyOverlayRenderer.h"
#import "CWMyPolyLineRenderer.h"
#import "Util.h"
#import "CustomAnnotationView.h"

@interface DetailViewController ()<MKMapViewDelegate>

@property (nonatomic,strong) NSDictionary *dataInfo,*data;
@property (nonatomic,strong) NSArray *areas;
@property (nonatomic,strong) UIImageView *indexView;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.title = self.detailItem;
        [self initData:self.detailItem];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//    self.navigationItem.leftItemsSupplementBackButton = YES;
//    self.splitViewController
    
    [self configureView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.mapView) {
        self.mapView.delegate = self;
        [self.view addSubview:self.mapView];
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(20);
        }];
        
        UIImage *indexImage = [UIImage imageNamed:(NSString *)self.detailItem];
        
        UIImageView *imgView = [UIImageView new];
        imgView.image = indexImage;
        [self.view addSubview:imgView];
        self.indexView = imgView;
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(self.view);
        }];
    }
    else
    {
        UILabel *lbl = [UILabel new];
        lbl.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lbl];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        
        lbl.text = @"点击左侧列表查看内容";
    }
}

-(void)addAreasToMap
{
    NSArray *areas = [self.data objectForKey:@"areas"];
    for (NSDictionary *area in areas) {
        NSArray *items = [area objectForKey:@"items"];
        
        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * items.count);
        
        for (NSInteger i=0; i<items.count; i++) {
            NSDictionary *point = [items objectAtIndex:i];
            
            points[i] = CLLocationCoordinate2DMake([[point objectForKey:@"y"] doubleValue], [[point objectForKey:@"x"] doubleValue]);
        }
        
        MKPolygon *line = [MKPolygon polygonWithCoordinates:points count:items.count];
        free(points);
        
        if ([area objectForKey:@"c"]) {
            line.title = [area objectForKey:@"c"];
            line.subtitle = [area objectForKey:@"is_stripe"];
        }
//        else
//        {
//            NSDictionary *data = [self dataFromDataInfoWithCode:[area objectForKey:@"code"] text:[[area objectForKey:@"symbols"] objectForKey:@"text"]];
//            
//            line.title = [data objectForKey:@"color"];
//            line.subtitle = [data objectForKey:@"is_stripe"];
//        }
        
        
        [self.mapView addOverlay:line];
        
#if 0       // 不显示标注
        NSDictionary *anniInfo = [area objectForKey:@"symbols"];
        for (NSDictionary *anni in [anniInfo objectForKey:@"items"]) {
            
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            ann.coordinate = CLLocationCoordinate2DMake([[anni objectForKey:@"y"] doubleValue], [[anni objectForKey:@"x"] doubleValue]);
            ann.title = [anniInfo objectForKey:@"text"];
            
            [self.mapView addAnnotation:ann];
        }
#endif
    }
}

//-(void)addLinesToMap
//{
//    NSArray *areas = [self.data objectForKey:@"lines"];
//    /********* 目前没有，暂时不处理 *********/
//    
//    for (NSDictionary *area in areas) {
//        NSArray *items = [area objectForKey:@"items"];
//
//        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * items.count);
//
//        for (NSInteger i=0; i<items.count; i++) {
//            NSDictionary *point = [items objectAtIndex:i];
//
//            points[i] = CLLocationCoordinate2DMake([[point objectForKey:@"y"] doubleValue], [[point objectForKey:@"x"] doubleValue]);
//        }
//
//        MKPolygon *line = [MKPolygon polygonWithCoordinates:points count:items.count];
////        line.subtitle = [self colorStringFromDataInfoWithCode:[area objectForKey:@"code"] text:[[area objectForKey:@"symbols"] objectForKey:@"text"]];
//        free(points);
//
//        [self.mapView addOverlay:line];
//    }
//}

-(void)addLine_symbolsToMap
{
    NSArray *areas = [self.data objectForKey:@"line_symbols"];
    for (NSDictionary *area in areas) {
        
        if ([[area objectForKey:@"code"] integerValue] != 38) {
            continue;
        }
        
        NSArray *items = [area objectForKey:@"items"];
        
        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * items.count);
        
        for (NSInteger i=0; i<items.count; i++) {
            NSDictionary *point = [items objectAtIndex:i];
            
            points[i] = CLLocationCoordinate2DMake([[point objectForKey:@"y"] doubleValue], [[point objectForKey:@"x"] doubleValue]);
        }
        
        MKPolyline *line = [MKPolyline polylineWithCoordinates:points count:items.count];
        //        line.subtitle = [self colorStringFromDataInfoWithCode:[area objectForKey:@"code"] text:[[area objectForKey:@"symbols"] objectForKey:@"text"]];
        free(points);
        
        [self.mapView addOverlay:line];
    }
}

-(void)addSymbolsToMap
{
    NSArray *areas = [self.data objectForKey:@"symbols"];
    for (NSDictionary *area in areas) {
        
        MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
        ann.coordinate = CLLocationCoordinate2DMake([[area objectForKey:@"y"] doubleValue], [[area objectForKey:@"x"] doubleValue]);
        ann.title = [area objectForKey:@"text"];
        
        [self.mapView addAnnotation:ann];
    }
}

-(void)addAreasToMap1
{
    for (NSDictionary *area in self.areas) {
        NSArray *items = [area objectForKey:@"items"];
        
        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * items.count);
        
        for (NSInteger i=0; i<items.count; i++) {
            NSDictionary *point = [items objectAtIndex:i];
            
            points[i] = CLLocationCoordinate2DMake([[point objectForKey:@"lat"] doubleValue], [[point objectForKey:@"lng"] doubleValue]);
        }
        
        MKPolygon *line = [MKPolygon polygonWithCoordinates:points count:items.count];
        
        line.title = [area objectForKey:@"color"];
        free(points);
        
        [self.mapView addOverlay:line];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.data) {
        [self addAreasToMap];
        
        [self addLine_symbolsToMap];
        
//        [self addSymbolsToMap];
    }
    
    if (self.areas) {
        [self addAreasToMap1];
    }
}

-(NSDictionary *)dataFromDataInfoWithCode:(NSString *)code text:(NSString *)colorText
{
    NSMutableDictionary *finalData = [NSMutableDictionary dictionary];
    
    NSArray *blendent = [[self.dataInfo objectForKey:@"legend"] objectForKey:@"blendent"];
    
    NSDictionary *dict = blendent.firstObject;
    {
        for (NSDictionary *d in blendent) {
            if ([[[d objectForKey:@"val"] objectForKey:@"v"] integerValue] == [code integerValue]) {
                dict = d;
            }
        }
    }
    
    NSArray *colors = [dict objectForKey:@"colors"];
    [finalData setObject:[[dict objectForKey:@"is_stripe"] boolValue]?@"1":@"0" forKey:@"is_stripe"];
    
    NSDictionary *colorDict = colors.firstObject;
    [finalData setObject:[colorDict objectForKey:@"color"] forKey:@"color"];
    {
        for (NSDictionary *colorDict in colors) {
            
            NSArray *val = [colorDict objectForKey:@"val"];
            if (colorText.integerValue >= [val.firstObject integerValue] && colorText.integerValue < [val.lastObject integerValue]) {
                [finalData setObject:[colorDict objectForKey:@"color"] forKey:@"color"];
            }
        }
    }
    
    return finalData;
}

//-(void)initDataInfo:(NSString *)name
//{
//    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    
//    self.dataInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//}

-(void)initData:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    
    id data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    if ([data isKindOfClass:[NSArray class]]) {
        self.areas = data;
    }
    else
    {
        self.data = data;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayRenderer *renderer = nil;
    
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        CWMyOverlayRenderer *routineView = [[CWMyOverlayRenderer alloc] initWithPolygon:overlay];
        routineView.fillColor = [Util colorFromRGBString:[overlay title]];
        
        renderer = routineView;
    }
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        CWMyPolyLineRenderer * routineView = [[CWMyPolyLineRenderer alloc] initWithPolyline:overlay];
        routineView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];//[[Util colorFromRGBString:[overlay subtitle]] colorWithAlphaComponent:0.7];
        routineView.lineWidth = 1.5;
        renderer = routineView;
    }
    
    return renderer;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *annIdentifier = @"annIdentifier-detail";
        
        CustomAnnotationView *poiAnnotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:annIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        if ([poiAnnotationView isKindOfClass:[CustomAnnotationView class]]) {
            poiAnnotationView.image = [UIImage imageNamed:@"circle39"];
            [poiAnnotationView setLabelText:[annotation title]];
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

@end
