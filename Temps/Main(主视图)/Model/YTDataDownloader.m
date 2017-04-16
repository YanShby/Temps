//
//  YTDataDownloader.m
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//  API:@"https://free-api.heweather.com/v5/weather?city=37.785834,122.406417&&key=41e80f90800e40f69693679ba5be23ee"

#import "YTDataDownloader.h"
#import "YTWeatherData.h"
#import "Climacons.h"
#import "YTLocation.h"

#import <SVProgressHUD.h>
#import <AFNetworking.h>

@interface YTDataDownloader ()

/**天气api*/
@property (nonatomic,copy) NSString      *key;
/**记录当前时间*/
@property (nonatomic, strong) NSString   *time;
/**AFN HTTP 请求管理者*/
@property (nonatomic, strong) AFHTTPRequestOperationManager *mgr;
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
        self.mgr = [AFHTTPRequestOperationManager manager];
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
- (void)dataForLocation:(YTLocation *)location showStatus:(NSString *)showStatus showDone:(NSString *)showDone completion:(YTWeatherDataDownloadCompletion)completion {
 
    if (!location) return;
    
    [SVProgressHUD showWithStatus:showStatus maskType:SVProgressHUDMaskTypeClear];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [self.mgr GET:YT_API_GET parameters:[self parametersWithLocation:location] success:^(AFHTTPRequestOperation *operation, id responseObject) {

        YTWeatherData *weatherData = [self dataFormJSON:responseObject];
        
        if (weatherData == nil) {

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,nil);
                [SVProgressHUD showErrorWithStatus:showDone maskType:SVProgressHUDMaskTypeClear];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
            });
            return ;
        }

        weatherData.here = location.isHere ? YES : NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(weatherData,nil);
            [SVProgressHUD showSuccessWithStatus:showDone maskType:SVProgressHUDMaskTypeClear];
        });
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        completion(nil,error);
        [SVProgressHUD showErrorWithStatus:showDone maskType:SVProgressHUDMaskTypeClear];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
    
    
}

/**
 *  根据CLLocation数据生成对应的接口参数
 *
 *  @param location 地点对象
 *
 *  @return 返回接口参数
 */
- (NSMutableDictionary *)parametersWithLocation:(YTLocation *)location {
    


    NSMutableDictionary *parameters    = [NSMutableDictionary dictionary];
    CLLocationCoordinate2D coordinates = location.cl_location.coordinate;
    NSString *city                     = location.cityName;

    if (city) {
        parameters[@"city"]                = [NSString stringWithFormat:@"%@",city];
    }else {
        parameters[@"city"]                = [NSString stringWithFormat:@"%f,%f",coordinates.longitude,coordinates.latitude];
    }

    YTLog(@"citycitycity----%@",parameters[@"city"]);
    parameters[@"key"]                 = self.key;

    return parameters;
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
    
    if ([mainDict[@"status"] isEqualToString:@"unknown city"]) return nil;
    
    NSDictionary *basic               = [mainDict objectForKey:@"basic"];
    NSArray *forecast                 = [mainDict objectForKey:@"daily_forecast"];
    NSDictionary *now                 = [mainDict objectForKey:@"now"];
    NSDictionary *city                 = [[mainDict objectForKey:@"aqi"] objectForKey:@"city"];

    //把解析出来的信息放入这个字典
    NSMutableDictionary *weatherDict  = [NSMutableDictionary dictionary];

    NSString *location                = [basic objectForKey:@"city"];
    NSString *weather                 = [[now objectForKey:@"cond"] objectForKey:@"txt"];
    NSString *temperature             = [now objectForKey:@"tmp"];
    NSString *highTemp                = [[[forecast objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"];
    NSString *lowTemp                 = [[[forecast objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"];
    NSString *sunrise                 = [[[forecast objectAtIndex:0] objectForKey:@"astro"] objectForKey:@"sr"];
    NSString *sunset                  = [[[forecast objectAtIndex:0] objectForKey:@"astro"] objectForKey:@"ss"];
    UIImage  *icon                    = [self iconForCondition:weather
                                                    timeStatus:[self nowTime:[self time] sunrise:sunrise sunset:sunset]];
    NSString *pop                     = [[forecast objectAtIndex:0] objectForKey:@"pop"];
    NSString *hum                     = [now objectForKey:@"hum"];
    NSString *pcpn                    = [now objectForKey:@"pcpn"];
    NSString *fl                      = [now objectForKey:@"fl"];
    NSString *qlty                    = [city objectForKey:@"qlty"];
    NSString *pm25                    = [city objectForKey:@"pm25"];
    
    UIImage *weatherImage             = [self imageForCondition:weather
                                                     timeStatus:[self nowTime:[self time] sunrise:sunrise sunset:sunset]
                                                    temperature:temperature];
    
    //存放从JSON中取出的预测五天的天气
    NSMutableArray *oldForecast       = [NSMutableArray array];

    for (int i                        = 1; i <= 5; i++) {
        [oldForecast addObject:[forecast objectAtIndex:i]];
    }
    //存放处理后的预测五天的天气
    NSMutableArray *newForecast       = [NSMutableArray array];

    for (int i                        = 0; i < 5 ; i++) {

        UIImage *weatherIcon             = [self iconForCondition:[[oldForecast[i] objectForKey:@"cond"] objectForKey:@"txt_d"]
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
    [weatherDict setObject:pop forKey:@"pop"];
    [weatherDict setObject:hum forKey:@"hum"];
    [weatherDict setObject:pcpn forKey:@"pcpn"];
    [weatherDict setObject:fl forKey:@"fl"];
    [weatherDict setObject:qlty forKey:@"qlty"];
    [weatherDict setObject:pm25 forKey:@"pm25"];
    [weatherDict setObject:weatherImage forKey:@"weatherImage"];

    YTWeatherData *weatherData        = [[YTWeatherData alloc] initWithDict:weatherDict];

    return weatherData;
}

/**
 *  将从json中获取的天气状况转化成天气字体对应的字符
 *
 *  @param condition 天气状态详情
 *  @param status    时间状态,判断是白天还是黑天.
 *
 *  @return 返回天气数据对应的icon
 */
- (UIImage *)iconForCondition:(NSString *)condition timeStatus:(NSString *)status
{
    if ([condition isEqualToString:@"霾"])
    {
        return [UIImage imageNamed:@"雾霾icon"];
    }
    else if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"sun"])
    {
        return [UIImage imageNamed:@"晴icon"];
    }
    else if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"moon"])
    {
        return [UIImage imageNamed:@"夜间晴icon"];
    }
    else if ([condition isEqualToString:@"晴间多云"])
    {
        return [UIImage imageNamed:@"多云icon"];
    }
    else if (([condition isEqualToString:@"多云"] || [condition isEqualToString:@"阴"]))
    {
        return [UIImage imageNamed:@"云icon"];
    }
    else if (([condition containsString:@"多云"] || [condition isEqualToString:@"阴"]) && [status isEqualToString:@"moon"])
    {
        return [UIImage imageNamed:@"夜间多云icon"];
    }
    else if (([condition isEqualToString:@"小雪"] || [condition isEqualToString:@"阵雪"]))
    {
        return [UIImage imageNamed:@"小雪icon"];
    }
    else if ([condition isEqualToString:@"中雪"])
    {
        return [UIImage imageNamed:@"中雪icon"];
    }
    else if ([condition isEqualToString:@"大雪"])
    {
        return [UIImage imageNamed:@"大雪icon"];
    }
    else if ([condition isEqualToString:@"暴雪"])
    {
        return [UIImage imageNamed:@"大暴雪icon"];
    }
    else if ([condition isEqualToString:@"雾"])
    {
        return [UIImage imageNamed:@"雾icon"];
    }
    else if (([condition isEqualToString:@"雷雨"] || [condition isEqualToString:@"雷阵雨"]))
    {
        return [UIImage imageNamed:@"雷阵雨icon"];
    }
    else if ([condition isEqualToString:@"暴雨"])
    {
        return [UIImage imageNamed:@"暴雨icon"];
    }
    else if ([condition isEqualToString:@"冰雹"])
    {
        return [UIImage imageNamed:@"雨加冰雹icon"];
    }
    else if ([condition isEqualToString:@"大雨"])
    {
        return [UIImage imageNamed:@"大雨icon"];
    }
    else if (([condition isEqualToString:@"小雨"] || [condition isEqualToString:@"阵雨"]))
    {
        return [UIImage imageNamed:@"小雨icon"];
    }
    else if ([condition isEqualToString:@"中雨"])
    {
        return [UIImage imageNamed:@"中雨icon"];
    }
    
    return [UIImage imageNamed:@"晴icon"];
    
}

- (UIImage *)imageForCondition:(NSString *)condition timeStatus:(NSString *)status temperature:(NSString *)temp{
   
    if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"sun"]) {
        return [UIImage imageNamed:@"晴天-日"];
    }
    else if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"moon"]) {
        return [UIImage imageNamed:@"晴天-夜"];
    }
    else if ([condition isEqualToString:@"晴"] && [status isEqualToString:@"sun"] && ([temp integerValue] >= 30)) {
        return [UIImage imageNamed:@"高温"];
    }
    else if (([condition isEqualToString:@"雷雨"]
               || [condition isEqualToString:@"雷阵雨"]) && [status isEqualToString:@"sun"]) {
        return [UIImage imageNamed:@"雷雨-日"];
    }
    else if (([condition isEqualToString:@"雷雨"]
               || [condition isEqualToString:@"雷阵雨"]) && [status isEqualToString:@"moon"]) {
        return [UIImage imageNamed:@"雷雨-夜"];
    }
    else if (([condition containsString:@"雨"] && [status isEqualToString:@"sun"])) {
        return [UIImage imageNamed:@"小雨-日"];
    }
    else if (([condition containsString:@"雨"] && [status isEqualToString:@"moon"])) {
        return [UIImage imageNamed:@"小雨-夜"];
    }
    else if (([condition isEqualToString:@"多云"] || [condition isEqualToString:@"阴"])&& [status isEqualToString:@"sun"]) {
        return [UIImage imageNamed:@"多云-日"];
    }
    else if (([condition isEqualToString:@"多云"] || [condition isEqualToString:@"阴"])&& [status isEqualToString:@"moon"]) {
        return [UIImage imageNamed:@"多云-夜"];
    }
    else if ([condition containsString:@"霾"] || [condition containsString:@"雾"] ) {
        return [UIImage imageNamed:@"雾霾"];
    }
    else if ([condition isEqualToString:@"雨夹雪"] && [status isEqualToString:@"sun"]) {
        return [UIImage imageNamed:@"雨夹雪-日"];
    }
    else if ([condition isEqualToString:@"雨夹雪"] && [status isEqualToString:@"moon"]) {
        return [UIImage imageNamed:@"雨夹雪-夜"];
    }
    else if ([condition containsString:@"雪"] && [status isEqualToString:@"sun"]) {
        return [UIImage imageNamed:@"下雪-日"];
    }
    else if ([condition containsString:@"雪"] && [status isEqualToString:@"moon"]) {
        return [UIImage imageNamed:@"下雪-夜"];
    }
    return [UIImage imageNamed:@"渐变"];
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
