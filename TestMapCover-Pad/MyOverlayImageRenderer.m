//
//  MyOverlayImageRenderer.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/5/22.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MyOverlayImageRenderer.h"

@implementation MyOverlayImageRenderer

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    MKMapRect theMapRect    = self.overlay.boundingMapRect;
    CGRect theRect       =  [self rectForMapRect:theMapRect];
    
    UIGraphicsPushContext(context);

#if 0
    UIImage *image = self.image;
    if (image) {
        [image drawInRect:theRect blendMode:kCGBlendModeCopy alpha:self.alpha];
    }
#else
    CGImageRef imageReference = self.image.CGImage;
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetAlpha(context, self.alpha);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    CGContextDrawImage(context, theRect, imageReference);
#endif
    
    UIGraphicsPopContext();
}

@end
