//
//  TaskListener.h
//  WeatherChina-iPhone
//
//  Created by sam on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef WeatherChina_iPhone_TaskListener_h
#define WeatherChina_iPhone_TaskListener_h

#import <Foundation/Foundation.h>

@protocol TaskListener <NSObject>

- (void)onTriggered:(id)result;

@end

#endif
