//
//  MText.h
//  MydKit
//
//  Created by Sam Chen on 10/23/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MText : MTag
{
    UInt16 _tagLen;
    NSString * _text;
}

@property UInt16 tagLen;
@property (copy, nonatomic) NSString * text;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

- (NSString *)getText;

@end
