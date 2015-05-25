//
//  TyphoonSpotAnnotationView.m
//  中国天气通
//
//  Created by Sam Chen on 11/14/12.
//
//

#import "TyphoonSpotAnnotationView.h"

@implementation TyphoonSpotAnnotationView

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

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        //self.info = @"";
        CGRect frame = self.frame;
        frame.size = CGSizeMake(10.0, 10.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        //self.centerOffset = CGPointMake(30.0, 42.0);
        self.centerOffset = CGPointMake(0.0, 0.0);
        self.annotation = annotation;

    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    //[[UIImage imageNamed:@"red_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
    TyphoonSpotAnnotation * ann = (TyphoonSpotAnnotation *)self.annotation;
    if ([ann.typhoonSpotInfo count] == 0) {
        NSLog(@"No typhoon spot info ...");
    }
    else {
        float fs = [[ann.typhoonSpotInfo objectForKey:@"fs"] floatValue];
        if (fs <= 17.1 && fs > 10.8) {
            [[UIImage imageNamed:@"green_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
        else if (fs <= 24.4 && fs >= 17.2) {
            [[UIImage imageNamed:@"yellow_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
        else if (fs <= 32.6 && fs >= 24.5) {
            [[UIImage imageNamed:@"orange_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
        else if (fs <= 41.4 && fs >= 32.7) {
            [[UIImage imageNamed:@"red_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
        else if (fs <= 50.9 && fs >= 41.5) {
            [[UIImage imageNamed:@"pink_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
        else if (fs > 50.9) {
            [[UIImage imageNamed:@"purple_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
        else {
            [[UIImage imageNamed:@"yellow_dot.png"] drawInRect:CGRectMake(0, 0, 10.0, 10.0)];
        }
    }
}

//10.8<风速<17.1  等级= "热带低压"
//17.2< 风速< 24.4 等级= "热带风暴";
//24.5< 风速< 32.6  等级= "强热带风暴";
//32.7< 风速< 41.4 等级= "台风";
//41.5< 风速< 50.9 等级= "强台风";
//风速> 50.9 等级= "超强台风";



@end
