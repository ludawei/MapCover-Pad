//
//  HTTPManager.h
//  adi
//
//  Created by LIU Zhongjie on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AsyncTask.h"

@interface HTTPManager : NSObject
{
@private
//    NSURLConnection*            m_conn;
//    bool                        m_isStatusFail;
}

- (void) setProxy: (NSURL*) url;
- (id) HTTPConnect: (AsyncTask*) delegate withUrl: (NSURL*) url isGet: (bool) get content: (const char*) upload length: (int) length;
- (bool) killConnection;

@end
