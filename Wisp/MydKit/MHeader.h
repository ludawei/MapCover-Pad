//
//  MHeader.h
//  MydKit
//
//  Created by Sam Chen on 10/21/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTag.h"

@interface MHeader : NSObject
{
    UInt8 _sign1;   // D -> 0x44,  C -> 0x43
    UInt8 _sign2;   //0x59
    UInt8 _sign3;   //0x4d
    UInt8 _version;
    UInt32 _filelength;
    UInt16 _dataScale;
    MRect _rect;
    SInt16 _layerCount;
}

@property UInt8 sign1;
@property UInt8 sign2;
@property UInt8 sign3;
@property UInt8 version;
@property UInt32 filelength;
@property UInt16 dataScale;
@property MRect rect;
@property SInt16 layerCount;

- (void)getHeader:(NSData *)mydData;

- (BOOL)isMydHeaderValid;

@end
