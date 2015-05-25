//
//  MPointString.h
//  MydKit
//
//  Created by Sam Chen on 11/6/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MPointString : MTag
{
    SInt32 _lon;
    SInt32 _lat;
}

@property SInt32 lon;
@property SInt32 lat;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

@end
