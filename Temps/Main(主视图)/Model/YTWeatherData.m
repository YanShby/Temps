//
//  YTWeatherData.m
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

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
    self.local           = [dict objectForKey:@"local"];


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
    self.local           = [aDecoder decodeObjectForKey:@"local"];
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
    [aCoder encodeObject:self.local forKey:@"local"];

}



@end
