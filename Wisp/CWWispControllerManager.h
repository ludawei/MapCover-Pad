//
//  CWWispControllerManager.h
//  ChinaWeather
//
//  Created by platomix on 13-8-20.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//


//GS模块  单例   

#import <Foundation/Foundation.h>

@interface CWWispControllerManager : NSObject
@property (strong, nonatomic) NSString *wispControllerClassName;
@property (strong, nonatomic) NSString *wispControllerViewName;
@property (strong, nonatomic) NSString *urlString;
+(id)shardWispManager;
//-(id)initWithUrlStr:(NSString *)str;

-(UIViewController *)responseControllerFromDataProcessWithTitle:(NSString *)title;


@end
