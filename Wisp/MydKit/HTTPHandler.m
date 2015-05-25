//
//  HTTPHandler.m
//  MydKit
//
//  Created by Sam Chen on 11/20/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "HTTPHandler.h"

@implementation HTTPHandler

const int HTTP_TIMEOUT = 5000;


- (void) setProxy: (NSURL*) url
{
}

- (id) HTTPConnect: (HTTPAsyncTask*) delegate withUrl: (NSURL*) url isGet: (bool) get content: (const char*) upload length: (int) length
{
    @try
    {
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL: url];
        [urlRequest setHTTPMethod: get ? @"GET" : @"POST"];
        [urlRequest setTimeoutInterval:20.0];
        [urlRequest setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
        [urlRequest setValue: @"keep-alive" forHTTPHeaderField: @"connection"];
        [urlRequest setValue: @"UTF-8" forHTTPHeaderField: @"Charset"];
        [urlRequest setValue: @"text/xml" forHTTPHeaderField:@"Content-Type"];
        NSData* dataRequest = nil;
        if (length > 0)
        {
            dataRequest = [NSData dataWithBytes: upload length: length];
            [urlRequest setHTTPBody: dataRequest];
        }
        
        if (delegate != nil)
        {
            if ([NSURLConnection canHandleRequest: urlRequest])
            {
                NSURLConnection* connection = [NSURLConnection connectionWithRequest: urlRequest delegate: delegate];
                [urlRequest release];
                return connection;
            }
            else
            {
                [urlRequest release];
                return nil;
            }
        }
        else
        {
            NSHTTPURLResponse* response = nil;
            NSError* error = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest: urlRequest returningResponse: &response error: &error];
            
            [urlRequest release];
            
            return responseData;
        }
    }
    @catch (NSException* e)
    {
        return nil;
    }
}

- (bool) killConnection
{
    return FALSE;
}


@end
