//
//  MLayer.m
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MLayer.h"

@implementation MLayer

- (id)init
{
    if ([super init]) {
        self.tagType = 20;
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
        self.tagType = 20;
        
        [tagData getBytes:&self->_textLen range:NSMakeRange(loc, 1)];
        //NSLog(@"textLen : %d", self.textLen);
        
        char * tagText = (char *)malloc(self.textLen + 1);
        [tagData getBytes:tagText range:NSMakeRange(loc+1 , self.textLen)];
        tagText[self.textLen] = 0;
        self.layerName = [NSString stringWithCString:(const char *)tagText encoding:NSUTF8StringEncoding];
        //NSLog(@"layerName : %@", self.layerName);
        
        free(tagText);
        self.length = 1 + self.textLen;
    }
    return self;
}

- (NSString *)getName
{
    return self.layerName;
}

- (void)dealloc
{
    [_layerName release];
    [super dealloc];
}

@end
