//
//  MSolidFillStyle.m
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MSolidFillStyle.h"

@implementation MSolidFillStyle

- (id)init
{
    if ([super init]) {
        self.tagType = 5;
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
        self.tagType = 5;
        
        [tagData getBytes:&self->_color range:NSMakeRange(loc, 4)];
        [tagData getBytes:&self->_width range:NSMakeRange(loc+4, 1)];

        //NSLog(@"tagColor : %d, %d, %d, %d  width : %d", self.color.red, self.color.green, self.color.blue, self.color.alpha, self.width);
        self.length = 5;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
