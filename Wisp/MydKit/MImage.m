//
//  MImage.m
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MImage.h"

@implementation MImage

- (id)init
{
    if ([super init]) {
        self.tagType = 10;
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
        self.tagType = 10;
        
        [tagData getBytes:&self->_tagLen range:NSMakeRange(loc, 4)];
        //NSLog(@"tagLen : %d", self.tagLen);
        
        self.image = [tagData subdataWithRange:NSMakeRange(loc+4, self.tagLen)];
        
        self.length = 4 + self.tagLen;
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
