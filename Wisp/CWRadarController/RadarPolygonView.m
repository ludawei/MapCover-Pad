//
//  RadarPolygonView.m
//  中国天气通
//
//  Created by Sam Chen on 12/1/12.
//
//

#import "RadarPolygonView.h"

@implementation RadarPolygonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (void)setPath:(CGPathRef)path
//{
//    [super setPath:path];
//    [self setNeedsDisplay];
//}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"drawRect ... ");
}

//- (void)createPath
//{
//    CGMutablePathRef mutablePath = CGPathCreateMutable();
//    NSLog("createPath ... ");
//}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    [self applyFillPropertiesToContext:context atZoomScale:zoomScale];
    [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
    
    //CLLocationCoordinate2D coord = MKCoordinateForMapPoint(MKMapPointMake(mapRect.origin.x, mapRect.origin.y));
    
    //CLLocationDistance dist = MKMetersPerMapPointAtLatitude(coord.latitude);
    //CGContextSetShadowWithColor(context,
    //                            CGSizeMake(dist*10, dist*10), 20.0f, [[UIColor grayColor] CGColor]);
    //NSLog(@"dist = %f", dist);
    //self.fillColor = [UIColor redColor];
    
    UIGraphicsPushContext(context);
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    //UIBezierPath * bezierPath = [UIBezierPath bezierPathWithCGPath:self.path];
    //CGMutablePathRef path = CGPathCreateMutable();
    
    MKPolygon * polygon = (MKPolygon*)self.overlay;
    
    CGPoint p = [self pointForMapPoint:polygon.points[0]];
    CGPoint controlPoint1, controlPoint2;
    CGPoint toPoint;
    [bezierPath moveToPoint:p];
    for (int i = 0; i < polygon.pointCount-3; i+=3) {
        controlPoint1 = [self pointForMapPoint:polygon.points[i+1]];
        controlPoint2 = [self pointForMapPoint:polygon.points[i+2]];
        toPoint = [self pointForMapPoint:polygon.points[i+3]];
        [bezierPath addCurveToPoint:toPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    }
    
    if (polygon.pointCount % 3 == 0) {
        [bezierPath closePath];
    }
    else if (polygon.pointCount % 3 == 1) {
        [bezierPath addQuadCurveToPoint:p controlPoint:[self pointForMapPoint:polygon.points[polygon.pointCount-1]]];
        [bezierPath closePath];
    }
    else if (polygon.pointCount % 3 == 2) {
        controlPoint1 = [self pointForMapPoint:polygon.points[polygon.pointCount-2]];
        controlPoint2 = [self pointForMapPoint:polygon.points[polygon.pointCount-1]];
        [bezierPath addCurveToPoint:p controlPoint1:controlPoint1 controlPoint2:controlPoint2];
        [bezierPath closePath];
    }

    //CGContextSetRGBFillColor(context, 0., 0., 1., 1.);
    //CGContextSetRGBStrokeColor(context, 0., 0., 1., 0.);
    //bezierPath.lineWidth = 20;
    //bezierPath.flatness = 5.0;
    //bezierPath.usesEvenOddFillRule = YES;
    [bezierPath fillWithBlendMode:kCGBlendModeLuminosity alpha:0.9];
    //[bezierPath fill];
    [bezierPath stroke];
    UIGraphicsPopContext();
    
    //[self fillPath:self.path inContext:context];
    //[self fillPath:bezierPath.CGPath inContext:context];
    //[self strokePath:self.path inContext:context];
    
}

@end
