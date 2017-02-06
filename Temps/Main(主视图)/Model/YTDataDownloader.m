//
//  YTDataDownloader.m
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import "YTDataDownloader.h"
#import "YTWeatherData.h"
#import "Climacons.h"
#import <SVProgressHUD.h>

@interface YTDataDownloader ()

/**天气api*/
@property (nonatomic,copy) NSString      *key;
/**记录当前时间*/
@property (nonatomic, strong) NSString   *time;

@end

@implementation YTDataDownloader

/**
 *  单例对象
 *
 *  @return 返回一个单例对象
 */
+ (YTDataDownloader *)sharedDownloader {
    
    static YTDataDownloader *sharedDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDownloader = [[YTDataDownloader alloc] initWithAPIKey:YT_API_Key];
    });
    return sharedDownloader;
}

/**
 *  根据提供的apiKey常量来初始化downloader对象
 *
 *  @param key 天气接口的Key
 *
 *  @return 返回YTDataDownloader对象
 */
- (instancetype)initWithAPIKey:(NSString *)key {
    
    if(self = [super init]) {
        self.key = key;
    }
    return self;
}

- (NSString *)time {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HHmm"];
    _time = [dateformatter stringFromDate:date];

    return _time;
}

/**
 *  根据获得的CLLocation地点对象发送请求获得数据
 *
 *  @param location   地点对象
 *  @param showStatus 显示加载时的提示信息
 *  @param showDone   加载结束时的提示信息
 *  @param completion 一个Block回调，接收请求传回来的数据及错误
 */


- (void)dataForLocation:(CLLocation *)location showStatus:(NSString *)showStatus showDone:(NSString *)showDone completion:(YTWeatherDataDownloadCompletion)completion {
 
    if (!location) return;
    
    [SVProgressHUD showWithStatus:showStatus maskType:SVProgressHUDMaskTypeClear];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLRequest *request = [self urlRequestForLocation:location];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error) {
            completion(nil,error);
        } else {
           
            NSDictionary *JSON = [self serializedData:data];
             [JSON writeToFile:@"/Users/yans/Desktop/data.plist" atomically:YES];
            YTWeatherData *weatherData = [self dataFormJSON:JSON];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(weatherData,error);
                [SVProgressHUD showSuccessWithStatus:showDone maskType:SVProgressHUDMaskTypeClear];
            });
            
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    [task resume];
}

/**
 *  根据提供的CLLocation对象返回一个GET请求
 *
 *  @param location 地点
 *
 *  @return 返回一个天气接口的GET请求
 */
- (NSURLRequest *)urlRequestForLocation:(CLLocation *)location {
    
    static NSString *baseURL           = @"https://free-api.heweather.com/v5/weather?";
    static NSString *parameters        = @"city";
    CLLocationCoordinate2D coordinates = location.coordinate;
    NSString *requestURL               = [NSString stringWithFormat:@"%@%@=%f,%f&key=%@",baseURL,parameters,coordinates.longitude,coordinates.latitude,self.key];
    NSURL *url                         = [NSURL URLWithString:requestURL];
    NSURLRequest *request              = [NSURLRequest requestWithURL:url];
    return request;
}

/**
 *  把请求返回的二进制数据用NSJSONSerialization解析成字典
 *
 *  @param data 请求返回的二进制数据
 *
 *  @return 返回JSON字典
 */
- (NSDictionary *)serializedData:(NSData *)data
{
    NSError *JSONSerializationError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONSerializationError];
    if(JSONSerializationError) {
        [NSException raise:@"JSON Serialization Error" format:@"Failed to parse weather data"];
    }
    return JSON;
}

/**
 *  根据JSON解析的字典返回一个天气数据对象
 *
 *  @param JSON 解析后的JSON字典
 *
 *  @return 返回一个天气数据对象
 */
- (YTWeatherData *)dataFormJSON:(NSDictionary *)JSON {

    NSArray *hefengWeather            = [JSON objectForKey:@"HeWeather5"];
    NSDictionary *mainDict            = [hefengWeather lastObject];
    NSDictionary *basic               = [mainDict objectForKey:@"basic"];
    NSArray *forecast                 = [mainDict objectForKey:@"daily_forecast"];
    NSDictionary *now                 = [mainDict objectForKey:@"now"];

    //把解析出来的信息放入这个字典
    NSMutableDictionary *weatherDict  = [NSMutableDictionary dictionary];

    NSString *location                = [basic objectForKey:@"city"];
    NSString *weather                 = [[now objectForKey:@"cond"] objectForKey:@"txt"];
    NSString *temperature             = [now objectForKey:@"tmp"];
    NSString *highTemp                = [[[forecast objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"];
    NSString *lowTemp                 = [[[forecast objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"];
    NSString *sunrise                 = [[[forecast objectAtIndex:0] objectForKey:@"astro"] objectForKey:@"sr"];
    NSString *sunset                  = [[[forecast objectAtIndex:0] objectForKey:@"astro"] objectForKey:@"ss"];
    NSString *icon                    = [self iconForCondition:weather
                                                    timeStatus:[self nowTime:[self time] sunrise:sunrise sunset:sunset]];
    //存放从JSON中取出的预测五天的天气
    NSMutableArray *oldForecast       = [NSMutableArray array];

    for (int i                        = 1; i <= 5; i++) {
        [oldForecast addObject:[forecast objectAtIndex:i]];
    }
    //存放处理后的预测五天的天气
    NSMutableArray *newForecast       = [NSMutableArray array];

    for (int i                        = 0; i < 5 ; i++) {

    NSString *weatherIcon             = [self iconForCondition:[[oldForecast[i] objectForKey:@"cond"] objectForKey:@"txt_d"]
                                                    timeStatus:@"sun"];
    NSString *high                    = [[oldForecast[i] objectForKey:@"tmp"] objectForKey:@"max"];
    NSString *low                     = [[oldForecast[i] objectForKey:@"tmp"] objectForKey:@"min"];
    NSString *date                    = [oldForecast[i] objectForKey:@"date"];
    NSString *dayOfWeek               = [self featureWeekdayWithDate:date];

    NSMutableDictionary *forecastDict = [NSMutableDictionary dictionary];
        [forecastDict setObject:dayOfWeek forKey:@"dayOfWeek"];
        [forecastDict setObject:weatherIcon forKey:@"weatherIcon"];
        [forecastDict setObject:high forKey:@"high"];
        [forecastDict setObject:low forKey:@"low"];

        [newForecast addObject:forecastDict];
    }



    [weatherDict setObject:location forKey:@"location"];
    [weatherDict setObject:weather forKey:@"weather"];
    [weatherDict setObject:temperature forKey:@"temperature"];
    [weatherDict setObject:highTemp forKey:@"highTemp"];
    [weatherDict setObject:lowTemp forKey:@"lowTemp"];
    [weatherDict setObject:sunrise forKey:@"sunrise"];
    [weatherDict setObject:sunset forKey:@"sunset"];
    [weatherDict setObject:icon forKey:@"icon"];
    [weatherDict setObject:newForecast forKey:@"forecastWeather"];

    YTWeatherData *weatherData        = [[YTWeatherData alloc] initWithDict:weatherDict];

    return weatherData;
}

/**
 *  将从json中获取的天气状况转化成天气字体对应的字符
 *
 *  @param condition 天气状态详情
 *  @param status    时间状态,判断是白天还是黑天.
 *
 *  @return 返回天气数据对应的字符
 */
- (NSString *)iconForCondition:(NSString *)condition timeStatus:(NSString *)status
{
    NSString *iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    if ([condition isEqualToString:@"霾"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconHaze];
    } else if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    } else if ([condition isEqualToString:@"晴间多云"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloudSun];
    } else if ([condition isEqualToString:@"多云"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloudSun];
    } else if (([condition isEqualToString:@"小雪"]
               || [condition isEqualToString:@"阵雪"]) && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSnow];
    } else if ([condition isEqualToString:@"中雪"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconFlurries];
    }  else if (([condition isEqualToString:@"大雪"]
               || [condition isEqualToString:@"暴雪"]) && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconFlurries];
    } else if ([condition isEqualToString:@"雾"]  && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconFogSun];
    } else if (([condition isEqualToString:@"雷雨"]
               || [condition isEqualToString:@"雷阵雨"]) && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconLightning];
    } else if ([condition isEqualToString:@"暴雨"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconHail];
    } else if ([condition isEqualToString:@"冰雹"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSleet];
    } else if ([condition isEqualToString:@"大雨"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconDownpour];
    } else if (([condition isEqualToString:@"小雨"]
               || [condition isEqualToString:@"阵雨"]) && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconDrizzle];
    }  else if ([condition isEqualToString:@"中雨"] && [status isEqualToString:@"sun"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconRainAlt];
    }  else if ([condition isEqualToString:@"霾"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconHazeMoon];
    } else if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconMoon];
    } else if ([condition isEqualToString:@"晴间多云"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloudMoon];
    } else if ([condition isEqualToString:@"多云"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloudMoon];
    } else if (([condition isEqualToString:@"小雪"]
                || [condition isEqualToString:@"阵雪"]) && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSnowMoon];
    } else if ([condition isEqualToString:@"中雪"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconFlurriesMoon];
    }  else if (([condition isEqualToString:@"大雪"]
                 || [condition isEqualToString:@"暴雪"]) && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconFlurriesMoon];
    } else if ([condition isEqualToString:@"雾"]  && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconFogMoon];
    } else if (([condition isEqualToString:@"雷雨"]
                || [condition isEqualToString:@"雷阵雨"]) && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconLightningMoon];
    } else if ([condition isEqualToString:@"暴雨"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconHailMoon];
    } else if ([condition isEqualToString:@"冰雹"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSleetMoon];
    } else if ([condition isEqualToString:@"大雨"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconDownpourMoon];
    } else if (([condition isEqualToString:@"小雨"]
                || [condition isEqualToString:@"阵雨"]) && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconDrizzleMoon];
    }  else if ([condition isEqualToString:@"中雨"] && [status isEqualToString:@"moon"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconRainMoonAlt];
    }
    
    return iconName;
    
}

/**
 *  根据给定的日期算出星期
 *
 *  @param featureDate 传入的日期
 *
 *  @return 返回的星期
 */
- (NSString *)featureWeekdayWithDate:(NSString *)featureDate {

    NSArray *weekdays               = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];

    // 创建格式对象
    NSDateFormatter *formatter      = [[NSDateFormatter alloc] init];
    // 设置日期格式,可以根据自己的需求随时调整，否则计算的结果可能为 nil
    formatter.dateFormat            = @"yyyy-MM-dd";
    // 将字符串日期 转换为 NSDate 类型
    NSDate *endDate                 = [formatter dateFromString:featureDate];


    NSCalendar *calendar            = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone            = [[NSTimeZone alloc] initWithName:@"Asia/Beijing"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit     = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:endDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

/**
 *  根据系统时间,日出日落时间判断白天还是黑天
 *
 *  @param now     系统当前时间
 *  @param sunrise 日出时间
 *  @param sunset  日落时间
 *
 *  @return 返回白天是还是黑天 @"sun":白天;@"moon":黑天
 */
- (NSString *)nowTime:(NSString *)now sunrise:(NSString *)sunrise sunset:(NSString *)sunset {
    
    NSInteger nowString = [now integerValue];
    
    NSRange range = NSMakeRange(2, 1);
    NSMutableString *cutSunrise = [NSMutableString stringWithString:sunrise];
    NSMutableString *cutSunset = [NSMutableString stringWithString:sunset];
    [cutSunrise deleteCharactersInRange:range];
    [cutSunset  deleteCharactersInRange:range];
    
    NSInteger sunriseString = [cutSunrise integerValue];
    NSInteger sunsetString = [cutSunset integerValue];

    return (nowString > sunriseString && nowString < sunsetString) ? @"sun":@"moon";
}


@end
