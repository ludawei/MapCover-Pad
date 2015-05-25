//
//  MText.m
//  MydKit
//
//  Created by Sam Chen on 10/23/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MText.h"

@implementation MText

- (id)init
{
    if ([super init]) {
        self.tagType = 3;
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
        self.tagType = 3;
        
        [tagData getBytes:&self->_tagLen range:NSMakeRange(loc, 2)];
        //NSLog(@"tagLen : %d", self.tagLen);
        
        //UInt8 * tagText = (UInt8 *)malloc(sizeof(UInt8) * self.tagLen + 1);
        //memset(tagText, 0, sizeof(UInt8) * self.tagLen);
        char * tagText = (char *)malloc(self.tagLen + 1);
        [tagData getBytes:tagText range:NSMakeRange(loc+2 , self.tagLen)];
        tagText[self.tagLen] = 0;
        self.text = [NSString stringWithCString:(const char *)tagText encoding:NSUTF8StringEncoding];
        //NSLog(@"tagText : %@", self.text);
        free(tagText);
        
        self.length = 2 + self.tagLen;
    }
    return self;
}

- (NSString *)getText
{
    return self.text;
}

- (void)dealloc
{
    [_text release];
    [super dealloc];
}

@end
