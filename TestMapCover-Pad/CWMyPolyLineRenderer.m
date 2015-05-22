//
//  CWMyPolyLineRenderer.m
//  TestMapCover
//
//  Created by 卢大维 on 15/4/1.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "CWMyPolyLineRenderer.h"

@implementation CWMyPolyLineRenderer

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
    [self strokePath:self.path inContext:context];
    
    CGFloat lineLen = 20.0/zoomScale;
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [self.strokeColor CGColor]);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, MKRoadWidthAtZoomScale(zoomScale)*self.lineWidth);
    
    for (NSInteger i=0; i<self.polyline.pointCount-1; i=i+10) {
        
        CGPoint p2 = [self pointForMapPoint:self.polyline.points[i]];
        CGPoint p1 = [self pointForMapPoint:self.polyline.points[i+1]];
        
        CGPoint fromP = CGPointMake(p1.x + (p2.x-p1.x)/2, p1.y + (p2.y-p1.y)/2);
        
        CGFloat angle = atan2(p2.y-p1.y, p2.x-p1.x);
        CGPoint toP = CGPointMake(fromP.x + lineLen*sin(angle), fromP.y - lineLen*cos(angle));
        
        CGContextMoveToPoint(context, fromP.x, fromP.y);
        CGContextAddLineToPoint(context, toP.x, toP.y);
    }
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end
