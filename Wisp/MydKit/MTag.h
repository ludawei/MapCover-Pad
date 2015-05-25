//
//  MTag.h
//  MydKit
//
//  Created by Sam Chen on 11/6/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

//static int TAG_NBITS = 5;
//static int BYTES_TO_BITS = 3;
//static int BITS_TO_BYTES = 3;
//static int BITS_PER_BYTE = 8;
//static int BITS_PER_INT = 32;
//static int MASK_LOWEST3 = 0x0007;
//static int BYTE_MASK = 255;

#define TAG_NBITS 5
#define BYTES_TO_BITS 3
#define BITS_TO_BYTES 3
#define BITS_PER_BYTE 8
#define BITS_PER_INT 32
#define MASK_LOWEST3 0x0007
#define BYTE_MASK 255

typedef struct mrect{
    SInt32 Xmin;
    SInt32 Xmax;
    SInt32 Ymin;
    SInt32 Ymax;
}MRect;

typedef struct mcolor{
    UInt8 red;
    UInt8 green;
    UInt8 blue;
    UInt8 alpha;
}MColor;

@interface MTag : NSObject
{
    UInt8 _tagType;
    UInt32 _length;
}

@property UInt8 tagType;
@property UInt32 length;

//- (id)initWithData:(NSData *)tagData dataLocation:(NSUInteger)loc;

@end
