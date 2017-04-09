//
//  YTWeatherData.h
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YTWeatherData : NSObject <NSCoding>

/**地点*/
@property (nonatomic, copy) NSString *location;
/**天气状况*/
@property (nonatomic, copy) NSString *weather;
/**当前气温*/
@property (nonatomic, copy) NSString *temperature;
/**今日最高温*/
@property (nonatomic, copy) NSString *highTemp;
/**今日最低温*/
@property (nonatomic, copy) NSString *lowTemp;
/**日出时间*/
@property (nonatomic, copy) NSString *sunrise;
/**日落时间*/
@property (nonatomic, copy) NSString *sunset;
/**天气状况图标*/
@property (nonatomic, copy) NSString *icon;
/**降水概率*/
@property (nonatomic, copy) NSString *pop;
/**相对湿度*/
@property (nonatomic, copy) NSString *hum;
/**降水量*/
@property (nonatomic, copy) NSString *pcpn;
/**体感温度*/
@property (nonatomic, copy) NSString *fl;
/**空气质量*/
@property (nonatomic, copy) NSString *qlty;
/**pm2.5*/
@property (nonatomic, copy) NSString *pm25;
/**未来五天的天气状况*/
@property (nonatomic, strong) NSArray *forecastWeather;
/**判断是否为本地*/
@property (nonatomic, assign) BOOL here;
/**天气背景*/
@property (nonatomic, strong) UIImage *weatherImage;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end


