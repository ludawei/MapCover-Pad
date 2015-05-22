//
//  MapStatisticsBottomView.m
//  chinaweathernews
//
//  Created by 卢大维 on 15/5/20.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "MapStatisticsBottomView.h"
#import "TJPieView.h"
#import "PLHttpManager.h"
#import "Util.h"
#import "NSDate+Utilities.h"
#import "CWChartView.h"

#define BOTTOM_HEIGHT 220
//#define START_DATE    @"2015-01-01"

@interface MapStatisticsBottomView ()

@property (nonatomic,copy) NSString *stationId;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) UIActivityIndicatorView *actView;

@property (nonatomic,strong) CWChartView *chartView;

@end

@implementation MapStatisticsBottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-BOTTOM_HEIGHT, frame.size.width, BOTTOM_HEIGHT)];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [self addSubview:self.contentView];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyyMMdd"];
        
        self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.actView.center = self.contentView.center;
        [self.actView startAnimating];
        [self addSubview:self.actView];
        
        self.hidden = YES;
        
#if 0
        self.chartView = [[CWChartView alloc] initWithFrame:CGRectMake(0, 220, self.contentView.width, 150)];
        self.chartView.isShowQuadCurve = YES;
        CWChartAxis* _yAxis = [[CWChartAxis alloc] init];
        _yAxis.lineColor = [UIColor grayColor];
        self.chartView.yAxis = _yAxis;
        CWChartAxis* _xAxis = [[CWChartAxis alloc] init];
        _xAxis.showLines = YES;
        self.chartView.xAxis = _xAxis;
        
        self.chartView.yAxis.lineStyle = CWChartAxisLineStyleSolid;
        self.chartView.xAxis.lineStyle = CWChartAxisLineStyleNone;
#endif
    }
    
    return self;
}

-(void)showWithStationId:(NSString *)stationid
{
    self.stationId = stationid;

    self.hidden = NO;
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = 0;
    } completion:^(BOOL finished) {
        NSString *url = [Util requestEncodeWithString:[NSString stringWithFormat:@"http://scapi.weather.com.cn/weather/historycount?areaid=%@&", stationid]
                                                appId:@"f63d329270a44900"
                                           privateKey:@"sanx_data_99"];
        [[PLHttpManager sharedInstance].manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                [self setupViewsWitnData:(NSDictionary *)responseObject];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self setupViewsWitnData:nil];
        }];
    }];
}

-(void)hide
{
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = self.height;
    } completion:^(BOOL finished) {
        [self clearViews];
        self.hidden = YES;
    }];
}

-(void)setupViewsWitnData:(NSDictionary *)data
{
    UILabel *titleLabel = [self createLabelWithFrame:CGRectMake(0, 10, self.contentView.width, 20)];
    titleLabel.text = [NSString stringWithFormat:@"%@ %@", self.addr, self.stationId];
    [self.contentView addSubview:titleLabel];
    
    if (!data || data.count == 0) {
        UILabel *tipLabel = [self createLabelWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.contentView.width, 25)];
        tipLabel.text = data?@"暂无数据":@"请求失败";
        [self.contentView addSubview:tipLabel];
    }
    else
    {
        NSArray *tqxx = [data objectForKey:@"tqxxcount"];
        NSInteger days = [[data objectForKey:@"days"] integerValue];
        
        CGFloat margin = 10.0f;
        CGFloat pieWidth = (self.contentView.width - margin*(tqxx.count+1))/tqxx.count;
        for (NSDictionary *dict in tqxx) {
            NSInteger i = [tqxx indexOfObject:dict];
            NSInteger dictDays = [[dict objectForKey:@"value"] integerValue];
            
            TJPieView *pieView = [[TJPieView alloc] initRadiuses:@[dict, @{@"name":@"其它", @"value":@(days-dictDays)}] total:days];
            pieView.frame = CGRectMake(margin + (pieWidth+margin)*i, CGRectGetMaxY(titleLabel.frame)+margin, pieWidth, pieWidth);
            [self.contentView addSubview:pieView];
            
            [pieView startAnim];
        }
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, pieWidth+10+CGRectGetMaxY(titleLabel.frame)+margin, self.contentView.width-40, self.contentView.height-(pieWidth+CGRectGetMaxY(titleLabel.frame)+margin+20))];
        lbl.numberOfLines = 0;

        {
            NSString *htmlString = @"<div style='color:#FFFFFF; font-size:18px'>自%@至%@：<br />"
            "日最高气温<a style='color:#d87a80;'>%@</a>°C,日最低气温<a style='color:#d87a80;'>%@</a>°C,日最大风速<a style='color:#d87a80;'>%@</a>m/s，日最大降水量<a style='color:#d87a80;'>%@</a>mm，连续无降水日数<a style='color:#d87a80;'>%@</a>天，连续霾日数<a style='color:#d87a80;'>%@</a>天。</div>";
            
            NSDate *startDate = [self.dateFormatter dateFromString:data[@"starttime"]];
            NSString *startDateString = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)startDate.year, (long)startDate.month, (long)startDate.day];
            
            NSDate *endDate = [self.dateFormatter dateFromString:data[@"endtime"]];
            NSString *endDateString = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)endDate.year, (long)endDate.month, (long)endDate.day];
            
            htmlString = [NSString stringWithFormat:htmlString, startDateString, endDateString, [[data[@"count"] firstObject] objectForKey:@"max"], [[data[@"count"] firstObject] objectForKey:@"min"], [[data[@"count"] lastObject] objectForKey:@"max"], [[data[@"count"] objectAtIndex:1] objectForKey:@"max"], data[@"no_rain_lx"],  data[@"mai_lx"]];
            
            NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            lbl.attributedText = attrStr;
        }
//        lbl.backgroundColor = [UIColor lightGrayColor];
        [lbl sizeToFit];
        [self.contentView addSubview:lbl];
        
        self.contentView.height = CGRectGetMaxY(lbl.frame);
#if 0
        [self.contentView addSubview:self.chartView];
        self.chartView.y = CGRectGetMaxY(lbl.frame)+margin-20;
        
        NSDictionary *chartData = [self chartDataWithDatas:[data objectForKey:@"array"]];
        
        CWChartAxis *xAxis = self.chartView.xAxis;
        CWChartAxis *yAxis = self.chartView.yAxis;
        
        xAxis.minValue = 0;
        xAxis.maxValue = (int)[[chartData objectForKey:@"data1"] count]-1;
        
        yAxis.maxValue = [[chartData objectForKey:@"max"] floatValue];
        yAxis.minValue = [[chartData objectForKey:@"min"] floatValue];
        yAxis.values = [chartData objectForKey:@"yAxisValue"];
        yAxis.labels = [chartData objectForKey:@"yAxisLabel"];
        
        CWChartPlot *plot1 = [[CWChartPlot alloc] init];
        plot1.width = 2.0f;
        plot1.points = [chartData objectForKey:@"data1"];
        plot1.color = [UIColor colorWithRed:0.898 green:0.247 blue:0.090 alpha:1];
        
        CWChartPlot *plot2 = [[CWChartPlot alloc] init];
        plot2.width = 2.0f;
        plot2.points = [chartData objectForKey:@"data2"];
        plot2.color = UIColorFromRGB(0x0095ff);
        
        self.chartView.plots = @[plot1, plot2];
        
        [self.chartView setNeedsDisplay];
#endif
    }
    
    self.actView.hidden = YES;
}

-(NSDictionary *)chartDataWithDatas:(NSArray *)array
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    CGFloat max = -100.0,min = 100.0;
    NSMutableArray *maxArray = [NSMutableArray array];
    NSMutableArray *minArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<array.count; i=i+1) {
        NSDictionary *obj = [array objectAtIndex:i];
        
        max = MAX([[obj objectForKey:@"maxtemp"] floatValue], max);
        min = MIN([[obj objectForKey:@"mintemp"] floatValue], min);
        [maxArray addObject:[obj objectForKey:@"maxtemp"]];
        [minArray addObject:[obj objectForKey:@"mintemp"]];
    }
    
    NSInteger temp = max - min;
    max += temp/5 + 1;
    min -= temp/5 + 1;
    
    NSMutableArray *arrayValuey = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLabely = [[NSMutableArray alloc] init];
    for (NSInteger i=(int)(min/10)*10; i<=(int)(max/10)*10; i=i+10) {
        [arrayLabely addObject:[NSString stringWithFormat:@"%ld°", i]];
        [arrayValuey addObject:[NSString stringWithFormat:@"%ld", i]];
    }
    
    [dict setObject:arrayValuey forKey:@"yAxisValue"];
    [dict setObject:arrayLabely forKey:@"yAxisLabel"];
    [dict setObject:[NSNumber numberWithInteger:max] forKey:@"max"];
    [dict setObject:[NSNumber numberWithInteger:min] forKey:@"min"];
    [dict setObject:maxArray forKey:@"data1"];
    [dict setObject:minArray forKey:@"data2"];
    
    return dict;
}

-(UILabel *)createLabelWithFrame:(CGRect)frame
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    return titleLabel;
}

-(void)clearViews
{
    for (UIView *sub in self.contentView.subviews) {
        [sub removeFromSuperview];
    }
    
    self.actView.hidden = NO;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    CGPoint point = [touches.anyObject locationInView:self];
//
//    if (CGRectContainsPoint(self.contentView.frame, point)) {
//        
//    }
    [self hide];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hide];
}
@end
