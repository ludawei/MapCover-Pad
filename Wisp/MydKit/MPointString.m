//
//  MPointString.m
//  MydKit
//
//  Created by Sam Chen on 11/6/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MPointString.h"

@implementation MPointString

- (id)init
{
    if ([super init]) {
        self.tagType = 1;
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
        
        self.tagType = 1;
        
        [tagData getBytes:&self->_lon range:NSMakeRange(loc, 4)];
        [tagData getBytes:&self->_lat range:NSMakeRange(loc+4, 4)];
        //NSLog(@"tagMPointString : %@, %@", tagMPointString.lon, tagMPointString.lat);
        self.length = 8;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
