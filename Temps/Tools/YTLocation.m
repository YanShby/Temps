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
        self.here = [aDecoder decodeObjectForKey:@"here"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.here forKey:@"here"];
}

@end
