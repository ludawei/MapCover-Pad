//
//  MBundle.m
//  MydKit
//
//  Created by Sam Chen on 11/2/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "MBundle.h"
#import "zlib.h"

@implementation MBundle
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
        self.header = [[[MHeader alloc] init] autorelease];
        self.fileType = 0;
    }
    return self;
}

- (void)getBundle:(NSData *)mydData
{
    if (mydData == nil) {
        return;
    }
    
    UInt8 sign;
    [mydData getBytes:&sign range:NSMakeRange(0, 1)];
    self.header.sign1 = sign;
    
    [mydData getBytes:&sign range:NSMakeRange(1, 1)];
    self.header.sign2 = sign;
    
    [mydData getBytes:&sign range:NSMakeRange(2, 1)];
    self.header.sign3 = sign;
    
    //NSLog(@"%d, %d, %d", self.header.sign1, self.header.sign2, self.header.sign3);
    
    // Check header
    if (![self.header isMydHeaderValid]) {
        return;
    }
    
    UInt8 version;
    [mydData getBytes:&version range:NSMakeRange(3, 1)];
    self.header.version = version;
    //NSLog(@"version : %d", self.header.version);
    
    UInt32 filelength;
    [mydData getBytes:&filelength range:NSMakeRange(4, 4)];
    self.header.filelength = filelength;
    //NSLog(@"filelength : %ld", self.header.filelength);
    
    int length = [mydData length] - 8;
    NSData * mydUnComData;
    if (self.header.sign1 == 0x43) {
        
        NSData * mydComData = [mydData subdataWithRange:NSMakeRange(8, length)];
        mydUnComData = [self uncompressZippedData:mydComData];
        
        //NSLog(@"comStr : %@ ---> %d,  unComStr : %@  ---> %d", mydComData, [mydComData length], mydUnComData, [mydUnComData length]);
    }
    else if (self.header.sign1 == 0x44) {
        mydUnComData = [mydData subdataWithRange:NSMakeRange(8, length)];
        
        //NSLog(@"unComStr : %@  ---> %d", mydUnComData, [mydUnComData length]);
    }
    else {
        return;
    }
    
    
    // Make tags array and tagsTypes array
    NSMutableArray * tagsArray = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray * tagsTypesArray = [[[NSMutableArray alloc] init] autorelease];
    if (mydUnComData != nil) {
        UInt16 dataScale;
        [mydUnComData getBytes:&dataScale range:NSMakeRange(0, 2)];
        self.header.dataScale = dataScale;
        //NSLog(@"dataScale : %d", self.header.dataScale);
        
        UInt8 nBits;
        [mydUnComData getBytes:&nBits range:NSMakeRange(2, 1)];
        //NSLog(@"nBits : %d", nBits);
        nBits = nBits >> BITS_PER_BYTE - TAG_NBITS;  // nBits >> 3
        //NSLog(@"nBits : %d", nBits);
        
        //Get the RECT
        offset = 0;
        index = 0;
        buffer_length = (4 * nBits + TAG_NBITS) / BITS_PER_BYTE + 1;
        buffer = (char *)malloc(buffer_length);
        [mydUnComData getBytes:buffer range:NSMakeRange(2 , buffer_length)];
        
        nBits = [self readBits:TAG_NBITS];
        MRect rect;
        rect.Xmin = [self readBits:nBits];
        rect.Xmax = [self readBits:nBits];
        rect.Ymin = [self readBits:nBits];
        rect.Ymax = [self readBits:nBits];
        
        NSUInteger loc = buffer_length + 2;
        
        int16_t layerCount;
        //[mydUnComData getBytes:&layerCount range:NSMakeRange(11, 2)];
        [mydUnComData getBytes:&layerCount range:NSMakeRange(loc, 2)];
        //NSLog(@"layerCount : %d", layerCount);
        
        //NSUInteger loc = 13;
        loc += 2;
        
        while (loc < [mydUnComData length]-1) {
            id tag;
            tag = [self getTag:mydUnComData dataLocation:&loc];
            
            if (tag == nil) {
                break;
            }
            else if ([tag isMemberOfClass:[MPointString class]]) {
                [tagsArray addObject:(MPointString *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MPointStringTag]];
            }
            else if ([tag isMemberOfClass:[MLineString class]]) {
                [tagsArray addObject:(MLineString *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MLineStringTag]];
            }
            else if ([tag isMemberOfClass:[MText class]]) {
                [tagsArray addObject:(MText *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MTextTag]];
                //NSLog(@"tag : %@", [(MText *)tag getText]);
            }
            else if ([tag isMemberOfClass:[MPointText class]]) {
                [tagsArray addObject:(MPointText *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MPointTextTag]];
            }
            else if ([tag isMemberOfClass:[MSolidFillStyle class]]) {
                [tagsArray addObject:(MSolidFillStyle *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MSolidFillStyleTag]];
            }
            else if ([tag isMemberOfClass:[MLineStyle class]]) {
                [tagsArray addObject:(MLineStyle *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MLineStringTag]];
            }
            else if ([tag isMemberOfClass:[MImage class]]) {
                [tagsArray addObject:(MImage *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MImageTag]];
            }
            else if ([tag isMemberOfClass:[MLayer class]]) {
                [tagsArray addObject:(MLayer *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MLayerTag]];
            }
            else if ([tag isMemberOfClass:[MFrame class]]) {
                [tagsArray addObject:(MFrame *)tag];
                [tagsTypesArray addObject:[NSNumber numberWithInt:MFrameTag]];
            }
        }
        
        self.tags = [NSArray arrayWithArray:tagsArray];
        self.tagsTypes = [NSArray arrayWithArray:tagsTypesArray];
        [self getMydFileType];
    }
    else {
        return;
    }
    
}

- (id)getTag:(NSData *)mydData dataLocation:(NSUInteger*)loc
{
    UInt8 tagType;
    [mydData getBytes:&tagType range:NSMakeRange(*loc, 1)];
    //NSLog(@"tagType : %d", tagType);
    
    //UInt16 tagLen;
    
    if (tagType == 1) { // MPointString        
        MPointString * tagMPointString = [[MPointString alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMPointString : %@, %@", tagMPointString.lon, tagMPointString.lat);
        *loc = (*loc) + 1 + tagMPointString.length;
        return tagMPointString;
    }
    else if (tagType == 2) { // MLineString
        MLineString * tagMLineString = [[MLineString alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMLineString : %d", tagMLineString.pointNumber);
        *loc = (*loc) + 1 + tagMLineString.length;
        return tagMLineString;
    }
    else if (tagType == 3) { // MText   
        MText * tagMText = [[MText alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMText : %@", [tagMText getText]);
        *loc = (*loc) + 1 + tagMText.length;
        return tagMText;
    }
    else if (tagType == 4) { // MPointText
        MPointText * tagMPointText = [[MPointText alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMPointText : %@", [tagMPointText getText]);
        *loc = (*loc) + 1 + tagMPointText.length;
        return tagMPointText;
    }
    else if (tagType == 5) { // MSolidFillStyle
        MSolidFillStyle * tagMSolidFillStyle = [[MSolidFillStyle alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMSolidFillStyle : %@", [tagMSolidFillStylet getText]);
        *loc = (*loc) + 1 + tagMSolidFillStyle.length;
        return tagMSolidFillStyle;
    }
    else if (tagType == 6) { // MLineStyle
        MLineStyle * tagMLineStyle = [[MLineStyle alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMLineStyle : %@", [tagMLineStylet getText]);
        *loc = (*loc) + 1 + tagMLineStyle.length;
        return tagMLineStyle;
    }
    else if (tagType == 10) { // MImage
        MImage * tagMImage = [[MImage alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMImage : %@", [tagMImage getText]);
        *loc = (*loc) + 1 + tagMImage.length;
        return tagMImage;
    }
    else if (tagType == 20) { // MLayer
        MLayer * tagMLayer = [[MLayer alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMLayer : %@", [tagMLayer getText]);
        *loc = (*loc) + 1 + tagMLayer.length;
        return tagMLayer;
    }
    else if (tagType == 30) { // MFrame
        MFrame * tagMFrame = [[MFrame alloc] initWithData:mydData dataLocation:(*loc)+1];
        //NSLog(@"tagMFrame : %@", [tagMFrame getText]);
        *loc = (*loc) + 1 + tagMFrame.length;
        return tagMFrame;
    }
    else if (tagType == 99) {
        *loc += 1;
        return nil;
    }
    
    return nil;
}

- (void)getMydFileType
{
    if ([self.tagsTypes count] == 0) {
        return;
    }
    else if ([self.tagsTypes count] == 1) {
        if ([self.tagsTypes[0] intValue] == MTextTag) {
            self.fileType = TEXT_FILE;
        }
        else if ([self.tagsTypes[0] intValue] == MImageTag) {
            self.fileType = IMAGE_FILE;
        }
    }
    else {
        self.fileType = SHAPE_FILE;
    }
}

-(NSData *)uncompressZippedData:(NSData *)compressedData
{
    
    if ([compressedData length] == 0) return compressedData;
    
    unsigned full_length = [compressedData length];
    
    unsigned half_length = [compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = [compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
        
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
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
    [_header release];
    [_tags release];
    [_tagsTypes release];
    [super dealloc];
}

@end
