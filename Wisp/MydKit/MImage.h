//
//  MImage.h
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MImage : MTag
{
    UInt32 _tagLen;
    NSData * _image;
}

@property UInt32 tagLen;
@property (retain, nonatomic) NSData * image;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

@end
