//
//  YTFoldTableViewCell.m
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import "YTFoldTableViewCell.h"
#import "YTForecastTableViewCell.h"
#import "YTRotatedView.h"
#import "YTWeatherData.h"
#import "YTForecastData.h"

@interface YTFoldTableViewCell () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet YTRotatedView *foregroundView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *foregoundViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;

//地点
@property (weak, nonatomic) IBOutlet UILabel *locate;
//地点
@property (weak, nonatomic) IBOutlet UILabel *location;
//天气状况
@property (weak, nonatomic) IBOutlet UILabel *weather;
//当前温度
@property (weak, nonatomic) IBOutlet UILabel *temperature;
//今日最高温
@property (weak, nonatomic) IBOutlet UILabel *highTemp;
//今日最低温
@property (weak, nonatomic) IBOutlet UILabel *lowTemp;
//日落时间
@property (weak, nonatomic) IBOutlet UILabel *sunset;
//日出时间
@property (weak, nonatomic) IBOutlet UILabel *sunrise;
//天气状况图标
@property (weak, nonatomic) IBOutlet UILabel *icon;
/**未来五天的天气状况*/
@property (nonatomic, strong) NSArray *forecastWeather;

/**预测天气视图*/
@property (nonatomic, strong) IBOutlet UITableView *forecastTableView;

/**存放折叠视图的数组*/
@property (nonatomic, strong) NSMutableArray *animationItemViews;
/**翻转时的背景色*/
@property (nonatomic, strong) UIColor *backViewColor;


@property (weak, nonatomic) IBOutlet UIView *nowBg;
@property (weak, nonatomic) IBOutlet UIView *now2Bg;
@property (weak, nonatomic) IBOutlet UIView *nowOther;




@end

@implementation YTFoldTableViewCell

#pragma mark - 初始化操作
- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    //
    [self.location sizeToFit];
 
    //前景视图
    _foregroundView.layer.cornerRadius = 10;
    _foregroundView.layer.masksToBounds = YES;
    
    //预测天气TableView设置
    _forecastTableView.delegate = self;
    _forecastTableView.dataSource = self;
    _forecastTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _forecastTableView.backgroundColor = [UIColor clearColor];
    _forecastTableView.bounces = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _backViewColor = [UIColor colorWithWhite:1.0 alpha:0.3];
   
    [self configureDefaultState];
  
    _animationItemViews = [self createAnimationItemView];
}



//设置初始状态
- (void)configureDefaultState {
    
    self.containerViewTopConstraint.constant = _foregoundViewTopConstraint.constant;
    
    _containerView.alpha = 0;
    
    //将第一个图设置成圆角
    UIView *firstItemView;
    
    for (UIView  *v in _containerView.subviews) {
        
        if (v.tag == 0) {
            
            firstItemView = v;
        }
    }
    
    //设置外层图片属性
    _foregroundView.layer.anchorPoint = CGPointMake(0.5,1);
    
    self.foregoundViewTopConstraint.constant += _foregroundView.bounds.size.height / 2;
    _foregroundView.layer.transform = [self transform3d];
    [self.contentView bringSubviewToFront:_foregroundView];
    
    for (NSLayoutConstraint *constraint in _containerView.constraints) {
        
        if ([constraint.identifier isEqualToString:@"yPosition"]) {
            constraint.constant -= [constraint.firstItem layer].bounds.size.height / 2;
            [constraint.firstItem layer].anchorPoint = CGPointMake(0.5, 0);
            [constraint.firstItem layer].transform = [self transform3d];
        }
    }
    
    //添加背景View
    YTRotatedView *previusView;
    for (UIView *s in _containerView.subviews) {
        
        if(s.tag > 0 && [s isKindOfClass:[YTRotatedView class]]){
            
            YTRotatedView *tempView = (YTRotatedView *)s;
            [previusView addBackViewHeight:tempView.bounds.size.height color:_backViewColor];
            previusView = tempView;
        }
    }
}

- (NSMutableArray *)createAnimationItemView {
    
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *rotatedViews = [NSMutableArray array];
    
    [items addObject:_foregroundView];
    
    for (UIView *itemView in _containerView.subviews) {
        
        if([itemView isKindOfClass:[YTRotatedView class]])
        {
            YTRotatedView *tempView = (YTRotatedView *)itemView;
            [rotatedViews addObject:tempView];
            
            if (tempView.backView != nil)
                [rotatedViews addObject:tempView.backView];
        }
        
    }
    
    [items addObjectsFromArray:rotatedViews];
    return items;
    
}

- (NSMutableArray *)durationSequence {
    
    NSMutableArray *durationArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:0.35],[NSNumber numberWithFloat:0.23],[NSNumber numberWithFloat:0.23], nil];
    NSMutableArray *durtions = [NSMutableArray array];
    
    for (int index = 0; index < _containerView.subviews.count - 1; index++) {
        
        NSNumber *tempDuration = durationArray[index];
        float temp = [tempDuration floatValue] / 2;
        NSNumber *duration = [NSNumber numberWithFloat:temp];
        
        [durtions addObject:duration];
        [durtions addObject:duration];
    }
    return durtions;
}


- (void)configureAnimationItems:(YTAnimationType)animationType {
    
    if (animationType == YTAnimationTypeOpen) {
        
        for (UIView *view in _containerView.subviews) {
            
            if ([view isKindOfClass:[YTRotatedView class]]) {
                
                view.alpha = 0;
            }
        }
        
    } else {   //close
        
        for (UIView *view in _containerView.subviews) {
            
            if (![view isKindOfClass:[YTRotatedView class]]) return;
           
            YTRotatedView *tempRotaView = (YTRotatedView *)view;
           
            if (animationType == YTAnimationTypeOpen) {
                tempRotaView.alpha = 0;
            } else {
                tempRotaView.alpha = 1;
                tempRotaView.backView.alpha = 0;
            }
        }
    }
}

#pragma mark - setter方法
- (void)setWeatherData:(YTWeatherData *)weatherData {
    
    self.location.text = weatherData.location;
    self.locate.text = weatherData.location;
    self.weather.text = weatherData.weather;
    self.temperature.text = [NSString stringWithFormat:@"%@°",weatherData.temperature];
    self.highTemp.text = [NSString stringWithFormat:@"最高:%@°",weatherData.highTemp];
    self.lowTemp.text = [NSString stringWithFormat:@"最低:%@°",weatherData.lowTemp];
    self.sunset.text = [NSString stringWithFormat:@"日落:%@",weatherData.sunset];
    self.sunrise.text = [NSString stringWithFormat:@"日出:%@",weatherData.sunrise];
    self.icon.text = weatherData.icon;
    self.forecastWeather = weatherData.forecastWeather;
    
    self.nowBg.backgroundColor = [self colorWithTemperature:weatherData.temperature];
    self.now2Bg.backgroundColor = self.nowBg.backgroundColor;
    
    [self.forecastTableView reloadData];
}



#pragma mark - 动画<开/关>
- (void)openAnimation:(CompletionHandler)completion {
    
    NSArray *durtions = [self durationSequence];
    NSTimeInterval delay = 0;
    NSString *timing = kCAMediaTimingFunctionEaseIn;
    CGFloat from = 0.0;
    CGFloat to = -(M_PI / 2);
    //让前景view隐藏
    BOOL hidden = YES;
    [self configureAnimationItems:YTAnimationTypeOpen];
    
    for (int  index = 0; index < _animationItemViews.count; index++) {
        
        float duration = [durtions[index] floatValue];
        YTRotatedView *animatedView = _animationItemViews[index];
        [animatedView foldingAnimation:timing from:from to:to delay:delay duration:duration hidden:hidden];
       
        from = (from == 0 ? (M_PI / 2) : 0.0);
        to = (to == 0.0 ? (-M_PI / 2 ): 0.0);
        timing = timing == kCAMediaTimingFunctionEaseIn ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;
        //其他视图显示
        hidden = !hidden;
        delay += duration;
        
    }
    
    //设置第一个和最后一个视图为圆角
    for (UIView *view in _containerView.subviews) {
        
        if (view.tag == 0) {
            YTRotatedView *firstItemView = (YTRotatedView*)view;
            firstItemView.layer.masksToBounds = YES;
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:firstItemView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10,10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            firstItemView.layer.mask = maskLayer;
        }
        else if(view.tag == 3)
        {
            YTRotatedView *lastItemView = (YTRotatedView*)view;
            lastItemView.layer.masksToBounds = YES;
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:lastItemView.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            lastItemView.layer.mask = maskLayer;
            
        }
    }
}

- (void)closeAnimation:(CompletionHandler)completion {
    
    NSArray *durations = [self durationSequence];
    durations = [[durations reverseObjectEnumerator] allObjects];
    NSTimeInterval delay = 0;
    NSString *timing = kCAMediaTimingFunctionEaseIn;
    CGFloat from = 0.0;
    CGFloat to = M_PI / 2;
    BOOL hidden = YES;
   
    [self configureAnimationItems:YTAnimationTypeClose];
   
    for (int index = 0; index < _animationItemViews.count; index++) {
       
        float duration = [durations[index] floatValue];
        NSArray *tempArray = [[_animationItemViews reverseObjectEnumerator] allObjects];
        YTRotatedView *animatedView = tempArray[index];
        [animatedView foldingAnimation:timing from:from to:to delay:delay duration:duration hidden:hidden];
        
        from = (from == 0.0 ? -M_PI/2 : 0.0);
        to = (to == 0.0 ? M_PI/2 : 0.0);
        timing = timing == kCAMediaTimingFunctionEaseIn ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;
        hidden =! hidden;
        delay += duration;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.containerView.alpha = 0;
        completion();
    });
    
    YTRotatedView *firstItemView;
   
    for (UIView *tempView in _containerView.subviews) {
      
        if (tempView.tag == 0) {
            firstItemView = (YTRotatedView *)tempView;
        }
        
        float value = (delay- [[durations lastObject] floatValue] *1.5);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(value * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            firstItemView.layer.masksToBounds =YES;
            
        });
    }
}


#pragma mark - 3D偏移属性设置
- (CATransform3D )transform3d {
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5 / -2000;
    return transform;
}


#pragma mark - 对外提供的方法
- (void)selectedAnimation:(BOOL)isSelected animated:(BOOL)animated completion:(CompletionHandler)completion {
    
    if (isSelected) { //开启状态
        _containerView.alpha = 1;
       
        for (UIView *subView in _containerView.subviews) {
            subView.alpha = 1;
        }
        
        if (animated) {
            [self openAnimation:^{
                if (completion) {
                    completion();
                }
            }];
        } else {
            _foregroundView.alpha = 0;
           
            for (UIView *subView in _containerView.subviews) {
                if ([subView isKindOfClass:[YTRotatedView class]]) {
                    YTRotatedView *rotateView = (YTRotatedView *)subView;
                    rotateView.backView.alpha = 0;
                }
            }
        }
    }else { //关闭状态
        if (animated) {
            [self closeAnimation:^{
                if (completion) {
                    completion();
                }
            }];
        }else {
            _foregroundView.alpha = 1;
            _containerView.alpha = 0;
        }
    }
}

- (BOOL)isAnimating {
    
    for (UIView *item in _animationItemViews) {
        if(item.layer.animationKeys.count > 0) return YES;
    }
    return NO;
}

- (CGFloat)returnSumTime {
    
    NSMutableArray *tempArray = [self durationSequence];
    CGFloat sumTime = 0.0;
    
    for (NSNumber *number in tempArray) {
        CGFloat time = [number floatValue];
        sumTime += time;
    }
    return sumTime;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  
    [super setSelected:selected animated:animated];
}

- (UIColor *)colorWithTemperature:(NSString *)temp {
    
    NSInteger t = [temp intValue];
    
    if (t < -40) {
        return YTColor(36,152,211);
    } else if (t >= -40 && t < -20) {
        return YTColor(176, 227, 247);
    } else if (t >= -20 && t < -10) {
        return YTColor(176, 227, 247);
    } else if (t >= -10 && t < 0) {
        return YTColor(210, 213, 247);
    } else if (t >= 0 && t < 15) {
        return YTColor(232, 202, 247);
    } else if (t >=15 && t < 25) {
        return YTColor(232, 123, 90);
    } else if (t >=25 && t < 35) {
        return YTColor(255, 128, 36);
    } else if (t >= 35) {
        return YTColor(243, 74, 55);
    }
    
    return nil;
}

#pragma  mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return self.forecastWeather.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    YTForecastTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"YTForecastTableViewCell" owner:nil options:nil] lastObject];
    
    NSDictionary *dict = self.forecastWeather[indexPath.row];
    
    YTForecastData *data = [[YTForecastData alloc] initWithDict:dict];
    
    cell.forecastData = data;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return 30;
}

@end
