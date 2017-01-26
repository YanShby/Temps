//
//  YTWeatherData.h
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YTWeatherData : NSObject <NSCoding>
/**CLLocation*/
@property (nonatomic, strong) CLLocation *local;
/**地点*/
@property (nonatomic, strong) NSString *location;
/**天气状况*/
@property (nonatomic, strong) NSString *weather;
/**当前气温*/
@property (nonatomic, strong) NSString *temperature;
/**今日最高温*/
@property (nonatomic, strong) NSString *highTemp;
/**今日最低温*/
@property (nonatomic, strong) NSString *lowTemp;
/**日出时间*/
@property (nonatomic, strong) NSString *sunrise;
/**日落时间*/
@property (nonatomic, strong) NSString *sunset;
/**天气状况图标*/
@property (nonatomic, strong) NSString *icon;
/**未来五天的天气状况*/
@property (nonatomic, strong) NSArray *forecastWeather;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
