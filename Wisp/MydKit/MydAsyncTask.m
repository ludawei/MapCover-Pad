//
//  MydAsyncTask.m
//  MydKit
//
//  Created by Sam Chen on 10/20/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MydAsyncTask.h"
#import "HTTPHandler.h"
#import "HTTPHosts.h"

@implementation MydAsyncTask

- (NSString *)doInBackground:(NSArray *)params
{
    @try
    {
        NSString * mydURL = [self makeMydURL:params];

        HTTPHandler * manager = [[[HTTPHandler alloc] init] autorelease];
        NSURL * url = [NSURL URLWithString:mydURL];
        self.m_connection = [manager HTTPConnect:self withUrl:url isGet:TRUE content:nil length:0];
        
        NSLog(@"MYD URL : %@", mydURL);
        return nil;
    }
    @catch (NSException * e)
    {
        return (NSString *)MYD_ERROR;
    }
}

- (void)postExecute:(NSData*)result
{
    @try
    {
        int len = result.length;
        if (len > 0)
        {
            [self onPostExecute:[NSData dataWithBytes:(const char*)[result bytes] length:len]];
        }
        else
            [self onPostExecute:nil];
    }
    @catch (NSException * e)
    {
        [self onPostExecute:nil];
    }
}

- (NSString *)makeMydURL:(NSArray *)params
{
    @try {
        int argc = [params count];
        NSString * mydType = nil;
        
        if (argc >= 2)
        {
            mydType = [params objectAtIndex:0];   
        }
        if (argc < 2 ||
            mydType == nil || [mydType compare: @""] == 0)
            return (NSString *)MYD_ERROR;
        
        NSString * mydURL = nil;
        if ([mydType compare:(NSString*)MYD_SURROUNDINGS_CITY] == 0) {
            NSString * cityId = [params objectAtIndex:1];
            if (cityId == nil || [cityId compare: @""] == 0) {
                return (NSString *)MYD_ERROR;
            }
            mydURL = [NSString stringWithFormat:@"%@%@.myd", (NSString *)HTTP_HOST_SURROUNDINGS, cityId];
        }
        else if ([mydType compare:(NSString*)MYD_TYPHOON_LIST] == 0) {
            NSString * year = [params objectAtIndex:1];
            if (year == nil || [year compare: @""] == 0) {
                return (NSString *)MYD_ERROR;
            }
            //mydURL = [NSString stringWithFormat:@"%@%@/taifeng.myd", (NSString *)HTTP_HOST_TYPHOON_LIST, year];
            mydURL = [NSString stringWithFormat:@"%@taifeng.myd", (NSString *)HTTP_HOST_TYPHOON_LIST];
        }
        else if ([mydType compare:(NSString*)MYD_TYPHOON] == 0) {
            NSString * typhoonId = [params objectAtIndex:1];
            if (typhoonId == nil || [typhoonId compare: @""] == 0) {
                return (NSString *)MYD_ERROR;
            }
            mydURL = [NSString stringWithFormat:@"%@%@.myd", (NSString *)HTTP_HOST_TYPHOON, typhoonId];
        }
        else if ([mydType compare:(NSString*)MYD_TYPHOON_INCPOINTS] == 0) {
            NSString * typhoonId = [params objectAtIndex:1];
            if (typhoonId == nil || [typhoonId compare: @""] == 0) {
                return (NSString *)MYD_ERROR;
            }
            mydURL = [NSString stringWithFormat:@"%@IncPoint%@.myd", (NSString *)HTTP_HOST_TYPHOON_INCPOINTS, typhoonId];
        }
        else if ([mydType compare:(NSString*)MYD_RADAR_LIST] == 0) {
            mydURL = (NSString *)HTTP_HOST_RADAR_LIST;
        }
        else if ([mydType compare:(NSString*)MYD_RADAR] == 0) {
            NSString * radarURL = [params objectAtIndex:1];
            if (radarURL == nil || [radarURL compare: @""] == 0) {
                return (NSString *)MYD_ERROR;
            }
            mydURL = [NSString stringWithFormat:@"%@%@", (NSString *)HTTP_HOST_RADAR, radarURL];
        }
        
        return mydURL;
    }
    @catch (NSException *exception) {
        return (NSString *)MYD_ERROR;
    }
    
}

@end
