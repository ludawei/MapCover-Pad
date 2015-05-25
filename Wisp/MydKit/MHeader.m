//
//  MHeader.m
//  MydKit
//
//  Created by Sam Chen on 10/21/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MHeader.h"
#import "zlib.h"

@implementation MHeader

- (BOOL)isMydHeaderValid
{
    if (self.sign2 != 0x59 || self.sign3 != 0x4d) {
        return NO;
    }
    
    if (self.sign1 == 0x43 || self.sign1 == 0x44) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)getHeader:(NSData *)mydData
{
    UInt8 sign;
    [mydData getBytes:&sign range:NSMakeRange(0, 1)];
    self.sign1 = sign;
    
    [mydData getBytes:&sign range:NSMakeRange(1, 1)];
    self.sign2 = sign;
    
    [mydData getBytes:&sign range:NSMakeRange(2, 1)];
    self.sign3 = sign;
    
    NSLog(@"%d, %d, %d", self.sign1, self.sign2, self.sign3);
    
    UInt8 version;
    [mydData getBytes:&version range:NSMakeRange(3, 1)];
    self.version = version;
    NSLog(@"version : %d", self.version);
    
    UInt32 filelength;
    [mydData getBytes:&filelength range:NSMakeRange(4, 4)];
    self.filelength = filelength;
    NSLog(@"filelength : %ld", self.filelength);
}


@end
