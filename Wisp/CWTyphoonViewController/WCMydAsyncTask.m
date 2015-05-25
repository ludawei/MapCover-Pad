//
//  WCMydAsyncTask.m
//  中国天气通
//
//  Created by Sam Chen on 11/10/12.
//
//

#import "WCMydAsyncTask.h"

@implementation WCMydAsyncTask

- (void)onPostExecute:(id)result
{
    if (_listener) {
        [_listener onTriggered:result];
    }
}

- (void)setListener:(id<TaskListener>)listener
{
    _listener = listener;
}

@end
