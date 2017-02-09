//
//  YTSaveTool.m
//  YanTemps
//
//  Created by Yans on 2017/1/3.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import "YTSaveTool.h"

@implementation YTSaveTool

+ (BOOL)archiveRootObject:(id)object toFile:(NSString *)file {
    
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [cachePath stringByAppendingPathComponent:file];
    
    YTLog(@"%@",filePath);
    [NSKeyedArchiver archiveRootObject:object toFile:@"/Users/yans/Desktop/LOCATIONS.plist"];
    return [NSKeyedArchiver archiveRootObject:object toFile:filePath];
}

+ (instancetype)unarchiveObjectWithFile:(NSString *)file {
    
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [cachePath stringByAppendingPathComponent:file];
    
    YTLog(@"%@",filePath);
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
