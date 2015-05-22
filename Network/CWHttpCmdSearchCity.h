//
//  CWHttpCmdSearchCity.h
//  chinaweathernews
//
//  Created by 卢大维 on 14-11-6.
//  Copyright (c) 2014年 weather. All rights reserved.
//

#import "PLHttpCmd.h"

@interface CWHttpCmdSearchCity : PLHttpCmd

@property (nonatomic, strong) NSString *nameZh;     // 城市中文名称
@property (nonatomic, strong) NSString *nameEn;     // 城市英文名称
@property (nonatomic, strong) NSString *areaId;     // 区域编号
@property (nonatomic, strong) NSString *postCode;   // 邮编
@property (nonatomic, strong) NSString *telCode;    // 区号
@property (nonatomic, strong) NSString *keyWord;    // 关键字
@property (nonatomic, assign) NSUInteger start;     // 每页起始条数
@property (nonatomic, assign) NSUInteger limit;     // 每页显示多少条

@end
