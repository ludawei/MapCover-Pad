//
//  HTTPHandler.h
//  MydKit
//
//  Created by Sam Chen on 11/20/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPAsyncTask.h"

@interface HTTPHandler : NSObject
{
@private
    //    NSURLConnection*            m_conn;
    //    bool                        m_isStatusFail;
}

- (void) setProxy: (NSURL*) url;
- (id) HTTPConnect: (HTTPAsyncTask*) delegate withUrl: (NSURL*) url isGet: (bool) get content: (const char*) upload length: (int) length;
- (bool) killConnection;

@end
