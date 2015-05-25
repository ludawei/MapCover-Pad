//
//  WeatherAnnotationView.m
//  MydTest
//
//  Created by Sam Chen on 10/28/12.
//  Copyright (c) 2012 Open Labs. All rights reserved.
//

#import "WeatherAnnotationView.h"
#import "MBundle.h"

@implementation WeatherAnnotationView

@synthesize loadingIndicator = _loadingIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        self.info = @"";
        CGRect frame = self.frame;
        frame.size = CGSizeMake(24.0, 30.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        //self.centerOffset = CGPointMake(30.0, 42.0);
        self.centerOffset = CGPointMake(0.0, 0.0);
        self.annotation = annotation;
        
        [self installLoadingIndicator];
        [self showLoading];
    }
    return self;
}

- (void)displayWeatherInfo
{
    [self setNeedsDisplay];
    [self hideLoading];
}

- (void)displayLoadingIndicator
{
    [self showLoading];
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
    [[UIImage imageNamed:@"map_green.png"] drawInRect:CGRectMake(0, 0, 24.0, 30.0)];
    WeatherAnnotation * ann = (WeatherAnnotation*)self.annotation;
    if ([ann.cityWeatherInfoString isEqualToString:@""]) {
        NSLog(@"No city weather info ...");
    }
    else {
        [self hideLoading];
        
        UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 15)] autorelease];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:12.0];
        //label.text = @"10";
        label.text = ann.cityWeatherInfoString;
        NSString * temp = [[ann.cityWeatherInfo objectForKey:@"l"] objectForKey:@"t"];
        
        if ([temp intValue] >= 20) {
            [[UIImage imageNamed:@"map_orange.png"] drawInRect:CGRectMake(0, 0, 24.0, 30.0)];
        }
        else if ([temp intValue] <= 0) {
            [[UIImage imageNamed:@"map_blue.png"] drawInRect:CGRectMake(0, 0, 24.0, 30.0)];
        }
        
        label.text = [NSString stringWithFormat:@"%@°", temp];
        [label drawTextInRect:CGRectMake(0, 5, 24, 15)];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)installLoadingIndicator
{
    self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)] autorelease];
    CGPoint center = self.center;
    center.y = center.y - 3;
    [self.loadingIndicator setCenter:center];
    [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.loadingIndicator];
}

- (void)showLoading
{
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoading
{
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
}

- (void)dealloc {
    [_loadingIndicator release];
    [super dealloc];
}

@end
