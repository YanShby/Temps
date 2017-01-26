//
//  YTFoldTableViewCell.h
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTWeatherData;

typedef void(^CompletionHandler)(void);

typedef NS_ENUM(NSUInteger, YTAnimationType) {
    YTAnimationTypeOpen,
    YTAnimationTypeClose,
};


@interface YTFoldTableViewCell : UITableViewCell

/**数据模型*/
@property (nonatomic, strong) YTWeatherData *weatherData;


- (void)selectedAnimation:(BOOL)isSelected animated:(BOOL)animated completion:(CompletionHandler)completion;
- (BOOL)isAnimating;
- (CGFloat)returnSumTime;

@end
