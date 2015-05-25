//
//  MydAsyncTask.h
//  MydKit
//
//  Created by Sam Chen on 10/20/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "HTTPAsyncTask.h"

//const NSString * MYD_SURROUNDINGS_CITY = @"CITY";
//const NSString * MYD_TYPHOON = @"TYPH";
//const NSString * MYD_RADAR_LIST = @"RALI";
//const NSString * MYD_RADAR = @"RADA";

#define MYD_SURROUNDINGS_CITY @"CITY"
#define MYD_TYPHOON_LIST @"TYLI"
#define MYD_TYPHOON @"TYPH"
#define MYD_TYPHOON_INCPOINTS @"TYIP"
#define MYD_RADAR_LIST @"RALI"
#define MYD_RADAR @"RADA"

@interface MydAsyncTask : HTTPAsyncTask
{
    
}

- (NSString *)doInBackground:(NSArray *)params;

- (void)postExecute:(NSData *)result;

@end
