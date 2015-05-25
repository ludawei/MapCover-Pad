//
//  WCMydTaskControl.m
//  中国天气通
//
//  Created by Sam Chen on 11/20/12.
//
//

#import "WCMydTaskControl.h"

@implementation WCMydTaskControl

- (id)init
{
    if (self = [super init]){
        self.mydTask = [[[WCMydAsyncTask alloc] init] autorelease];
        [self.mydTask setListener:self];
        self.displayDelegate = nil;
    }
    return self;
}

- (void)dealloc
{
    [self.mydTask setListener:nil];
    [super dealloc];
}

- (void)onTriggered:(id)result
{
    //NSLog(@"%@", (NSData*)result);
    if (result) {
        [self.displayDelegate displayMydData:result taskControl:self];
    }
    else {
        NSLog(@"MydTaskControl onTriggered: Error Data Response");
    }
}

- (void)getMydFromServer:(NSArray *)params
{
    if (params) {
        [self.mydTask execute:params];
        NSLog(@"%@", params);
    }
}

@end
