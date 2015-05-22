//
//  CWMyOverlayView.m
//  ChinaWeather
//
//  Created by 卢大维 on 14-9-22.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import "CWMyOverlayRenderer.h"

#define SPACE_WIDTH 10.f

@interface CWMyOverlayRenderer ()

@end

@implementation CWMyOverlayRenderer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    if ([[self.polygon subtitle] isEqualToString:@"1"])
    {
        MKMapRect theMapRect    = [self.overlay boundingMapRect];
        CGRect theRect           = [self rectForMapRect:theMapRect];
        
        CGFloat width = 10/zoomScale;
        
        CGPatternCallbacks callbacks = { 0, &MyPatternFunction, NULL };
        CGContextSaveGState(context);
        CGPatternRef myPattern;
        SetPatternColorSpace(context);
        
        CGRect patternRect = CGRectMake(0,0,width,width);
        
        CGFloat r,g,b,f;
        [self.fillColor getRed:&r green:&g blue:&b alpha:&f];
        
        NSDictionary *dataDict = @{@"frame": [NSValue valueWithCGRect:patternRect], @"color": [NSString stringWithFormat:@"%f,%f,%f,%f", r,g,b,f]};
        myPattern = CGPatternCreate((void*)dataDict,
                                    theRect,
                                    CGAffineTransformMake(1, 0, 0, 1, 0, 0),
                                    width,
                                    width,
                                    kCGPatternTilingConstantSpacing,
                                    true,
                                    &callbacks
                                    );
        CGFloat alpha = 1;
        CGContextSetFillPattern(context, myPattern, &alpha);
        CGPatternRelease(myPattern);
        [self fillPath:self.path inContext:context];
        
        CGContextRestoreGState(context);
    }
    else
    {
        [self applyFillPropertiesToContext:context atZoomScale:zoomScale];
        [self fillPath:self.path inContext:context];
    }
}

void SetPatternColorSpace(CGContextRef context)
{
    CGColorSpaceRef myColorSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, myColorSpace);
    CGColorSpaceRelease(myColorSpace);
}

void MyPatternFunction(void* info, CGContextRef context)
{
    NSDictionary *dataDict = (__bridge NSDictionary *)info;
    CGRect bounds = [[dataDict objectForKey:@"frame"] CGRectValue];
    NSArray *rgbf = [[dataDict objectForKey:@"color"] componentsSeparatedByString:@","];
    
    UIColor *color = [UIColor colorWithRed:[rgbf[0] floatValue] green:[rgbf[1] floatValue] blue:[rgbf[2] floatValue] alpha:[rgbf[3] floatValue]];
    
    CGFloat width = bounds.size.width/10;
    
    CGContextSaveGState(context);

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, bounds.size.width-width, 0);
    CGContextAddLineToPoint(context, 0, bounds.size.width-width);
    CGContextAddLineToPoint(context, width, bounds.size.width);
    CGContextAddLineToPoint(context, bounds.size.width, width);
    CGContextClosePath(context);

    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}
@end
