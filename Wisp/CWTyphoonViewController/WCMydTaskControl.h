//
//  WCMydTaskControl.h
//  中国天气通
//
//  Created by Sam Chen on 11/20/12.
//
//

#import <Foundation/Foundation.h>
#import "WCMydAsyncTask.h"
#import "TaskListener.h"

@protocol MydDisplayDelegate <NSObject>

@optional

- (void)displayMydData:(id)result taskControl:(id)taskControl;

@end

@interface WCMydTaskControl : NSObject <TaskListener>
{
   // id<MydDisplayDelegate> _displayDelegate;
}

@property (retain, nonatomic) WCMydAsyncTask * mydTask;
@property (assign, nonatomic) id<MydDisplayDelegate> displayDelegate;

- (id)init;

- (void)getMydFromServer:(NSArray *)params;

@end
