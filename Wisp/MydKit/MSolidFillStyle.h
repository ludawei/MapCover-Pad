//
//  MSolidFillStyle.h
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MSolidFillStyle : MTag
{
    MColor _color;
    UInt8 _width;
}

@property MColor color;
@property UInt8 width;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

@end
