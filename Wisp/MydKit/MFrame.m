//
//  MFrame.m
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MFrame.h"

@implementation MFrame

- (id)init
{
    if ([super init]) {
        self.tagType = 30;
    }
    return self;
}

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc
{
    if ([super init]) {
        if (!tagData) {
            return nil;
        }
        if (loc >= [tagData length]) {
            return nil;
        }
        self.tagType = 30;
        
        [tagData getBytes:&self->_textLen range:NSMakeRange(loc, 1)];
        //NSLog(@"textLen : %d", self.textLen);
        
        char * tagText = (char *)malloc(self.textLen + 1);
        [tagData getBytes:tagText range:NSMakeRange(loc+1 , self.textLen)];
        tagText[self.textLen] = 0;
        self.frameName = [NSString stringWithCString:(const char *)tagText encoding:NSUTF8StringEncoding];
        //NSLog(@"frameName : %@", self.frameName);
        
        free(tagText);
        self.length = 1 + self.textLen;
    }
    return self;
}

- (NSString *)getName
{
    return self.frameName;
}

- (void)dealloc
{
    [_frameName release];
    [super dealloc];
}

@end
