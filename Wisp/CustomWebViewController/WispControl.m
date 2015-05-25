//
//  WispControl.m
//  WeatherChina-iPhone
//
//  Created by sam on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WispControl.h"

@implementation WispControl

@synthesize wispController = _wispController;
@synthesize wispType = _wispType;
@synthesize wispParams = _wispParams;

- (id)initWithWispURL:(NSString *)wispUrl
{
    self.wispController = @"";
    self.wispType = @"";
    self.wispParams = @"";
    
    NSArray * components = [wispUrl componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#?"]];
    int i = 0;
    for (NSString * str in components){
        if (i == 0)
            self.wispController = str;
        else if (i == 1)
            self.wispParams = str;
        else if (i == 2) {
            self.wispType = str;
        }
        i++;
    }
    
    NSString * wispDetail = [[self.wispParams componentsSeparatedByString:@"&"] objectAtIndex:0];
    if ([wispDetail compare:@"detail=peripheral"] == 0) {
        self.wispController = [NSString stringWithFormat:@"%@?%@", self.wispController, @"detail=peripheral"];
    }
    else if ([wispDetail compare:@"detail=typhoon"] == 0) {
        self.wispController = [NSString stringWithFormat:@"%@?%@", self.wispController, @"detail=typhoon"];
    }
    else if ([wispDetail compare:@"detail=radar"] == 0) {
        self.wispController = [NSString stringWithFormat:@"%@?%@", self.wispController, @"detail=radar"];
    }
    
    if (self.wispController.length>=16 && [[self.wispController substringToIndex:16] compare:@"wisp://templates"] == 0) {
        self.wispController = @"wisp://templates";
    }
    
    return self;
}

- (NSString *)getWispControllerClassName
{
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"wisp" ofType:@"plist"];
    NSDictionary * wispDict = [[[NSDictionary alloc] initWithContentsOfFile:plistPath] autorelease];
    return [wispDict objectForKey:self.wispController];
}

- (NSString *)getWispControllerViewName
{
    NSString * wispControllerClassName = [self getWispControllerClassName];
    return [wispControllerClassName stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
}

- (NSDictionary *)getVideoInfoFromUrl:(NSString *)params
{
    if (params) {
        NSMutableDictionary * videoInfo = [[[NSMutableDictionary alloc] init] autorelease];
        NSArray * components = [params componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
        int count = [components count] / 2;
        for (int i = 0; i < count; i++) {
            if ([[components objectAtIndex:i*2] isEqualToString:@"androidSrc"]) {
                [videoInfo setValue:[components objectAtIndex:i*2+1] forKey:@"src"];
            }
            else if ([[components objectAtIndex:i*2] isEqualToString:@"title"]) {
                [videoInfo setValue:[components objectAtIndex:i*2+1] forKey:@"title"];
            }
        }
        return videoInfo;
    }
    else {
        return nil;
    }
}

- (void)dealloc
{
    [_wispController release];
    [_wispType release];
    [_wispParams release];
    [super dealloc];
}

@end
