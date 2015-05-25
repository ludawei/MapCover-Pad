//
//  CityMapViewController.m
//  中国天气通
//
//  Created by Sam Chen on 11/9/12.
//
//

#import "CityMapViewController.h"
//#import "StatAgent.h"
//#import "AppDelegate.h"

@interface CityMapViewController ()

@end

@implementation CityMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Setup the Toolbar
    [self setupToolBar];
    
    self.weatherMapView.mapType = MKMapTypeHybrid;
    
    self.titleLabel.text = @"周边城市天气";
    NSLog(@"Type : %@, Params : %@", self.requestType, self.requestParams);
    
    self.makeAnnotationsLock = NO;
    self.weatherAnnotations = [[[NSMutableArray alloc] init] autorelease];
    self.weatherInfos = [[[NSMutableDictionary alloc] init] autorelease];
    self.cityLocations = [[[WCCityLocations alloc] init] autorelease];
    
    //AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    NSString * lastLocation = nil;//[myAppDelegate.userSettings.settings objectForKey:@"lastLocation"];
    
    CLLocationCoordinate2D loc;
    if ([lastLocation compare:@""] != 0 || lastLocation != nil) {
        NSArray * locArray = [lastLocation componentsSeparatedByString:@"|"];
        loc = CLLocationCoordinate2DMake([locArray[0] floatValue], [locArray[1] floatValue]);
    }
    else {
        loc = CLLocationCoordinate2DMake(40.0,116.0);
    }
    
    self.weatherMapView.delegate = self;
    
    [self gotoLocation:loc];
    self.weatherMapView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupToolBar
{
    if (self.navigationController == nil) {
        CGRect frame = self.weatherMapView.frame;
        frame.origin.y = 44;
        self.weatherMapView.frame = frame;
        
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"title_bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    else {
        [self.toolBar removeFromSuperview];
    }
}

- (int)makeCityLevel:(MKCoordinateSpan)span
{
    float latDelta = span.latitudeDelta;
    int cityLevel = 1;
    if (latDelta < 1) {
        cityLevel = 3;
    }
    else if (latDelta >= 1 && latDelta < 3) {
        cityLevel = 2;
    }
    else if (latDelta > 3) {
        cityLevel = 1;
    }
    
    return cityLevel;
    //return 1;
}

- (void)makeAnnotations:(CLLocationCoordinate2D)loc regionSpan:(MKCoordinateSpan)span cityLevel:(int)level
{
    if (self.makeAnnotationsLock == YES) {
        return;
    }
    self.makeAnnotationsLock = YES;
    
    if (level <= 0 || level >= 4) {
        return;
    }
    
    if (span.latitudeDelta == 0 || span.longitudeDelta == 0) {
        return;
    }
    
    float latLow = loc.latitude - span.latitudeDelta / 2;
    float latHigh = loc.latitude + span.latitudeDelta / 2;
    float longLow = loc.longitude - span.longitudeDelta / 2;
    float longHigh = loc.longitude + span.longitudeDelta / 2;
    //NSLog(@"&&&& === %f, %f, %f, %f", latLow, latHigh, longLow, longHigh);
    
    if ([self.weatherAnnotations count] > 0) {
        [self.weatherAnnotations removeAllObjects];
    }
    
//    NSString * cityDataPath = [[NSBundle mainBundle] pathForResource:@"city_location" ofType:@"csv"];
//    NSString * cityData = [NSString stringWithContentsOfFile:cityDataPath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSArray * lines = [cityData componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    
    NSArray * lines = self.cityLocations.cityLocations;
    NSArray * cityLineArray;
    float latitude, longitude;
    int cityLevel;
    //int i = 0;
    for (NSString * line in lines) {
        cityLineArray = [line componentsSeparatedByString:@","];
        if ([cityLineArray count] < 6) {
            continue;
        }
        longitude = [cityLineArray[2] floatValue];
        latitude = [cityLineArray[3] floatValue];
        cityLevel = [cityLineArray[5] intValue];
        
        if (longitude <= longLow) {
            continue;
        }
        if (longitude >= longHigh) {
            break;
        }
        
        if (cityLevel <= level
            //&& longitude < longHigh
            //&& longitude > longLow
            && latitude < latHigh
            && latitude > latLow) {
            if ([self.weatherInfos objectForKey:cityLineArray[0]] == nil) {
                WeatherAnnotation * ann = [[[WeatherAnnotation alloc] init] autorelease];
                ann.cityId = cityLineArray[0];
                ann.cityName = cityLineArray[1];
                ann.longitude = longitude;
                ann.latitude = latitude;
                [ann getWeatherInfo];
                ann.cityWeatherInfoString = @"";
                [self.weatherAnnotations addObject:ann];
                [self.weatherInfos setObject:ann forKey:cityLineArray[0]];
                //NSLog(@"+++++++ Add node ++++++++");
            }
            else {
                WeatherAnnotation * ann = [self.weatherInfos objectForKey:cityLineArray[0]];
                if ([ann.cityWeatherInfoString isEqualToString:@""]) {
                    [ann getWeatherInfo];
                }
                else if ([self isWeatherAnnotationOutOfDate:ann
                                              withInSeconds:DEFAULT_WEATHER_ANNOTATION_UPDATE_TIMEINTERVAL]) {
                    [ann getWeatherInfo];
                }
                [self.weatherAnnotations addObject:ann];
                //NSLog(@"------ Use node ---------");
            }
        }
        //i++;
    }
    
    self.makeAnnotationsLock = NO;
}

- (BOOL)isWeatherAnnotationOutOfDate:(WeatherAnnotation *)ann withInSeconds:(NSUInteger)seconds
{
    if (ann.lastUpdated == nil) {
        return YES;
    }
    NSDate * now = [NSDate dateWithTimeIntervalSinceNow:0.0f];
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:ann.lastUpdated];

    if (timeInterval > seconds) {
        return YES;
    }
    else {
        return NO;
    }
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //NSLog(@"**** === %f, %f, %f, %f", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    
    [self.weatherMapView removeAnnotations:self.weatherAnnotations];
    int cityLevel = [self makeCityLevel:mapView.region.span];
    [self makeAnnotations:mapView.region.center regionSpan:mapView.region.span cityLevel:cityLevel];
    [self.weatherMapView addAnnotations:self.weatherAnnotations];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Anno Callout Accessory Tapped");
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //NSLog(@"didAddAnno");
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //NSLog(@"-------- viewForAnnotation!");
    //MKAnnotationView * v = nil;
    WeatherAnnotationView * v = nil;
    
    static NSString * ident = @"greenPin";
    v = (WeatherAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ident];
    if (v == nil) {
        //            v = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
        //                                                 reuseIdentifier:ident]
        //                                                autorelease];
        //            ((MKPinAnnotationView*)v).pinColor = MKPinAnnotationColorGreen;
        //            ((MKPinAnnotationView*)v).animatesDrop = YES;
        //[((MKPinAnnotationView*)v) setImage:[UIImage imageNamed:@"city_book.png"]];
        v = [[[WeatherAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ident] autorelease];
        WeatherAnnotation * ann = (WeatherAnnotation*)v.annotation;
        ann.displayDelegate = v;
        v.canShowCallout = YES;
        //[v setNeedsDisplay];
        //((MKPinAnnotationView*)v)
    }
    else {
        v.annotation = annotation;
        WeatherAnnotation * ann = (WeatherAnnotation*)annotation;
        ann.displayDelegate = v;
        [v setNeedsDisplay];
    }
    
    return v;
}

- (void)viewDidAppear:(BOOL)animated
{
    // StatAgent
//    [StatAgent onResume:@"MapServiceView"];
    //AppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
    //myAppDelegate.currentServiceId = self.serviceId;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    for (WeatherAnnotation * ann in self.weatherAnnotations) {
//        ann.taskControl.displayDelegate = nil;
//    }
    
    // StatAgent
//    [StatAgent onPause:self.serviceId];
}

- (void)viewDidUnload
{
    for (WeatherAnnotation * ann in self.weatherAnnotations) {
        ann.taskControl.displayDelegate = nil;
    }
    [self setToolBar:nil];
    [self setWeatherMapView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    for (WeatherAnnotation * ann in self.weatherAnnotations) {
        ann.taskControl.displayDelegate = nil;
    }
    [_weatherMapView release];
    [_requestType release];
    [_requestParams release];
    [_serviceId release];
    [_toolBarTitleString release];
    [_weatherAnnotations release];
    [_weatherInfos release];
    [_cityLocations release];
    [super dealloc];
}

- (IBAction)onClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
