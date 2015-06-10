//
//  TSTileOverlayView.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/6/8.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "TSTileOverlayView.h"

@implementation TSTileOverlayView

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    });
}
@end
