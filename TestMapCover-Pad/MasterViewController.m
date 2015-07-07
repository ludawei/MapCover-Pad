//
//  MasterViewController.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/21.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <MapKit/MapKit.h>

#import "DetailViewController1.h"
#import "CWEyeMapController.h"
#import "CWWindMapController.h"
#import "MapAnimController.h"
#import "OtherMapController.h"
#import "TyphoonMapViewController.h"

#import "OtherMapController.h"

@interface MasterViewController ()

@property NSDictionary *datas;
@property NSArray *dataSections;
@property (nonatomic,strong) MKMapView *mapView;
@property (strong, nonatomic) UIViewController *detailViewController;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.title = @"产品列表";
    
    self.mapView = [MKMapView new];
    
    [self initData];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换地图" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightBarButton)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoti:) name:@"changeItem" object:nil];
}

-(void)receiveNoti:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSIndexPath *indexPath = [userInfo objectForKey:@"indexPath"];
    
    if (!indexPath) {
        return;
    }
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    NSString *key = [self.dataSections objectAtIndex:indexPath.section];
    NSString *text = [[self.datas objectForKey:key] objectAtIndex:indexPath.row];
    UIViewController *vc = nil;
    if ([text isEqualToString:@"等风来"]) {
        CWWindMapController *next = [CWWindMapController new];
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
//
        vc = next;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self showDetailViewController:nav sender:nil];
    self.detailViewController = vc;
}

-(void)clickRightBarButton
{
    if (self.mapView.mapType == MKMapTypeStandard) {
        self.mapView.mapType = MKMapTypeHybrid;
    }
    else
    {
        self.mapView.mapType = MKMapTypeStandard;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MapDatas" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    self.datas = data;
    self.dataSections = data.allKeys;
}
//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

-(void)clearMapView
{
    self.mapView.alpha = 1.0;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
}

//-(void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    
//    UIViewController *vc = self.detailViewController;
//#if 1
//    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
//#else
//        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
//#endif
//    {
//        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全屏" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
//    }
//    else
//    {
//        vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        vc.navigationItem.leftItemsSupplementBackButton = YES;
//    }
//}
//
//-(void)clickRightButton
//{
//    UIViewController *vc = self.detailViewController;
//    BOOL showFull = [vc.navigationItem.leftBarButtonItem.title isEqualToString:@"全屏"];
//    
//    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        if (showFull) {
//            self.splitViewController.preferredPrimaryColumnWidthFraction = 0;
//        }
//        else
//        {
//            self.splitViewController.preferredPrimaryColumnWidthFraction = UISplitViewControllerAutomaticDimension;
//        }
//    } completion:^(BOOL finished) {
//        [vc.navigationItem.leftBarButtonItem setTitle:showFull?@"分屏":@"全屏"];
//    }];
//}

#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = self.objects[indexPath.row];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        [self clearMapView];
//        controller.mapView = self.mapView;
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataSections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.dataSections objectAtIndex:section];
    return [[self.datas objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *key = [self.dataSections objectAtIndex:indexPath.section];
    NSString *text = [[self.datas objectForKey:key] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = text;
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView indexPathForSelectedRow] isEqual:indexPath]) {
        return nil;
    }
    
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.dataSections objectAtIndex:indexPath.section];
    NSString *text = [[self.datas objectForKey:key] objectAtIndex:indexPath.row];
    
    UIViewController *vc = nil;
    if ([key isEqualToString:@"mapJson"]) {
        DetailViewController *controller = [DetailViewController new];
        [controller setDetailItem:text];
        [self clearMapView];
        controller.mapView = self.mapView;
        
        vc = controller;
    }
    else if ([text isEqualToString:@"全球温度预报"]) {
        DetailViewController1 *controller = [DetailViewController1 new];
        controller.detailItem = text;
        [self clearMapView];
        controller.mapView = self.mapView;
        
        vc = controller;
    }
    else if ([text isEqualToString:@"全国雷达"]) {
        MapAnimController *next = [MapAnimController new];
        next.type = 0;
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
        
        vc = next;
    }
    else if ([text isEqualToString:@"全国云图"]) {
        MapAnimController *next = [MapAnimController new];
        next.type = 1;
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
        
        vc = next;
    }
    else if ([text isEqualToString:@"等风来"]) {
        CWWindMapController *next = [CWWindMapController new];
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
        
        vc = next;
    }
    else if ([text isEqualToString:@"实景天气"]) {
        CWEyeMapController *next = [CWEyeMapController new];
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
        
        vc = next;
    }
    else if ([text isEqualToString:@"台风路径"])
    {
        TyphoonMapViewController *viewController = [[TyphoonMapViewController alloc] initWithNibName:@"TyphoonMapView" bundle:nil];
        [viewController setRequestType:@""];
        viewController.title = text;
        
//        [viewController setRequestParams:data[@"l3"]];
        vc = viewController;

    }
    else if ([text isEqualToString:@"全国温度实况"])
    {
        OtherMapController *next = [OtherMapController new];
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
        next.isShowTemp = YES;
        
        vc = next;
    }
    else if ([text isEqualToString:@"天气统计"])
    {
        OtherMapController *next = [OtherMapController new];
        next.title = text;
        [self clearMapView];
        next.mapView = self.mapView;
        
        vc = next;
    }
    
    if (vc) {
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self showDetailViewController:nav sender:nil];
        self.detailViewController = vc;
        
//#if 1
//        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
//#else
//        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
//#endif
//        {
//            vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全屏" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
//        }
//        else
//        {
//            vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//            vc.navigationItem.leftItemsSupplementBackButton = YES;
//        }
    }
    
}

//-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    self.splitViewController.preferredPrimaryColumnWidthFraction = UISplitViewControllerAutomaticDimension;
//}

@end
