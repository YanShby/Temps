//
//  YTSaveTool.h
//  YanTemps
//
//  Created by Yans on 2017/1/3.
//  Copyright © 2017年 Yans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTSaveTool : NSObject

+ (instancetype)unarchiveObjectWithFile:(NSString *)file;
+ (BOOL)archiveRootObject:(id)object toFile:(NSString *)file;

@end
