//
//  CWHttpCmdWeather.h
//  ChinaWeather
//
//  Created by davlu on 7/5/13.
//  Copyright (c) 2013 Platomix. All rights reserved.
//

#import "PLHttpCmd.h"

@interface CWHttpCmdWeather : PLHttpCmd

@property (nonatomic, strong) NSArray *cityIds;

@end


static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey_dav";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
