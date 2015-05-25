//
//  MPointText.m
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MPointText.h"

@implementation MPointText

- (id)init
{
    if ([super init]) {
        self.tagType = 4;
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
        self.tagType = 4;
        
        [tagData getBytes:&self->_lon range:NSMakeRange(loc, 4)];
        [tagData getBytes:&self->_lat range:NSMakeRange(loc+4, 4)];
        
        [tagData getBytes:&self->_textLen range:NSMakeRange(loc+8, 2)];
        //NSLog(@"textLen : %d", self.textLen);
        
        char * tagText = (char *)malloc(self.textLen + 1);
        [tagData getBytes:tagText range:NSMakeRange(loc+10 , self.textLen)];
        tagText[self.textLen] = 0;
        self.text = [NSString stringWithCString:(const char *)tagText encoding:NSUTF8StringEncoding];
        //NSLog(@"tagText : %@", self.text);
        free(tagText);
        
        self.length = 10 + self.textLen;
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
