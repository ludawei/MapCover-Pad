//
//  MyAnnotation.h
//  chinaweathernews
//
//  Created by 卢大维 on 15/10/14.
//  Copyright © 2015年 weather. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : MKPointAnnotation

@property (nonatomic,copy) NSString *imageTag;
@property (nonatomic,copy) NSString *warnId;
@property (nonatomic,copy) NSString *warnUrl;

// use for typhoon
@property (nonatomic,copy) NSString *pointType;
@property (nonatomic,copy) NSArray *typhoonInfo;
@property (nonatomic,assign) BOOL isHeader;

@end
