//
//  HTTPAsyncTask.m
//  MydKit
//
//  Created by Sam Chen on 11/20/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "HTTPAsyncTask.h"

@implementation HTTPAsyncTask

@synthesize m_connection;
@synthesize m_result;

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
    if (!self.m_result) {
        self.m_result = [[NSMutableData alloc] init];
    }
    [self.m_result appendData: data];
    self->m_hasData = TRUE;
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
    self.m_connection = nil;
    //    NSLog(@"本次请求结果 %@", self->m_hasData ? @"有数据" : @"无数据");
    [self postExecute: self.m_result];
    [self.m_result release];
    self.m_result = nil;
}

- (void) connection:(NSURLConnection*) connection didFailWithError: (NSError*) error
{
    self.m_connection = nil;
    //    NSLog(@"本次请求结果出错 %@", error);
    [self postExecute: self.m_result];
    [self.m_result release];
    self.m_result = nil;
}

- (BOOL) execute: (NSArray*) params
{
    if (self.m_connection == nil)
    {
        [self onPreExecute];
        
        self.m_result = [[NSMutableData alloc] init];
        self->m_hasData = FALSE;
        
        NSString* result = [self doInBackground: params];
        if (result != nil)
        {
            if ([result compare: @""] != 0)
                [self onPostExecute: [NSData dataWithBytes: [result UTF8String] length:[result lengthOfBytesUsingEncoding: NSUTF8StringEncoding]]];//[result dataUsingEncoding: NSUTF8StringEncoding]];
            else
                [self onPostExecute: nil];
        }
        
        return TRUE;
    }
    else
        return FALSE;
}

- (void) cancel
{
    if (self.m_connection != nil)
    {
        [self.m_connection cancel];
        self.m_connection = nil;
    }
    
    if (self.m_result != nil)
    {
        [self.m_result release];
        self.m_result = nil;
    }
    
    [self onCanceled];
}

- (NSString*) doInBackground: (NSData*) params
{
    return nil;
}

- (void) postExecute: (NSData*) result
{
    
}

- (void) onPreExecute
{
    
}

- (void) onPostExecute: (NSData*) result
{
    
}

- (void) onCanceled
{
    
}

- (void) onProgressUpdate: (int) param
{
    
}


@end
