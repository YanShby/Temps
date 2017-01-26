//
//  YTForecastData.m
//  YanTemps
//
//  Created by Yans on 2017/1/2.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import "YTForecastData.h"

@implementation YTForecastData

- (instancetype)initWithDict:(NSDictionary *)dict {

    self.dayOfWeek   = [dict objectForKey:@"dayOfWeek"];
    self.weatherIcon = [dict objectForKey:@"weatherIcon"];
    self.high        = [dict objectForKey:@"high"];
    self.low         = [dict objectForKey:@"low"];


    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    if(self == [super init]) {
    self.dayOfWeek   = [aDecoder decodeObjectForKey:@"dayOfWeek"];
    self.weatherIcon = [aDecoder decodeObjectForKey:@"weatherIcon"];
    self.high        = [aDecoder decodeObjectForKey:@"high"];
    self.low         = [aDecoder decodeObjectForKey:@"low"];

    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:self.dayOfWeek forKey:@"dayOfWeek"];
    [aCoder encodeObject:self.weatherIcon forKey:@"weatherIcon"];
    [aCoder encodeObject:self.high forKey:@"high"];
    [aCoder encodeObject:self.low forKey:@"low"];

}



@end
