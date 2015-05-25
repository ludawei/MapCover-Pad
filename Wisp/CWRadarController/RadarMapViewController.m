//
//  RadarMapViewController.m
//  中国天气通
//
//  Created by Sam Chen on 11/10/12.
//
//

#import "RadarMapViewController.h"
#import "MBundle.h"
#import "RadarPolygonView.h"
//#import "StatAgent.h"
//#import "AppDelegate.h"

const float latitudeDelta = 3.0;
const float longitudeDelta = 2.5;

@interface RadarMapViewController ()

@end

@implementation RadarMapViewController
{
@private
    NSString * solidFillStyleStr;
    int rainLevel;
    NSString * MYDFileType;
}

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
    
    self.titleLabel.text = @"降水图";
    self.timeStampLabel.hidden = YES;
    
    NSLog(@"Type : %@, Params : %@", self.requestType, self.requestParams);
    NSArray * params = [self.requestParams componentsSeparatedByString:@"&"];
    NSArray * range;
    MKCoordinateRegion region;
    BOOL isGetRegionOk = NO;
    for (NSString * param in params) {
        if ([[param substringToIndex:5] compare:@"range"] == 0) {
            range = [[[param componentsSeparatedByString:@"="] objectAtIndex:1] componentsSeparatedByString:@"|"];
            region = [self makeMKMapRegionByLonLow:[range[0] doubleValue]
                                                              lonHigh:[range[2] doubleValue]
                                                               latLow:[range[1] doubleValue]
                                                              latHigh:[range[3] doubleValue]];
            isGetRegionOk = YES;
            break;
        }
    }
    
    self.weatherMapView.delegate = self;
    
    if (isGetRegionOk) {
        [self gotoRegion:region];
    }
    else {
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(40.0,116.0);
        [self gotoLocation:loc];
    }

    self.weatherMapView.hidden = NO;
    
    //Init MydControl
    self.mydControl = [[[WCMydTaskControl alloc] init] autorelease];
    
    //Add Radar Data
    [self loadRadarList];
}

- (void)setupToolBar
{
    if (self.navigationController == nil) {
        CGRect frame = self.weatherMapView.frame;
        frame.origin.y = 44;
        self.weatherMapView.frame = frame;
        
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"title_bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self displayToolBarTitle];
    }
    else {
        [self.toolBar removeFromSuperview];
        
        CGRect frame = self.timeStampLabel.frame;
        //NSLog(@"Frame : %f, %f", frame.origin.x, frame.origin.y);
        frame.origin.y -= 44;
        //NSLog(@"Frame : %f, %f", frame.origin.x, frame.origin.y);
        self.timeStampLabel.frame = frame;
    }
}

- (void)displayToolBarTitle
{
    self.toolBarTitle.title = self.toolBarTitleString;
}

//- (void)loadRadarList
//{
//    WCMydAsyncTask * myd = [[[WCMydAsyncTask alloc] init] autorelease];
//    
//    //NSArray * params = @[MYD_TYPHOON, @"2012"];
//    NSArray * params = @[MYD_RADAR_LIST, @"leida"];
//    MYDFileType = MYD_RADAR_LIST;
//    [myd setListener:self];
//    [myd execute:params];
//}
//
//- (void)loadRadar:(NSString *)radarFileName
//{
//    WCMydAsyncTask * myd = [[[WCMydAsyncTask alloc] init] autorelease];
//
//    //NSArray * params = @[MYD_RADAR, @"ACHN.QREF000.20121108.112000.myd"];
//    NSArray * params = @[MYD_RADAR, radarFileName];
//    MYDFileType = MYD_RADAR;
//    
//    [myd setListener:self];
//    [myd execute:params];
//}

- (void)loadRadarList
{
    NSArray * params = @[MYD_RADAR_LIST, @"leida"];
    MYDFileType = MYD_RADAR_LIST;
    
    self.mydControl.displayDelegate = self;
    [self.mydControl getMydFromServer:params];
}

- (void)loadRadar:(NSString *)radarFileName
{
    //NSArray * params = @[MYD_RADAR, @"ACHN.QREF000.20121108.112000.myd"];
    NSArray * params = @[MYD_RADAR, radarFileName];
    MYDFileType = MYD_RADAR;
    
    self.mydControl.displayDelegate = self;
    [self.mydControl getMydFromServer:params];
}

- (void)displayMydData:(id)result taskControl:(id)taskControl
//- (void)onTriggered:(id)result
{
    @try {
        MBundle * bundle = [[[MBundle alloc] init] autorelease];
        [bundle getBundle:(NSData*)result];
        
        if (bundle.fileType == TEXT_FILE && [MYDFileType compare:MYD_RADAR_LIST] == 0) {
            MText * mText = (MText *)bundle.tags[0];
            //NSLog(@"################# ret : %@ ############### len : %d, %d", mText.text, mText.tagLen, mText.text.length);

            NSXMLParser * xmlparser = [[NSXMLParser alloc] initWithData:[mText.text dataUsingEncoding:NSUTF8StringEncoding]];
            [xmlparser setDelegate:self];
            BOOL isXMLParseOK = [xmlparser parse];
            if (!isXMLParseOK) {
                NSLog(@"XML Parse Error : %@", [xmlparser parserError]);
                return;
            }
            
        }
        else if (bundle.fileType == SHAPE_FILE && [MYDFileType compare:MYD_RADAR] == 0) {
            int index = 0;
            for (id i in bundle.tagsTypes) {
                //NSLog(@"%d", [i intValue]);
                if ([i intValue] == MLineStringTag){ // = 2
                    MLineString * tagMLineString = (MLineString *)bundle.tags[index];
                    //NSLog(@"---------MLineString----------");
                    //NSLog(@"%d", tagMLineString.pointNumber);
                    
                    if (tagMLineString.pointXs[0] == tagMLineString.pointXs[tagMLineString.pointNumber-1]
                        && tagMLineString.pointYs[0] == tagMLineString.pointYs[tagMLineString.pointNumber-1]) {
                        
                        CLLocationCoordinate2D * points = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * (tagMLineString.pointNumber - 1));
                        for (int j=0; j < tagMLineString.pointNumber-1; j++) {
                            CLLocationCoordinate2D pLoc = CLLocationCoordinate2DMake((double)tagMLineString.pointYs[j] / bundle.header.dataScale, (double)tagMLineString.pointXs[j] / bundle.header.dataScale);
                            //NSLog(@"%f, %f", (float)tagMLineString.pointXs[j] / bundle.header.dataScale, (float)tagMLineString.pointYs[j] / bundle.header.dataScale);
                            points[j] = pLoc;
                        }
                        MKPolygon* polygon = [MKPolygon polygonWithCoordinates:points count:tagMLineString.pointNumber-1];
                        
                        polygon.subtitle = solidFillStyleStr;
                        [self.weatherMapView addOverlay:polygon];
                        free(points);
                    }
                    else {
                        NSLog(@"--- ???????? MLineString ????????---");
                    }
                    
                }
                else if ([i intValue] == MSolidFillStyleTag) { // = 5
                    MSolidFillStyle * tagMSolidFillStyle= (MSolidFillStyle *)bundle.tags[index];
                    NSLog(@"-------MSolidFillStyle------------");
                    //NSLog(@"tagColor : %d, %d, %d, %d  width : %d", tagMSolidFillStyle.color.red, tagMSolidFillStyle.color.green, tagMSolidFillStyle.color.blue, tagMSolidFillStyle.color.alpha, tagMSolidFillStyle.width);
                    
                    rainLevel++;
                    solidFillStyleStr = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d",
                                         tagMSolidFillStyle.color.red,
                                         tagMSolidFillStyle.color.green,
                                         tagMSolidFillStyle.color.blue,
                                         tagMSolidFillStyle.color.alpha,
                                         tagMSolidFillStyle.width,rainLevel];
                }
                else if ([i intValue] == MTextTag) { // = 3
                    MText * tagMText = (MText *)bundle.tags[index];
                    NSLog(@"--------MText-----------");
                    NSLog(@"%@", tagMText.text);
                    self.timeStamp = tagMText.text;
                    [self displayTimeStamp];
                }
                index++;
            }
        }
    }
    @catch (NSException* e) {
        NSLog(@"onTriggered meet exception...");
    }

}

- (void)gotoLocation:(CLLocationCoordinate2D)loc
{
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //NSLog(@"**** === %f, %f, %f, %f", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}

//- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    MKPolygonView* v = nil;
//    if ([overlay isKindOfClass:[MKPolygon class]]) {
//        v = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay]
//             autorelease];
//        
//        MKPolygon * polygon = (MKPolygon *)overlay;
//        NSArray * infoArray = [polygon.subtitle componentsSeparatedByString:@","];
//        
//        
//        UIColor * color = [UIColor colorWithRed:[infoArray[0] floatValue] / 256
//                                          green:[infoArray[1] floatValue] / 256
//                                           blue:[infoArray[2] floatValue] / 256
//                                          alpha:[infoArray[3] floatValue] / 256];
//        v.fillColor = [color colorWithAlphaComponent:0.6];
//        v.strokeColor = [color colorWithAlphaComponent:0.2];;
//        v.lineWidth = [infoArray[4] intValue];
//        
////        NSLog(@"=============Overlay===========");
////        NSLog(@"%d", polygon.pointCount);
////        CLLocationCoordinate2D pLoc;
////        CGPoint pView;
////        for (int i = 0; i < polygon.pointCount; i++) {
////            //NSLog(@"%f, %f", polygon.points[i].x, polygon.points[i].y);
////            pLoc = MKCoordinateForMapPoint(polygon.points[i]);
////            pView = [mapView convertCoordinate:pLoc toPointToView:self.view];
////            NSLog(@"%f, %f", pView.x, pView.y);
////        }
//        
//    }
//    return v;
//}

- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    RadarPolygonView * v = nil;
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        v = [[[RadarPolygonView alloc] initWithOverlay:overlay]
             autorelease];
        
        MKPolygon * polygon = (MKPolygon *)overlay;
        NSArray * infoArray = [polygon.subtitle componentsSeparatedByString:@","];
        
        
        UIColor * color = [UIColor colorWithRed:[infoArray[0] floatValue] / 256
                                          green:[infoArray[1] floatValue] / 256
                                           blue:[infoArray[2] floatValue] / 256
                                          alpha:[infoArray[3] floatValue] / 256];
        v.fillColor = [color colorWithAlphaComponent:0.6];
        v.strokeColor = [color colorWithAlphaComponent:0.2];;
        v.lineWidth = [infoArray[4] intValue];
    }
    return v;
}

//- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    MKPolygonView * v = nil;
//    if ([overlay isKindOfClass:[MKPolygon class]]) {
//        v = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay]
//             autorelease];
//        
//        MKPolygon * polygon = (MKPolygon *)overlay;
//        NSArray * infoArray = [polygon.subtitle componentsSeparatedByString:@","];
//        
//        
//        UIColor * color = [UIColor colorWithRed:[infoArray[0] floatValue] / 256
//                                          green:[infoArray[1] floatValue] / 256
//                                           blue:[infoArray[2] floatValue] / 256
//                                          alpha:[infoArray[3] floatValue] / 256];
//        v.fillColor = [color colorWithAlphaComponent:0.6];
//        v.strokeColor = [color colorWithAlphaComponent:0.2];;
//        v.lineWidth = [infoArray[4] intValue];
//    }
//    return v;
//}

- (void)displayTimeStamp
{
    self.timeStampLabel.text = self.timeStamp;
    self.timeStampLabel.hidden = NO;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.radarList = [[[NSMutableArray alloc] init] autorelease];
    self.timeStamp = [[[NSString alloc] init] autorelease];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"leidaProps"]) {
        NSString * radarFileName = [attributeDict objectForKey:@"data"];
        [self.radarList addObject:radarFileName];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//    for (NSString * i in self.radarList) {
//        NSLog(@"radar : %@", i);
//    }
    int fileCount = [self.radarList count];
    if (fileCount > 0) {
        NSString * radarFileName = [self.radarList objectAtIndex:fileCount - 1];
        [self loadRadar:radarFileName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.mydControl.displayDelegate = nil;
    
    // StatAgent
//    [StatAgent onPause:self.serviceId];
}

- (void)viewDidUnload
{
    [self setToolBar:nil];
    [self setToolBarTitle:nil];
    [self setWeatherMapView:nil];
    [self setTimeStampLabel:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    [_weatherMapView release];
    [_requestType release];
    [_requestParams release];
    [_serviceId release];
    [_toolBarTitleString release];
    [_radarList release];
    [_timeStamp release];
    [_timeStampLabel release];
    [_mydControl release];
    [super dealloc];
}

- (IBAction)onClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
