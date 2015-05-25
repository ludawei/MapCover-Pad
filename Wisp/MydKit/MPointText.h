//
//  MPointText.h
//  MydKit
//
//  Created by Sam Chen on 11/8/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MTag.h"

@interface MPointText : MTag
{
    SInt32 _lon;
    SInt32 _lat;
    UInt16 _textLen;
    NSString * _text;
}

@property SInt32 lon;
@property SInt32 lat;
@property UInt16 textLen;
@property (copy, nonatomic) NSString * text;

- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

- (NSString *)getText;


@end
