//
//  WebController.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-10-20.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebController : UIViewController

@property (nonatomic,strong) NSDictionary *info;
@property (nonatomic,assign) BOOL hideCollButton;
@property (nonatomic,assign) BOOL isIdleTimerDisabled;

@end
