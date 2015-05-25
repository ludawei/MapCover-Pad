//
//  MLineString.h
//  MydKit
//
//  Created by Sam Chen on 11/6/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MLineString : MTag
{
    SInt32 _startLon;
    SInt32 _startLat;
    UInt16 _pointNumber;
    //NSArray * _points;
    SInt32 * _pointXs;
    SInt32 * _pointYs;
}

@property SInt32 startLon;
@property SInt32 startLat;
@property UInt16 pointNumber;
//@property (retain, nonatomic) NSArray * points;
@property SInt32 * pointXs;
@property SInt32 * pointYs;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

@end
