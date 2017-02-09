//
//  YTLocation.m
//  Temps
//
//  Created by Yans on 2017/2/9.
//  Copyright © 2017年 Ewane Shen. All rights reserved.
//

#import "YTLocation.h"

@implementation YTLocation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.here = [aDecoder decodeBoolForKey:@"here"];
        self.cl_location = [aDecoder decodeObjectForKey:@"cl_location"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.here forKey:@"here"];
    [aCoder encodeObject:self.cl_location forKey:@"cl_location"];
}

+ (instancetype)locationWithCLLocation:(CLLocation *)location {
    YTLocation *yt_location = [[YTLocation alloc] init];
    yt_location.cl_location = location;
    return yt_location;
}

@end
