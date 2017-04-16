//
//  YTForecastData.h
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTForecastData : NSObject <NSCoding>

//星期
@property (strong, nonatomic) NSString *dayOfWeek;
//天气状况
@property (strong, nonatomic) UIImage *weatherIcon;
//最高  （H 20° L 10°）
@property (strong, nonatomic) NSString *high;
//最低
@property (strong, nonatomic) NSString *low;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
