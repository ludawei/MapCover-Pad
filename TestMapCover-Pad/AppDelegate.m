//
//  AppDelegate.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/21.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;
    
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"china_1" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    
//    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//    
//    NSArray *dataArr = [data objectForKey:@"features"];
//    NSMutableArray *mutableArray = [NSMutableArray array];
//    for(NSInteger i=0; i<dataArr.count; i++)
//    {
//        NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:[dataArr objectAtIndex:i]];
//        NSArray *cp = [[md objectForKey:@"properties"] objectForKey:@"cp"];
//        NSString *name = [[md objectForKey:@"properties"] objectForKey:@"cname"];
//        
//        [mutableArray addObject:@{@"name":name, @"level":@"2", @"cp": cp}];
//    }
//    
//    NSData *jsData = [NSJSONSerialization dataWithJSONObject:mutableArray options:0 error:nil];
//    NSString *jsStr = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
//    
//    NSString *tmp = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.json"];
//    
//    [jsStr writeToFile:tmp atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[DetailViewController class]] && ([(DetailViewController *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

//-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc

@end
