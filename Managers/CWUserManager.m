//
//  CWUserManager.m
//  chinaweathernews
//
//  Created by 卢大维 on 14-11-17.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "CWUserManager.h"
#import "CWDataManager.h"

static NSString *ISLOGINED = @"isLogined";
static NSString *USERNAME = @"userName";
static NSString *PASSWORD = @"password";

static NSString *USERID = @"userId";

@implementation CWUserManager

+ (CWUserManager *)sharedInstance
{
    static CWUserManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}
-(id) init
{
    self = [super init];
    if(self)
    {
//        self.storyName = self.isLogined?@"NoLogin":@"Login";
    }
    return self;
}


-(BOOL)isLogined
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ISLOGINED];
}

-(void)setIsLogined:(BOOL)isLogined
{
    [[NSUserDefaults standardUserDefaults] setBool:isLogined forKey:ISLOGINED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)userName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
}

-(void)setUserName:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)pass
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
}

-(void)setPass:(NSString *)pass
{
    [[NSUserDefaults standardUserDefaults] setObject:pass forKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)uid
{
    NSString *uid = [[CWDataManager sharedInstance].userDict objectForKey:@"uId"];
    if (uid && uid.length>0) {
        return uid;
    }
    
    return @"";
}

-(NSString *)userId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
}

-(void)setUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
