//
//  YTWeatherData.m
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//
//[weatherDict setObject:pop forKey:@"pop"];
//[weatherDict setObject:hum forKey:@"hum"];
//[weatherDict setObject:pcpn forKey:@"pcpn"];
//[weatherDict setObject:fl forKey:@"fl"];
//[weatherDict setObject:qlty forKey:@"qlty"];
//[weatherDict setObject:pm25 forKey:@"pm25"];
#import "YTWeatherData.h"

@implementation YTWeatherData

- (instancetype)initWithDict:(NSDictionary *)dict {


    self.location        = [dict objectForKey:@"location"];
    self.weather         = [dict objectForKey:@"weather"];
    self.temperature     = [dict objectForKey:@"temperature"];
    self.highTemp        = [dict objectForKey:@"highTemp"];
    self.lowTemp         = [dict objectForKey:@"lowTemp"];
    self.sunset          = [dict objectForKey:@"sunset"];
    self.sunrise         = [dict objectForKey:@"sunrise"];
    self.icon            = [dict objectForKey:@"icon"];
    self.forecastWeather = [dict objectForKey:@"forecastWeather"];

    self.pop             = [dict objectForKey:@"pop"];
    self.hum             = [dict objectForKey:@"hum"];
    self.pcpn            = [dict objectForKey:@"pcpn"];
    self.fl              = [dict objectForKey:@"fl"];
    self.qlty            = [dict objectForKey:@"qlty"];
    self.pm25            = [dict objectForKey:@"pm25"];
    
    self.weatherImage    = [dict objectForKey:@"weatherImage"];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if(self == [super init]) {
        self.location        = [aDecoder decodeObjectForKey:@"location"];
        self.weather         = [aDecoder decodeObjectForKey:@"weather"];
        self.temperature     = [aDecoder decodeObjectForKey:@"temperature"];
        self.highTemp        = [aDecoder decodeObjectForKey:@"highTemp"];
        self.lowTemp         = [aDecoder decodeObjectForKey:@"lowTemp"];
        self.sunset          = [aDecoder decodeObjectForKey:@"sunset"];
        self.sunrise         = [aDecoder decodeObjectForKey:@"sunrise"];
        self.icon            = [aDecoder decodeObjectForKey:@"icon"];
        self.forecastWeather = [aDecoder decodeObjectForKey:@"forecastWeather"];
        self.pop             = [aDecoder decodeObjectForKey:@"pop"];
        self.hum             = [aDecoder decodeObjectForKey:@"hum"];
        self.pcpn            = [aDecoder decodeObjectForKey:@"pcpn"];
        self.fl              = [aDecoder decodeObjectForKey:@"fl"];
        self.qlty            = [aDecoder decodeObjectForKey:@"qlty"];
        self.pm25            = [aDecoder decodeObjectForKey:@"pm25"];
        self.weatherImage    = [aDecoder decodeObjectForKey:@"weatherImage"];

    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.weather forKey:@"weather"];
    [aCoder encodeObject:self.temperature forKey:@"temperature"];
    [aCoder encodeObject:self.highTemp forKey:@"highTemp"];
    [aCoder encodeObject:self.lowTemp forKey:@"lowTemp"];
    [aCoder encodeObject:self.sunset forKey:@"sunset"];
    [aCoder encodeObject:self.sunrise forKey:@"sunrise"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.forecastWeather forKey:@"forecastWeather"];
    [aCoder encodeObject:self.pop forKey:@"pop"];
    [aCoder encodeObject:self.hum forKey:@"hum"];
    [aCoder encodeObject:self.pcpn forKey:@"pcpn"];
    [aCoder encodeObject:self.fl forKey:@"fl"];
    [aCoder encodeObject:self.qlty forKey:@"qlty"];
    [aCoder encodeObject:self.pm25 forKey:@"pm25"];
    [aCoder encodeObject:self.weatherImage forKey:@"weatherImage"];

}



@end
