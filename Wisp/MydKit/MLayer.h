//
//  MLayer.h
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MLayer : MTag
{
    UInt8 _textLen;
    NSString * _layerName;
}

@property UInt8 textLen;
@property (copy, nonatomic) NSString * layerName;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

- (NSString *)getName;

@end
