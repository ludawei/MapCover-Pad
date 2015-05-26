//
//  BaseViewController.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/26.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIViewController *vc = self;
#if 1
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
#else
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
#endif
        {
            vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全屏" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
        }
        else
        {
            vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
            vc.navigationItem.leftItemsSupplementBackButton = YES;
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIViewController *vc = self;
#if 1
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
#else
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
#endif
        {
            vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全屏" style:UIBarButtonItemStyleDone target:self action:@selector(clickRightButton)];
        }
        else
        {
            vc.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
            vc.navigationItem.leftItemsSupplementBackButton = YES;
        }
}

-(void)clickRightButton
{
    UIViewController *vc = self;
    BOOL showFull = [vc.navigationItem.leftBarButtonItem.title isEqualToString:@"全屏"];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (showFull) {
            self.splitViewController.preferredPrimaryColumnWidthFraction = 0;
        }
        else
        {
            self.splitViewController.preferredPrimaryColumnWidthFraction = UISplitViewControllerAutomaticDimension;
        }
    } completion:^(BOOL finished) {
        [vc.navigationItem.leftBarButtonItem setTitle:showFull?@"分屏":@"全屏"];
    }];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.splitViewController.preferredPrimaryColumnWidthFraction = UISplitViewControllerAutomaticDimension;
}

@end
