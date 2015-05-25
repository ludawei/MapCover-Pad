//
//  TyphoonMapViewController.m
//  中国天气通
//
//  Created by Sam Chen on 11/10/12.
//
//

#import "TyphoonMapViewController.h"
#import "MBundle.h"
//#import "StatAgent.h"
//#import "AppDelegate.h"

@interface TyphoonMapViewController ()

@property (nonatomic,retain) UINavigationItem *navItem;

@end

@implementation TyphoonMapViewController
{
@private
    BOOL isInTyphoonQueryMode;
    BOOL isTyphoonQueryButtonSetuped;
    NSString * MYDFileType;
    NSString * currentTyphoonId;
    NSString * currentTyphoonName;
    NSString * currentYear;
    NSUInteger currentYearTyphoonRowNum;
    NSUInteger currentTyphoonRow;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isInTyphoonQueryMode = NO;
        isTyphoonQueryButtonSetuped = NO;
        MYDFileType = nil;
        currentTyphoonId = nil;
        currentTyphoonName = nil;
        currentYear = nil;
        currentYearTyphoonRowNum = 0;
        currentTyphoonRow = 0;
    }
    return self;
}

-(void)setupNav
{
    self.navItem = self.navigationItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"查询"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(onTyphoonQuery:)];
    self.navItem .rightBarButtonItem = rightItem;
    
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Setup the Toolbar
    [self setupNav];
    self.navItem.title = @"台风路径";
    
    self.typhoonLabel.hidden = YES;
    self.spotInfoPanel.hidden = YES;
    
    NSLog(@"Type : %@, Params : %@", self.requestType, self.requestParams);
    
    self.typhoonList = [[[NSMutableArray alloc] init] autorelease];
    self.typhoonInfo = [[[NSMutableArray alloc] init] autorelease];
    self.typhoonIncPoints = [[[NSMutableArray alloc] init] autorelease];
    self.typhoonSpotAnnotations = [[[NSMutableArray alloc] init] autorelease];
    //self.typhoonRoutine = [[[MKPolyline alloc] init] autorelease];
    //self.typhoon7circle = [[[MKCircle alloc] init] autorelease];
    //self.typhoon10circle = [[[MKCircle alloc] init] autorelease];
    
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(40.0,116.0);
    [self gotoLocation:loc];
    
    self.weatherMapView.delegate = self;
    self.weatherMapView.hidden = NO;
    
    //Init MydControl
    self.mydControl = [[[WCMydTaskControl alloc] init] autorelease];
    
    //Add Radar Data
    [self loadTyphoonList];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        self.typhoonPicker.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)gotoLocation:(CLLocationCoordinate2D)loc
{
    float latitudeDelta = 3.0;
    float longitudeDelta = 2.5;
    MKCoordinateRegion newRegion;
    newRegion.center = loc;
    newRegion.span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    [self.weatherMapView setRegion:newRegion animated:YES];
}

- (void)gotoRegion:(MKCoordinateRegion)region
{
    [self.weatherMapView setRegion:region animated:YES];
}

- (MKCoordinateRegion)makeMKMapRegionByLonLow:(double)lonLow lonHigh:(double)lonHigh latLow:(double)latLow latHigh:(double)latHigh
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = (latHigh - latLow) / 2 + latLow;
    newRegion.center.longitude = (lonHigh - lonLow) / 2 + lonLow;
    newRegion.span = MKCoordinateSpanMake(latHigh - latLow, lonHigh - lonLow);
    
    return newRegion;
}

- (void)gotoFitRegionForTyphoon:(NSArray*)typhoonInfo
{
    if ([typhoonInfo count] == 0) {
        return;
    }
    
    double lonLow = [[typhoonInfo[0] objectForKey:@"jd"] doubleValue];
    double lonHigh = lonLow;
    double latLow = [[typhoonInfo[0] objectForKey:@"wd"] doubleValue];
    double latHigh = latLow;
    
    double lon, lat;
    for (NSDictionary * pos in typhoonInfo) {
        lon = [[pos objectForKey:@"jd"] doubleValue];
        lat = [[pos objectForKey:@"wd"] doubleValue];
        if (lon < lonLow) {
            lonLow = lon;
        }
        if (lon > lonHigh) {
            lonHigh = lon;
        }
        
        if (lat < latLow) {
            latLow = lat;
        }
        if (lat > latHigh) {
            latHigh = lat;
        }
    }
    
    //NSLog(@"*** === %f, %f, %f, %f", lonLow, lonHigh, latLow, latHigh);
    
    latLow = latLow - (latHigh - latLow) / 8;
    lonLow = lonLow - (lonHigh - lonLow) / 8;
    latHigh = latHigh + (latHigh - latLow) / 8;
    lonHigh = lonHigh + (lonHigh - lonLow) / 8;
    
    //NSLog(@"**** === %f, %f, %f, %f", lonLow, lonHigh, latLow, latHigh);
    MKCoordinateRegion region = [self makeMKMapRegionByLonLow:lonLow lonHigh:lonHigh latLow:latLow latHigh:latHigh];
    [self.weatherMapView setRegion:region animated:YES];
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //NSLog(@"***** === %f, %f, %f, %f", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}

- (void)loadTyphoonList
{
    //WCMydTaskControl * taskControl = [[WCMydTaskControl alloc] init];
    
    NSArray * params = @[MYD_TYPHOON_LIST, @"2012"];
    MYDFileType = MYD_TYPHOON_LIST;
    
    self.mydControl.displayDelegate = self;
    [self.mydControl getMydFromServer:params];
    //taskControl.displayDelegate = self;
    //[taskControl getMydFromServer:params];
}

- (void)loadTyphoonInfo:(NSString *)typhoonId
{
    //WCMydTaskControl * taskControl = [[WCMydTaskControl alloc] init];
    if (typhoonId) {
        NSArray * params = @[MYD_TYPHOON, typhoonId];
        MYDFileType = MYD_TYPHOON;
        
        self.mydControl.displayDelegate = self;
        [self.mydControl getMydFromServer:params];
    }
}

- (void)loadTyphoonIncPoints:(NSString *)typhoonId
{
    if (typhoonId) {
        NSArray * params = @[MYD_TYPHOON_INCPOINTS, typhoonId];
        MYDFileType = MYD_TYPHOON_INCPOINTS;
        
        self.mydControl.displayDelegate = self;
        [self.mydControl getMydFromServer:params];
    }
}

//- (void)onTriggered:(NSData *)result
- (void)displayMydData:(id)result taskControl:(id)taskControl
{
    //[taskControl release];
    MBundle * bundle = [[[MBundle alloc] init] autorelease];
    [bundle getBundle:result];
    
    MText * mText = (MText *)bundle.tags[0];
    //NSLog(@"################# ret : %@ ############### len : %d, %d", mText.text, mText.tagLen, mText.text.length);
    
    NSXMLParser * xmlparser = [[[NSXMLParser alloc] initWithData:[mText.text dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    [xmlparser setDelegate:self];
    BOOL isXMLParseOK = [xmlparser parse];
    if (!isXMLParseOK) {
        NSLog(@"XML Parse Error : %@", [xmlparser parserError]);
        return;
    }
    
    //    if (bundle.fileType == TEXT_FILE && [MYDFileType compare:MYD_TYPHOON] == 0) {
    //
    //    }
    //    else if (bundle.fileType == TEXT_FILE && [MYDFileType compare:@"TYLI"] == 0) {
    //
    //    }
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    if ([MYDFileType isEqual: MYD_TYPHOON]) {
        [self.typhoonInfo removeAllObjects];
    }
    else if ([MYDFileType isEqual: MYD_TYPHOON_LIST]) {
        [self.typhoonList removeAllObjects];
    }
    if ([MYDFileType isEqual: MYD_TYPHOON_INCPOINTS]) {
        [self.typhoonIncPoints removeAllObjects];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"tfProps"]) {
        if ([MYDFileType isEqual: MYD_TYPHOON]) {
            [self.typhoonInfo addObject:attributeDict];
        }
        else if ([MYDFileType isEqual: MYD_TYPHOON_LIST]) {
            [self.typhoonList addObject:attributeDict];
        }
    }
    else if ([elementName isEqualToString:@"IncPoint"]) {
        if ([MYDFileType isEqual: MYD_TYPHOON_INCPOINTS]) {
            [self.typhoonIncPoints addObject:attributeDict];
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([MYDFileType isEqual: MYD_TYPHOON]) {
        //NSString * jd = [[self.typhoonInfo objectAtIndex:1] objectForKey:@"jd"];
        //NSLog(@"Typhoon JD : %@", jd);
        [self displayTyphoon:self.typhoonInfo];
    }
    else if ([MYDFileType isEqual: MYD_TYPHOON_LIST]) {
        int fileCount = [self.typhoonList count];
        if (fileCount > 0) {
            NSString * typhoonId = [[self.typhoonList objectAtIndex:fileCount - 1] objectForKey:@"code"];
            self.typhoonName = [[self.typhoonList objectAtIndex:fileCount - 1] objectForKey:@"title"];
            NSLog(@"TyphoonID : %@", typhoonId);
            currentTyphoonId = typhoonId;
            [self loadTyphoonInfo:currentTyphoonId];
            if (!isTyphoonQueryButtonSetuped) {
//                [self setupTyphoonQueryButton];
                isTyphoonQueryButtonSetuped = YES;
            }
        }
    }
    else if ([MYDFileType isEqual: MYD_TYPHOON_INCPOINTS]) {
        [self displayTyphoonIncPoints:self.typhoonIncPoints];
    }
}

- (void)displayTyphoon:(NSArray*)typhoonInfo
{
    @try {
        [self.typhoonSpotAnnotations removeAllObjects];
        
        int liveSpotCount = 0;
        int forecastSpotCount = 0;
        for (NSDictionary * info in typhoonInfo) {
            if ([[info objectForKey:@"t"] isEqualToString:@"00"]) {
                liveSpotCount++;
            }
            else {
                forecastSpotCount++;
            }
        }

        //CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * [typhoonInfo count]);
        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * liveSpotCount);
        CLLocationCoordinate2D * forecast_points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * (forecastSpotCount+1));
        
        int i = 0;
        int j = 1;
        for (NSDictionary * info in typhoonInfo) {
            TyphoonSpotAnnotation * ann = [[[TyphoonSpotAnnotation alloc] init] autorelease];
            ann.typhoonSpotInfo = info;
            ann.latitude = [[info objectForKey:@"wd"] doubleValue];
            ann.longitude = [[info objectForKey:@"jd"] doubleValue];
            [self.typhoonSpotAnnotations addObject:ann];
            
            CLLocationCoordinate2D pLoc = CLLocationCoordinate2DMake(ann.latitude, ann.longitude);
            if ([[info objectForKey:@"t"] isEqualToString:@"00"]) {
                points[i] = pLoc;
                forecast_points[0] = pLoc;
                i++;
            }
            else {
                forecast_points[j] = pLoc;
                j++;
            }
        }
        
        [self.weatherMapView addAnnotations:self.typhoonSpotAnnotations];
        
//        self.typhoonRoutine = [MKPolyline polylineWithCoordinates:points count:[typhoonInfo count]];
//        [self.weatherMapView addOverlay:self.typhoonRoutine];
//        free(points);
        self.typhoonRoutine = [MKPolyline polylineWithCoordinates:points count:liveSpotCount];
        self.typhoonRoutine.subtitle = @"liveRoutine";
        [self.weatherMapView addOverlay:self.typhoonRoutine];
        free(points);
        self.typhoonForecastRoutine = [MKPolyline polylineWithCoordinates:forecast_points count:forecastSpotCount+1];
        self.typhoonForecastRoutine.subtitle = @"forecastRoutine";
        [self.weatherMapView addOverlay:self.typhoonForecastRoutine];
        free(forecast_points);
        
        //[self displayTyphoonCircle:typhoonInfo[[typhoonInfo count]-1]];
        if (liveSpotCount-1 >= 0 && liveSpotCount <= typhoonInfo.count) {
            [self displayTyphoonCircle:typhoonInfo[liveSpotCount-1]];
            
            [self displayTyphoonName:self.typhoonName];
            
            if (forecastSpotCount > 0) {
                [self loadTyphoonIncPoints:currentTyphoonId];
            }
            [self gotoFitRegionForTyphoon:typhoonInfo];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"displayTyphoon exception ... %@", exception);
    }
}

- (void)displayTyphoonCircle:(NSDictionary *)typhoonSpotInfo
{
    if (!typhoonSpotInfo) {
        return;
    }
    
    // Remove all the Circle overlay
    NSArray * overlays = [self.weatherMapView overlays];
    for (id overlay in overlays) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            [self.weatherMapView removeOverlay:overlay];
        }
    }
    
    // Add Circle overlay
    double latitude = [[typhoonSpotInfo objectForKey:@"wd"] doubleValue];
    double longitude = [[typhoonSpotInfo objectForKey:@"jd"] doubleValue];
    NSString * radiusB7Str = [typhoonSpotInfo objectForKey:@"b7"];
    NSString * radiusB10Str = [typhoonSpotInfo objectForKey:@"b10"];
    double radiusB7 = 0.0;
    double radiusB10 = 0.0;
    
    CLLocationCoordinate2D pLoc = CLLocationCoordinate2DMake(latitude, longitude);
    
    if ([radiusB7Str compare:@""] != 0) {
        radiusB7 = [radiusB7Str intValue] * 1000;
        self.typhoon7circle = [MKCircle circleWithCenterCoordinate:pLoc radius:radiusB7];
        [self.weatherMapView addOverlay:self.typhoon7circle];
    }
    
    if ([radiusB10Str compare:@""] != 0) {
        radiusB10 = [radiusB10Str intValue] * 1000;
        self.typhoon10circle = [MKCircle circleWithCenterCoordinate:pLoc radius:radiusB10];
        [self.weatherMapView addOverlay:self.typhoon10circle];
    }
    
}

- (void)displayTyphoonName:(NSString *)typhoonName
{
    self.typhoonLabel.text = typhoonName;
    self.typhoonLabel.hidden = NO;
}

- (void)displayTyphoonSpotInfo:(NSDictionary *)typhoonSpotInfo
{
    if (!typhoonSpotInfo) {
        return;
    }
    
    self.spotInfoPanel.hidden = NO;
    
    NSString * spotTime = [NSString stringWithFormat:@"%@-%@-%@ %@时",
                           [typhoonSpotInfo objectForKey:@"y"],
                           [typhoonSpotInfo objectForKey:@"m"],
                           [typhoonSpotInfo objectForKey:@"d"],
                           [typhoonSpotInfo objectForKey:@"h"]];
    self.spotTimeLabel.text = spotTime;
    
    NSString * spotLocation = [NSString stringWithFormat:@"%@E %@N",
                               [typhoonSpotInfo objectForKey:@"jd"],
                               [typhoonSpotInfo objectForKey:@"wd"]];
    self.spotLocationLabel.text = spotLocation;
    
    NSString * spotPressure = [NSString stringWithFormat:@"%@百帕",
                               [typhoonSpotInfo objectForKey:@"qy"]];
    self.spotPressureLabel.text = spotPressure;
    
    NSString * spotWindSpeed;
    if ([[typhoonSpotInfo objectForKey:@"fs"] length] != 0) {
        spotWindSpeed = [NSString stringWithFormat:@"%@米/秒",
                         [typhoonSpotInfo objectForKey:@"fs"]];
    }
    else spotWindSpeed = @"";
    self.spotWindSpeedLabel.text = spotWindSpeed;
    
    NSString * spotMoveDir = [NSString stringWithFormat:@"%@",
                              [typhoonSpotInfo objectForKey:@"fx"]];
    self.spotMoveDirLabel.text = spotMoveDir;
    
    NSString * spotMoveSpeed = [NSString stringWithFormat:@"%@",
                                [typhoonSpotInfo objectForKey:@"sd"]];
    self.spotMoveSpeedLabel.text = spotMoveSpeed;
    
    NSString * spotB7Circle;
    if ([[typhoonSpotInfo objectForKey:@"b7"] length] != 0) {
        spotB7Circle = [NSString stringWithFormat:@"%@km",
                        [typhoonSpotInfo objectForKey:@"b7"]];
    }
    else spotB7Circle = @"";
    self.spotB7CircleLabel.text = spotB7Circle;
    
    NSString * spotB10Circle;
    if ([[typhoonSpotInfo objectForKey:@"b10"] length] != 0) {
        spotB10Circle = [NSString stringWithFormat:@"%@km",
                         [typhoonSpotInfo objectForKey:@"b10"]];
    }
    else spotB10Circle = @"";
    self.spotB10CircleLabel.text = spotB10Circle;
}

- (void)displayTyphoonIncPoints:(NSArray *)typhoonIncPoints
{
    if (!typhoonIncPoints || [typhoonIncPoints count] == 0) {
        return;
    }
    
    CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * [typhoonIncPoints count]);
    
    int i = 0;
    double longitude, latitude;
    for (NSDictionary * info in typhoonIncPoints) {
        longitude = [[info objectForKey:@"x"] doubleValue];
        latitude = [[info objectForKey:@"y"] doubleValue];
        
        CLLocationCoordinate2D pLoc = CLLocationCoordinate2DMake(latitude, longitude);
        points[i] = pLoc;
        i++;
    }
    
    MKPolygon * incPoints = [MKPolygon polygonWithCoordinates:points count:[typhoonIncPoints count]];
    incPoints.subtitle = @"incPoints";
    [self.weatherMapView addOverlay:incPoints];
    free(points);
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (!view) {
        return;
    }
    
    TyphoonSpotAnnotation * ann = (TyphoonSpotAnnotation *)view.annotation;
    [self displayTyphoonCircle:ann.typhoonSpotInfo];
    [self displayTyphoonSpotInfo:ann.typhoonSpotInfo];
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //NSLog(@"-------- viewForAnnotation!");
    //MKAnnotationView * v = nil;
    TyphoonSpotAnnotationView * v = nil;
    
    static NSString * ident = @"typhoonSpot";
    v = (TyphoonSpotAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ident];
    if (v == nil) {
        //        v = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
        //                                             reuseIdentifier:ident]
        //                                                 autorelease];
        //        ((MKPinAnnotationView*)v).pinColor = MKPinAnnotationColorGreen;
        //        ((MKPinAnnotationView*)v).animatesDrop = YES;
        //        [((MKPinAnnotationView*)v) setImage:[UIImage imageNamed:@"city_book.png"]];
        v = [[[TyphoonSpotAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ident] autorelease];
        //TyphoonSpotAnnotation * ann = (TyphoonSpotAnnotation *)v.annotation;
        v.canShowCallout = NO;
    }
    else {
        v.annotation = annotation;
        [v setNeedsDisplay];
    }
    
    return v;
}

- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayView* v = nil;
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        if ([[overlay subtitle] isEqualToString:@"liveRoutine"]) {
            MKPolylineView * routineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
            routineView.fillColor = [UIColor redColor];
            routineView.strokeColor = [UIColor redColor];
            routineView.lineWidth = 3.0;
            v = routineView;
        }
        else if ([[overlay subtitle] isEqualToString:@"forecastRoutine"]) {
            MKPolylineView * routineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
            routineView.fillColor = [UIColor yellowColor];
            routineView.strokeColor = [UIColor yellowColor];
            routineView.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:6], nil];
            routineView.lineWidth = 2.5;
            v = routineView;
        }
    }
    else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView * circleView = [[[MKCircleView alloc] initWithCircle:overlay] autorelease];
        circleView.fillColor = [UIColor redColor];
        circleView.strokeColor = [UIColor redColor];
        circleView.alpha = 0.2;
        circleView.lineWidth = 4.0;
        v = circleView;
    }
    else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonView * polygonView = [[[MKPolygonView alloc] initWithPolygon:overlay] autorelease];
        polygonView.fillColor = [UIColor greenColor];
        polygonView.strokeColor = [UIColor purpleColor];
        polygonView.alpha = 0.3;
        polygonView.lineWidth = 2.0;
        v = polygonView;
    }
    return v;
}

- (void)clearWeatherMapView
{
    // Remove all the overlay, including circles
    NSArray * overlays = [self.weatherMapView overlays];
    [self.weatherMapView removeOverlays:overlays];
    
    // Remove all the annotations
    NSArray * annotations = [self.weatherMapView annotations];
    [self.weatherMapView removeAnnotations:annotations];
    
    // Hide the Info Panel
    self.spotInfoPanel.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    // StatAgent
    //[StatAgent onResume:@"MapServiceView"];
    //AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    //myAppDelegate.currentServiceId = self.serviceId;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    self.mydControl.displayDelegate = nil;
    
    // StatAgent
//    [StatAgent onPause:self.serviceId];
}

- (void)viewDidUnload
{
    self.mydControl.displayDelegate = nil;
    [self setWeatherMapView:nil];
    [self setTyphoonLabel:nil];
    [self setSpotTimeLabel:nil];
    [self setSpotLocationLabel:nil];
    [self setSpotPressureLabel:nil];
    [self setSpotWindSpeedLabel:nil];
    [self setSpotMoveDirLabel:nil];
    [self setSpotMoveSpeedLabel:nil];
    [self setSpotB7CircleLabel:nil];
    [self setSpotB10CircleLabel:nil];
    [self setSpotInfoPanel:nil];
    [self setTyphoonPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    self.mydControl.displayDelegate = nil;
    [_weatherMapView release];
    [_requestType release];
    [_requestParams release];
    [_serviceId release];
    [_toolBarTitleString release];
    [_typhoonList release];
    [_typhoonInfo release];
    [_typhoonIncPoints release];
    [_typhoonSpotAnnotations release];
    [_typhoonName release];
    //[_typhoonRoutine release];
    //[_typhoonForecastRoutine release];
    //[_typhoon7circle release];
    //[_typhoon10circle release];
    [_typhoonLabel release];
    [_spotTimeLabel release];
    [_spotLocationLabel release];
    [_spotPressureLabel release];
    [_spotWindSpeedLabel release];
    [_spotMoveDirLabel release];
    [_spotMoveSpeedLabel release];
    [_spotB7CircleLabel release];
    [_spotB10CircleLabel release];
    [_spotInfoPanel release];
    [_mydControl release];
    [_typhoonPicker release];
    [super dealloc];
}

- (void)onClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)onTyphoonQuery:(id)sender {
    NSLog(@"onTyphoonQuery");
    
    if (!isInTyphoonQueryMode) {
        [self.typhoonPicker reloadAllComponents];
        self.typhoonPicker.hidden = NO;
        isInTyphoonQueryMode = YES;
        self.navItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
        self.navItem.rightBarButtonItem.title = @"确定";
    }
    else {
        isInTyphoonQueryMode = NO;
        self.typhoonPicker.hidden = YES;
        self.navItem.rightBarButtonItem.tintColor = [UIColor magentaColor];
        self.navItem.rightBarButtonItem.title = @"查询";
        [self clearWeatherMapView];
        self.typhoonName = currentTyphoonName;
        [self loadTyphoonInfo:currentTyphoonId];
    }
}

#pragma mark -
#pragma mark Picker Data Source Methods
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//	return 2;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    NSArray * yearArray = [self getTyphoonListYearArray];
//	if (component == 0)
//		return [yearArray count];
//	else
//        return currentYearTyphoonRowNum;
//}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.typhoonList count];
    }
    else
        return 0;
}

- (NSArray*)getTyphoonListYearArray
{
    if (!self.typhoonList || [self.typhoonList count] == 0) {
        return nil;
    }
    
    NSLog(@"getTyphoonListYearArray");
    NSMutableArray * yearArray = [[[NSMutableArray alloc] init] autorelease];
    NSString * year = nil;
    NSString * yearItem = nil;
    for (NSDictionary * typhoon in self.typhoonList) {
        yearItem = [[typhoon objectForKey:@"code"] substringToIndex:2];
        if ([yearItem isEqualToString:year]) {
            continue;
        }
        else {
            year = [NSString stringWithString:yearItem];
            [yearArray addObject:[NSString stringWithFormat:@"20%@", yearItem]];
        }
    }
    
    return yearArray;
}

- (NSArray*)getTyphoonListAtYear:(NSString*)year
{
    if (!self.typhoonList || [self.typhoonList count] == 0
        || !year || [year compare:@""] == 0) {
        return nil;
    }
    
    NSLog(@"getTyphoonListAtYear");
    NSString * yearCode = [year substringFromIndex:2];
    NSString * yearItem = nil;
    NSMutableArray * typhoonListAtYear = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary * typhoon in self.typhoonList) {
        yearItem = [[typhoon objectForKey:@"code"] substringToIndex:2];
        if ([yearItem isEqualToString:yearCode]) {
            [typhoonListAtYear addObject:typhoon];
        }
    }
    
    return typhoonListAtYear;
}

- (NSArray*)reversedArray:(NSArray*)array
{
    
    NSMutableArray * revArray = [NSMutableArray arrayWithCapacity:[array count]];
    
    NSEnumerator *enumerator = [array reverseObjectEnumerator];
    
    for (id element in enumerator) {
        [revArray addObject:element];
    }
    
    return revArray;
}

#pragma mark Picker Delegate Methods
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSArray * years = [self reversedArray:[self getTyphoonListYearArray]];
//    if (component == 0)
//    {
//        return years[row];
//    }
//    else
//    {
//        currentYear = years[row];
//        NSArray * typhoonListAtYear = [self reversedArray:[self getTyphoonListAtYear:currentYear]];
//        currentYearTyphoonRowNum = [typhoonListAtYear count];
//        return typhoonListAtYear[row];
//    }
//
//    return nil;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//	if (component == 0)
//	{
//        NSArray * years = [self reversedArray:[self getTyphoonListYearArray]];
//        currentYear = years[row];
//        NSArray * typhoonAtCurrentYear = [self getTyphoonListAtYear:currentYear];
//        currentYearTyphoonRowNum = [typhoonAtCurrentYear count];
//
//		[self.typhoonPicker selectRow:0 inComponent:1 animated:YES];
//		[self.typhoonPicker reloadComponent:1];
//    }
//    else
//    {
//        currentTyphoonRow = row;
//    }
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray * revTyphoonList = [self reversedArray:self.typhoonList];
    return [revTyphoonList[row] objectForKey:@"title"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelect : %d", row);
    NSArray * revTyphoonList = [self reversedArray:self.typhoonList];
    if (revTyphoonList.count == 0) {
        return;
    }
    currentTyphoonId = [revTyphoonList[row] objectForKey:@"code"];
    currentTyphoonName = [revTyphoonList[row] objectForKey:@"title"];
    NSLog(@"didSelect : %d,  Code : %@, Title : %@", row, currentTyphoonId, currentTyphoonName);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (component == 0)
		return [pickerView frame].size.width;
    else {
        return [pickerView frame].size.width;
    }
}

@end
