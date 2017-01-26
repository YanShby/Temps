//
//  YTForecastTableViewCell.h
//  YanTemps
//
//  Created by Yans on 2016/11/30.
//  Copyright © 2016年 Yans. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTForecastData;

@interface YTForecastTableViewCell : UITableViewCell

/**预测数据模型*/
@property (nonatomic, strong) YTForecastData *forecastData;

@end
