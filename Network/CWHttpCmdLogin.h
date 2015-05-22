//
//  CWHttpCmdLogin.h
//  ChinaWeather
//
//  Created by lou on 13-7-31.
//  Copyright (c) 2013年 Platomix. All rights reserved.
//

#import "PLHttpCmd.h"

@interface CWHttpCmdLogin : PLHttpCmd

@property (nonatomic, strong) NSString *username; // 用户名 必填
@property (nonatomic, strong) NSString *password; // 密码 必填

@end
