//
//  MFrame.h
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MFrame : MTag
{
    UInt8 _textLen;
    NSString * _frameName;
}

@property UInt8 textLen;
@property (copy, nonatomic) NSString * frameName;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

- (NSString *)getName;

@end
