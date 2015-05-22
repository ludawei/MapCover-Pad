//
//  CWUserManager.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-11-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWUserManager : NSObject

@property (nonatomic) BOOL isLogined;
//@property (nonatomic,copy) NSString *storyName;

@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *pass;
@property (readonly,copy) NSString *uid;
@property (readwrite) NSString *userId;

@property (nonatomic,copy) NSString *lat;
@property (nonatomic,copy) NSString *lon;

+ (CWUserManager *)sharedInstance;

@end
