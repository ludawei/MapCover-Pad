//
//  AsyncTask.h
//  adi
//
//  Created by LIU Zhongjie on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef adi_AsyncTask_h
#define adi_AsyncTask_h

@interface AsyncTask : NSObject<NSURLConnectionDataDelegate>
{
    NSURLConnection*        m_connection;
    NSMutableData*          m_result;
    bool                    m_hasData;
}

@property (nonatomic, retain) NSURLConnection* m_connection;
@property (nonatomic, retain) NSMutableData* m_result;

- (void) connection: (NSURLConnection*) connection didReceiveResponse: (NSURLResponse*) response;
- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data;
- (void) connectionDidFinishLoading: (NSURLConnection *) connection;
- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error;

- (BOOL) execute: (NSArray*) params;
- (void) cancel;
- (NSString*) doInBackground: (NSArray*) params;
- (void) postExecute: (NSData*) result;

- (void) onPreExecute;
- (void) onPostExecute: (NSData*) result;
- (void) onCanceled;
- (void) onProgressUpdate: (int) param;

@end


#endif
