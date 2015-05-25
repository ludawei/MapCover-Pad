//
//  MLineString.m
//  MydKit
//
//  Created by Sam Chen on 11/6/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MLineString.h"

@implementation MLineString
{
  @private
    int offset;
    int index;
    int buffer_length;
    char * buffer;
}

- (id)init
{
    if (self = [super init]) {
        self.tagType = 2;
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
        
        self.tagType = 2;
        self.pointXs = 0;
        self.pointYs = 0;
        
        offset = 0;
        index = 0;
        
        [tagData getBytes:&self->_startLon range:NSMakeRange(loc, 4)];
        [tagData getBytes:&self->_startLat range:NSMakeRange(loc+4, 4)];
        [tagData getBytes:&self->_pointNumber range:NSMakeRange(loc+8, 2)];
        
        UInt8 nBits;
        [tagData getBytes:&nBits range:NSMakeRange(loc+10, 1)];
        nBits = nBits >> BITS_PER_BYTE - TAG_NBITS;  // nBits >> 3
        //NSLog(@"nBits : %d", nBits);
        
        buffer_length = (self.pointNumber * 2 * nBits + TAG_NBITS) / BITS_PER_BYTE + 1;
        buffer = (char *)malloc(buffer_length);
        [tagData getBytes:buffer range:NSMakeRange(loc+10 , buffer_length)];
        
//        NSMutableArray * pointsArray = [[NSMutableArray alloc] initWithCapacity:self.pointNumber];
//        [pointsArray addObject:[NSNumber numberWithInt:self.startLon]];
//        [pointsArray addObject:[NSNumber numberWithInt:self.startLat]];
        
        self.pointNumber += 1;
        
        self.pointXs = (SInt32*)malloc(sizeof(SInt32) * self.pointNumber);
        self.pointYs = (SInt32*)malloc(sizeof(SInt32) * self.pointNumber);
        self.pointXs[0] = self.startLon;
        self.pointYs[0] = self.startLat;
        nBits = [self readBits:TAG_NBITS];
        for (int i = 1; i < self.pointNumber; i++) {
            self.pointXs[i] = self.pointXs[i-1] + [self readBits:nBits];
            self.pointYs[i] = self.pointYs[i-1] + [self readBits:nBits];
            //NSLog(@"tagMPointString : %@, %@", tagMPointString.lon, tagMPointString.lat);
        }
        
        self.length = 10 + buffer_length;
        free(buffer);
    }
    return self;
}

- (int)readBits:(int)numberOfBits
{
    int pointer = (index << BYTES_TO_BITS) + offset;
    
    int value = 0;
    
    if (numberOfBits > 0) {
        
        for (int i = BITS_PER_INT; (i > 0)
             && (index < buffer_length); i -= BITS_PER_BYTE) {
            value |= (buffer[index++] & BYTE_MASK) << (i - BITS_PER_BYTE);
        }
        
        value <<= offset;
        
        value >>= BITS_PER_INT - numberOfBits;
        
        pointer += numberOfBits;
        index = pointer >> BITS_TO_BYTES;
        offset = pointer & MASK_LOWEST3;
    }
    
    return value;
}


- (void)dealloc
{
    free(self->_pointXs);
    free(self->_pointYs);
    [super dealloc];
}


@end
