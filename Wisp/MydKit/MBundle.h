//
//  MBundle.h
//  MydKit
//
//  Created by Sam Chen on 11/2/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTag.h"
#import "MHeader.h"
#import "MPointString.h"
#import "MLineString.h"
#import "MText.h"
#import "MPointText.h"
#import "MSolidFillStyle.h"
#import "MLineStyle.h"
#import "MImage.h"
#import "MLayer.h"
#import "MFrame.h"

enum FileType
{
    TEXT_FILE= 1,
    IMAGE_FILE = 2,
    SHAPE_FILE = 3
};

enum TagType
{
    MPointStringTag= 1,
    MLineStringTag = 2,
    MTextTag = 3,
    MPointTextTag = 4,
    MSolidFillStyleTag = 5,
    MLineStyleTag = 6,
    MImageTag = 10,
    MLayerTag = 20,
    MFrameTag = 30,
    MEndTag = 99
};

@interface MBundle : NSObject
{
    MHeader * _header;
    int _fileType;
    NSArray * _tags;
    NSArray * _tagsTypes;
}

@property (retain, nonatomic) MHeader * header;
@property int fileType;
@property (retain, nonatomic) NSArray * tags;
@property (retain, nonatomic) NSArray * tagsTypes;
//@property (retain, nonatomic) id<NSObject> tag;

- (void)getBundle:(NSData *)mydData;

- (id)getTag:(NSData *)mydData dataLocation:(NSUInteger*)loc;

- (void)getMydFileType;

@end
