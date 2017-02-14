//
//  YTLocation.m
//  Temps
//
//  Created by Yans on 2017/2/9.
//  Copyright © 2017年 Ewane Shen. All rights reserved.
//

#import "YTLocation.h"

@interface YTLocation ()

@end

@implementation YTLocation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.here = [aDecoder decodeBoolForKey:@"here"];
        self.cl_location = [aDecoder decodeObjectForKey:@"cl_location"];
        self.cityName = [aDecoder decodeObjectForKey:@"cityName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.here forKey:@"here"];
    [aCoder encodeObject:self.cl_location forKey:@"cl_location"];
    [aCoder encodeObject:self.cityName forKey:@"cityName"];
}

+ (instancetype)locationWithCLLocation:(CLLocation *)location {
    YTLocation *yt_location = [[YTLocation alloc] init];
    yt_location.cl_location = location;
    
    [yt_location performSelectorOnMainThread:@selector(reverseGeocodeWithYTLocation:) withObject:yt_location waitUntilDone:YES];

    YTLog(@"qqq%@",yt_location.cityName);
    return yt_location;
}

- (void)reverseGeocodeWithYTLocation:(YTLocation *)yt_location {
    
    //反地理编码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [geocoder reverseGeocodeLocation:yt_location.cl_location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
                NSString *city = placemark.locality;
                if (!city) {
                    city = placemark.administrativeArea;
                }
                if ([city containsString:@"市辖区"] || [city containsString:@"市"]) {
                    city = [city stringByReplacingOccurrencesOfString:@"市辖区" withString:@""];
                    city = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];
                }
                yt_location.cityName = city;
                YTLog(@"%@",yt_location.cityName);
            }
        }];
    });

    YTLog(@"%@",yt_location.cityName);

}

@end
