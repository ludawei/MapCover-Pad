//
//  WCMydAsyncTask.h
//  中国天气通
//
//  Created by Sam Chen on 11/10/12.
//
//

#import "MydAsyncTask.h"
#import "TaskListener.h"

@interface WCMydAsyncTask : MydAsyncTask
{
    id<TaskListener>   _listener;
}

- (void)onPostExecute:(id)result;

- (void)setListener:(id<TaskListener>)listener;

@end
